import 'package:equatable/equatable.dart';

class ClassNote extends Equatable {
  final String docId;
  final String classId;
  final String filename;
  final String url;
  final String publicId;
  final int uploadedAt;
  final String sectionTitle; // New field for lesson/section title
  final int sectionOrder; // New field for ordering sections

  const ClassNote({
    required this.docId,
    required this.classId,
    required this.filename,
    required this.url,
    required this.publicId,
    required this.uploadedAt,
    required this.sectionTitle,
    required this.sectionOrder,
  });

  factory ClassNote.fromMap(String docId, Map<String, dynamic> m) {
    return ClassNote(
      docId: docId,
      classId: m['classId'] ?? '',
      filename: m['filename'] ?? '',
      url: m['url'] ?? '',
      publicId: m['publicId'] ?? '',
      uploadedAt: m['uploadedAt'] ?? 0,
      sectionTitle: m['sectionTitle'] ?? 'General',
      sectionOrder: m['sectionOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'classId': classId,
        'filename': filename,
        'url': url,
        'publicId': publicId,
        'uploadedAt': uploadedAt,
        'sectionTitle': sectionTitle,
        'sectionOrder': sectionOrder,
      };

  @override
  List<Object?> get props => [
        docId,
        classId,
        filename,
        url,
        publicId,
        uploadedAt,
        sectionTitle,
        sectionOrder,
      ];
}