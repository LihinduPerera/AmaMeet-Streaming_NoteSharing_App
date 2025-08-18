import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/class_video.dart';

final String CLOUDINARY_CLOUD_NAME = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
final String CLOUDINARY_UPLOAD_PRESET_VIDEO = dotenv.env['CLOUDINARY_UPLOAD_PRESET_VIDEO'] ?? '';

class ClassVideoRepository {
  final _firestore = FirebaseFirestore.instance;

  final cloudinary =
      CloudinaryPublic(CLOUDINARY_CLOUD_NAME, CLOUDINARY_UPLOAD_PRESET_VIDEO, cache: false);

  Future<List<ClassVideo>> getVideos(String classId) async {
    try {
      final snapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .orderBy('sectionOrder')
          .get();
      return snapshot.docs.map((doc) => ClassVideo.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  Future<void> uploadVideo(
    String classId,
    File file,
    String filename,
    String sectionTitle,
    int sectionOrder, {
    Function(int sent, int total)? onUploadProgress,
  }) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Video,
        ),
        onProgress: onUploadProgress,
      );

      await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .add({
        'filename': filename,
        'publicId': response.publicId,
        'url': response.secureUrl,
        'uploadedAt': DateTime.now().millisecondsSinceEpoch,
        'sectionTitle': sectionTitle,
        'sectionOrder': sectionOrder,
      });
    } catch (e) {
      throw Exception('Video upload failed: $e');
    }
  }

  Future<void> deleteVideo(String classId, String docId, String publicId) async {
    try {
      await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .doc(docId)
          .delete();
      // Note: Cloudinary deletion should be implemented server-side
    } catch (e) {
      throw Exception('Video deletion failed: $e');
    }
  }
}