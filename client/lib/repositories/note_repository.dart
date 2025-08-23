import 'dart:io';

import 'package:ama_meet/models/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoteModel>> notesStreamForClass(String classId) {
    return _firestore
        .collection('class_notes')
        .where('classId', isEqualTo: classId)
        .orderBy('sectionOrder', descending: false)
        .orderBy('uploadedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoteModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

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
    if (res.statusCode != 200) throw Exception('Failed to download file : ${res.statusCode}');
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