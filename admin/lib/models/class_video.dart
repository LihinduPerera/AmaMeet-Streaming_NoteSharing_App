import 'package:cloud_firestore/cloud_firestore.dart';

class ClassVideo {
  final String docId;
  final String filename;
  final String publicId;
  final String url;
  final int uploadedAt;
  final String sectionTitle;
  final int sectionOrder;

  ClassVideo({
    required this.docId,
    required this.filename,
    required this.publicId,
    required this.url,
    required this.uploadedAt,
    required this.sectionTitle,
    required this.sectionOrder,
  });

  factory ClassVideo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassVideo(
      docId: doc.id,
      filename: data['filename'],
      publicId: data['publicId'],
      url: data['url'],
      uploadedAt: data['uploadedAt'],
      sectionTitle: data['sectionTitle'],
      sectionOrder: data['sectionOrder'],
    );
  }
}
