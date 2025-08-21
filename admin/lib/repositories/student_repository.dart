import 'package:ama_meet_admin/models/student_model.dart';
import 'package:ama_meet_admin/utils/hash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> addStudent({
    required String classId,
    required String name,
    required String email,
    required String password,
  }) async {
    final studentId = await _generateStudentId(classId);
    final passwordHash = sha256Hash(password);
    final student = StudentModel(
      id: studentId,
      classId: classId,
      name: name,
      email: email,
      passwordHash: passwordHash,
      createdAt: DateTime.now().millisecondsSinceEpoch
    );

    await _firestore.collection('students').add(student.toMap());
  }

  Stream<List<MapEntry<String, StudentModel>>> studentsStreamForClass(String classId) {
    // Return list of MapEntry(docId, Student)
    return _firestore
        .collection('students')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MapEntry(doc.id, StudentModel.fromMap(doc.data()))).toList());
  }

  // Delete using doc id for now
  Future<void> deleteStudentByDocId(String docId) async {
    await _firestore.collection('students').doc(docId).delete();
  }

  Future<String> _generateStudentId(String classID) async {
    final counterRef = _firestore.collection('counters').doc(classID);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      int nextIndex = 1;

      if (snapshot.exists && snapshot.data()!.containsKey('nextIndex')) {
        nextIndex = (snapshot.data()!['nextIndex'] as int) + 1;
      }

      transaction.set(counterRef, {'nextIndex': nextIndex});
      return '$classID-${nextIndex.toString().padLeft(3, '0')}';
    });
  }
}