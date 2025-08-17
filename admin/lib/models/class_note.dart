import 'package:equatable/equatable.dart';

class ClassNote extends Equatable {
  final String docId;
  final String classId;
  final String filename;
  final String url;
  final String publicId;
  final int uploadedAt;

  const ClassNote(
      {required this.docId,
      required this.classId,
      required this.filename,
      required this.url,
      required this.publicId,
      required this.uploadedAt});

  factory ClassNote.fromMap(String docId, Map<String, dynamic> m) {
    return ClassNote(
      docId: docId,
      classId: m['classId'] ?? '',
      filename: m['filename'] ?? '',
      url: m['url'] ?? '',
      publicId: m['publicId'] ?? '',
      uploadedAt: m['uploadedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'classId': classId,
        'filename': filename,
        'url': url,
        'publicId': publicId,
        'uploadedAt': uploadedAt,
      };

  @override
  List<Object?> get props =>
      [docId, classId, filename, url, publicId, uploadedAt];
}
