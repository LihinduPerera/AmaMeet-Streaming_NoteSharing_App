import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/youtube/v3.dart' as youtube;
import '../models/class_video.dart';

/// Mobile YouTube helper:
/// - Uses google_sign_in for OAuth on device (youtube.upload scope)
/// - Uploads using googleapis youtube.videos.insert with uploadMedia.
/// NOTE: This code uses the access token provided by google_sign_in.
/// Mobile sign-in flows may not provide a long-lived refresh token; for production
/// consider a backend for refresh token / resumable uploads.
class YouTubeService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/youtube.upload',
      'email',
      'profile',
    ],
  );

  GoogleSignInAccount? _user;
  String? _accessToken;

  /// Signs in the user (interactive). Returns true if signed in & has access token.
  Future<bool> signIn() async {
    try {
      _user = await _googleSignIn.signIn();
      if (_user == null) return false;
      final auth = await _user!.authentication;
      _accessToken = auth.accessToken;
      return _accessToken != null;
    } catch (e) {
      print('YouTube signIn error: $e');
      return false;
    }
  }

  /// Signs out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _accessToken = null;
    _user = null;
  }

  /// Upload a video file to the signed-in user's channel.
  /// Returns the uploaded videoId on success.
  Future<String?> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required YouTubePrivacyStatus privacyStatus,
  }) async {
    if (_accessToken == null) {
      final ok = await signIn();
      if (!ok) {
        throw Exception('User not signed in or permission not granted.');
      }
    }

    final client = _BearerClient(_accessToken!);
    final ytApi = youtube.YouTubeApi(client);

    try {
      final video = youtube.Video();
      video.snippet = youtube.VideoSnippet()
        ..title = title
        ..description = description
        ..tags = ['education', 'class', 'recording'];
      video.status = youtube.VideoStatus()..privacyStatus = privacyStatus.name;

      final stream = videoFile.openRead();
      final media = youtube.Media(stream, videoFile.lengthSync());

      // Note: googleapis will handle the upload (may use resumable internally).
      final response = await ytApi.videos.insert(
        video,
        ['snippet', 'status'],
        uploadMedia: media,
      );

      return response.id;
    } catch (e) {
      print('YouTube upload error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}

/// Separate helper class for attaching Bearer token
class _BearerClient extends http.BaseClient {
  final String _token;
  final http.Client _inner = http.Client();

  _BearerClient(this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }

  void close() {
    _inner.close();
  }
}
