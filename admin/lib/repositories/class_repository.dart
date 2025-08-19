import 'package:ama_meet_admin/models/classroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addClass(ClassRoom cr) async {
    final docRef = _firestore.collection('classes').doc(cr.id);
    await docRef.set(cr.toMap());
  }

  Future<void> deleteClass(String classId) async{
    //Delete class doc
    await _firestore.collection('classes').doc(classId).delete();

    // Delete all students of the class
    final querySnap = await _firestore.collection('students').where('classId', isEqualTo: classId).get();
    final batch = _firestore.batch();
    for(final doc in querySnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    //Delete counter
    await _firestore.collection('counters').doc(classId).delete();
  }

  Stream<List<ClassRoom>> classStream() {
    return _firestore.collection('classes').snapshots().map((snap) =>
      snap.docs.map((doc) => ClassRoom.fromMap(doc.data())).toList());
  }
}