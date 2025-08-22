import 'package:ama_meet/models/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoteModel>> notesStreamForClass(String classId) {
    return _firestore
        .collection('class_notes')
        .where('classId', isEqualTo: classId)
        .orderBy('sectionOrder', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoteModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }
}