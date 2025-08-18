import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/class_video.dart';

final String CLOUDINARY_CLOUD_NAME = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
final String CLOUDINARY_UPLOAD_PRESET_VIDEO = dotenv.env['CLOUDINARY_UPLOAD_PRESET_VIDEO'] ?? '';

class ClassVideoRepository {
  final _firestore = FirebaseFirestore.instance;

  // Set your Cloudinary details here
  final cloudinary =
      CloudinaryPublic(CLOUDINARY_CLOUD_NAME, CLOUDINARY_UPLOAD_PRESET_VIDEO, cache: false);

  Future<List<ClassVideo>> getVideos(String classId) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('videos')
        .orderBy('sectionOrder')
        .get();

    return snapshot.docs.map((doc) => ClassVideo.fromFirestore(doc)).toList();
  }

  Future<void> uploadVideo(
    String classId,
    File file,
    String filename,
    String sectionTitle,
    int sectionOrder,
  ) async {
    // Upload as video resource type
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Video,
      ),
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
  }

  Future<void> deleteVideo(String classId, String docId, String publicId) async {
    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('videos')
        .doc(docId)
        .delete();

    // OPTIONAL: delete from Cloudinary using an Admin/Server-side API call.
    // Do NOT call Admin API from the client; implement that on trusted server/backend.
  }
}
