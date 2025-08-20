import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:googleapis_auth/auth_io.dart';
import '../models/class_video.dart';

final String YOUTUBE_CLIENT_ID = dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
final String YOUTUBE_CLIENT_SECRET = dotenv.env[''] ?? '';

class YouTubeService {
  static const List<String> scopes = [
    youtube.YouTubeApi.youtubeUploadScope,
    youtube.YouTubeApi.youtubeScope,
  ];

  youtube.YouTubeApi? _youtubeApi;
  AuthClient? _authClient;

  Future<bool> authenticate() async {
    try {
      final clientId = ClientId(YOUTUBE_CLIENT_ID, YOUTUBE_CLIENT_SECRET);
      
      _authClient = await clientViaUserConsent(
        clientId,
        scopes,
        (url) {
          // In a real app, you'd open this URL in a browser
          // For now, we'll print it - you might want to show it in a dialog
          print('Please go to the following URL and re-run the program:');
          print('  => $url');
        },
      );

      _youtubeApi = youtube.YouTubeApi(_authClient!);
      return true;
    } catch (e) {
      print('YouTube authentication failed: $e');
      return false;
    }
  }

  Future<String?> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required YouTubePrivacyStatus privacyStatus,
    Function(int sent, int total)? onProgress,
  }) async {
    if (_youtubeApi == null) {
      throw Exception('YouTube API not authenticated');
    }

    try {
      final videoMetadata = youtube.Video();
      videoMetadata.snippet = youtube.VideoSnippet();
      videoMetadata.snippet!.title = title;
      videoMetadata.snippet!.description = description;
      videoMetadata.snippet!.tags = ['education', 'class', 'recording'];
      
      videoMetadata.status = youtube.VideoStatus();
      videoMetadata.status!.privacyStatus = privacyStatus.name;

      // Create media stream
      final stream = videoFile.openRead();
      final media = youtube.Media(stream, videoFile.lengthSync());

      // Upload video
      final response = await _youtubeApi!.videos.insert(
        videoMetadata,
        ['snippet','status'],
        uploadMedia: media,
      );

      return response.id;
    } catch (e) {
      print('YouTube upload failed: $e');
      rethrow;
    }
  }

  String getVideoUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  void dispose() {
    _authClient?.close();
  }
}