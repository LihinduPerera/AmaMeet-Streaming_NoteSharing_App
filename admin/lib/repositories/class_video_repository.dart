import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/class_video.dart';

class ClassVideoRepository {
  final _firestore = FirebaseFirestore.instance;
  final cloudinary =
      CloudinaryPublic("your-cloud-name", "your-upload-preset", cache: false);

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
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(file.path,
          resourceType: CloudinaryResourceType.Video),
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

  Future<void> deleteVideo(
      String classId, String docId, String publicId) async {
    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('videos')
        .doc(docId)
        .delete();

    // Future : call Cloudinary API to delete the video file from storage
  }
}
