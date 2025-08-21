import 'package:cloud_firestore/cloud_firestore.dart';

enum VideoProvider { cloudinary, youtube }
enum YouTubePrivacyStatus { private, public, unlisted }

class ClassVideo {
  final String id;
  final String filename;
  final String publicId;
  final String url;
  final String sectionTitle;
  final int sectionOrder;
  final int uploadedAt;
  final VideoProvider provider;
  final YouTubePrivacyStatus? youtubePrivacyStatus;
  final String? youtubeVideoId;

  ClassVideo({
    required this.id,
    required this.filename,
    required this.publicId,
    required this.url,
    required this.sectionTitle,
    required this.sectionOrder,
    required this.uploadedAt,
    required this.provider,
    this.youtubePrivacyStatus,
    this.youtubeVideoId,
  });

  factory ClassVideo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassVideo(
      id: doc.id,
      filename: data['filename'] as String,
      publicId: data['publicId'] as String,
      url: data['url'] as String,
      sectionTitle: data['sectionTitle'] as String,
      sectionOrder: (data['sectionOrder'] as num).toInt(),
      uploadedAt: (data['uploadedAt'] as num).toInt(),
      provider: VideoProvider.values.firstWhere(
        (e) => e.toString() == 'VideoProvider.${data['provider'] ?? 'cloudinary'}',
        orElse: () => VideoProvider.cloudinary,
      ),
      youtubePrivacyStatus: data['youtubePrivacyStatus'] != null 
        ? YouTubePrivacyStatus.values.firstWhere(
            (e) => e.toString() == 'YouTubePrivacyStatus.${data['youtubePrivacyStatus']}',
            orElse: () => YouTubePrivacyStatus.unlisted,
          )
        : null,
      youtubeVideoId: data['youtubeVideoId'] as String?,
    );
  }

  String get docId => id;

  String get thumbnailUrl {
    if (provider == VideoProvider.youtube && youtubeVideoId != null) {
      return 'https://img.youtube.com/vi/$youtubeVideoId/maxresdefault.jpg';
    }
    if (url.endsWith('.png')) return url;
    return url.replaceAll(RegExp(r'\.\w+$'), '.png');
  }

  String get hlsUrl {
    if (provider == VideoProvider.youtube) {
      return url; // YouTube URL for youtube_player packages
    }
    if (url.endsWith('.m3u8')) return url;
    return url.replaceAll(RegExp(r'\.\w+$'), '.m3u8');
  }

  bool get isYouTubeVideo => provider == VideoProvider.youtube;
  bool get isCloudinaryVideo => provider == VideoProvider.cloudinary;
}
