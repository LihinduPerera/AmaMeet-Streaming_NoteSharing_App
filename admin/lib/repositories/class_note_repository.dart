import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ama_meet_admin/models/class_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final String CLOUDINARY_CLOUD_NAME = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
final String CLOUDINARY_UPLOAD_PRESET = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

// **Remember to turn on PDF and ZIP files delivery:	Allow delivery of PDF and ZIP files in cloudinary security settings!!!**

class ClassNoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<ClassNote>> notesStreamForClass(String classId) {
    return _firestore
        .collection('class_notes')
        .where('classId', isEqualTo: classId)
        .orderBy('sectionOrder', descending: false)
        .orderBy('uploadedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClassNote.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> uploadClassNote({
    required String classId,
    required File file,
    required String filename,
    required String sectionTitle,
    required int sectionOrder,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/raw/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
    request.fields['folder'] = 'ama_meet_class_notes/$classId';

    final multipartFile = await http.MultipartFile.fromPath('file', file.path, filename: filename);
    request.files.add(multipartFile);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload: ${response.statusCode} ${response.reasonPhrase} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String? ?? body['url'] as String? ?? '';
    final publicId = body['public_id'] as String? ?? '';

    final noteDoc = {
      'classId': classId,
      'filename': filename,
      'url': url,
      'publicId': publicId,
      'uploadedAt': DateTime.now().millisecondsSinceEpoch,
      'sectionTitle': sectionTitle,
      'sectionOrder': sectionOrder,
    };
    await _firestore.collection('class_notes').add(noteDoc);
  }

  Future<void> deleteClassNote({
    required String docId,
    required String publicId,
  }) async {
    await _firestore.collection('class_notes').doc(docId).delete();
  }

  Future<void> updateClassNote({
    required String docId,
    required File file,
    required String filename,
    required String sectionTitle,
    required int sectionOrder,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/raw/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
    final multipartFile = await http.MultipartFile.fromPath('file', file.path, filename: filename);
    request.files.add(multipartFile);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update upload: ${response.statusCode} ${response.reasonPhrase}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String? ?? body['url'] as String? ?? '';
    final publicId = body['public_id'] as String? ?? '';

    await _firestore.collection('class_notes').doc(docId).update({
      'filename': filename,
      'url': url,
      'publicId': publicId,
      'uploadedAt': DateTime.now().millisecondsSinceEpoch,
      'sectionTitle': sectionTitle,
      'sectionOrder': sectionOrder,
    });
  }

  /// Returns cached file if exists, otherwise downloads & caches
  Future<File> getOrDownloadFile({
    required String url,
    required String localFilename,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, localFilename);
    final f = File(filePath);

    if (await f.exists()) {
      return f;
    }

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('Failed to download file: ${res.statusCode}');
    await f.writeAsBytes(res.bodyBytes);
    return f;
  }

  Future<void> removeCachedFile(String localFilename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, localFilename);
    final f = File(filePath);
    if (await f.exists()) await f.delete();
  }
}
