import 'package:cloud_firestore/cloud_firestore.dart';

class ClassVideo {
  final String id;
  final String filename;
  final String publicId;
  final String url;
  final String sectionTitle;
  final int sectionOrder;
  final int uploadedAt;

  ClassVideo({
    required this.id,
    required this.filename,
    required this.publicId,
    required this.url,
    required this.sectionTitle,
    required this.sectionOrder,
    required this.uploadedAt,
  });

  factory ClassVideo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassVideo(
      id: doc.id,
      filename: data['filename'] as String,
      publicId: data['publicId'] as String,
      url: data['url'] as String,
      sectionTitle: data['sectionTitle'] as String,
      sectionOrder: data['sectionOrder'] as int,
      uploadedAt: data['uploadedAt'] as int,
    );
  }

  String get docId => id;

  String get thumbnailUrl {
    if (url.endsWith('.png')) return url;
    return url.replaceAll(RegExp(r'\.\w+$'), '.png');
  }

  String get hlsUrl {
    if (url.endsWith('.m3u8')) return url;
    return url.replaceAll(RegExp(r'\.\w+$'), '.m3u8');
  }
}