import 'package:ama_meet/models/video_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<List<VideoModel>> getVideos(String classId) async {
    try {
      final snapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .orderBy('sectionOrder')
          .get();
      return snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }
}