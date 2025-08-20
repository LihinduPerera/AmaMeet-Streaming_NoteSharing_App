import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/class_video.dart';
import '../services/youtube_service.dart';

final String CLOUDINARY_CLOUD_NAME = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
final String CLOUDINARY_UPLOAD_PRESET_VIDEO = dotenv.env['CLOUDINARY_UPLOAD_PRESET_VIDEO'] ?? '';

class ClassVideoRepository {
  final _firestore = FirebaseFirestore.instance;
  final _youtubeService = YouTubeService();

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

  Future<void> uploadVideoToCloudinary(
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
        'provider': 'cloudinary',
      });
    } catch (e) {
      throw Exception('Cloudinary upload failed: $e');
    }
  }

  Future<void> uploadVideoToYouTube(
    String classId,
    File file,
    String filename,
    String sectionTitle,
    int sectionOrder,
    YouTubePrivacyStatus privacyStatus, {
    Function(int sent, int total)? onUploadProgress,
  }) async {
    try {
      // Authenticate with YouTube
      final authenticated = await _youtubeService.authenticate();
      if (!authenticated) {
        throw Exception('YouTube authentication failed');
      }

      // Upload to YouTube
      final videoId = await _youtubeService.uploadVideo(
        videoFile: file,
        title: '$sectionTitle - $filename',
        description: 'Class recording: $sectionTitle',
        privacyStatus: privacyStatus,
        onProgress: onUploadProgress,
      );

      if (videoId == null) {
        throw Exception('Failed to get YouTube video ID');
      }

      final youtubeUrl = _youtubeService.getVideoUrl(videoId);

      // Save to Firestore
      await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .add({
        'filename': filename,
        'publicId': videoId, // Using YouTube video ID as publicId
        'url': youtubeUrl,
        'uploadedAt': DateTime.now().millisecondsSinceEpoch,
        'sectionTitle': sectionTitle,
        'sectionOrder': sectionOrder,
        'provider': 'youtube',
        'youtubePrivacyStatus': privacyStatus.name,
        'youtubeVideoId': videoId,
      });
    } catch (e) {
      throw Exception('YouTube upload failed: $e');
    }
  }

  Future<void> deleteVideo(String classId, String docId, String publicId) async {
    try {
      // Get video details first to check provider
      final doc = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('videos')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final provider = data?['provider'] ?? 'cloudinary';
        
        // Delete from Firestore
        await doc.reference.delete();

        // Note: For production, you should implement server-side deletion
        // For Cloudinary: Use Admin API to delete the resource
        // For YouTube: Use YouTube API to delete the video (if needed)
      }
    } catch (e) {
      throw Exception('Video deletion failed: $e');
    }
  }

  void dispose() {
    _youtubeService.dispose();
  }
}