import 'package:ama_meet_admin/models/classroom.dart';
import 'package:ama_meet_admin/models/student.dart';
import 'package:ama_meet_admin/utils/hash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Firebase Auth for admin
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();
  User? get currentUser => _auth.currentUser;

  //Classes
  Future<void> addClass(ClassRoom cr) async {
    final docRef = _firestore.collection('classes').doc(cr.id);
    await docRef.set(cr.toMap());
  }

  Future<void> deleteClass(String cId) async{
    //Delete class doc
    await _firestore.collection('classes').doc(cId).delete();

    // Delete all students of the class
    final querySnap = await _firestore.collection('students').where('clssId', isEqualTo: cId).get();
    final batch = _firestore.batch();
    for(final doc in querySnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    //Delete counter
    await _firestore.collection('counters').doc(cId).delete();
  }

  Stream<List<ClassRoom>> classStream() {
    return _firestore.collection('classes').snapshots().map((snap) =>
      snap.docs.map((doc) => ClassRoom.fromMap(doc.data())).toList());
  }

  //Students
  // Future<void> addStudent(Student st) async{
  //   //auto Id for now
  //   await _firestore.collection('students').add(st.toMap());
  // }

  // Add students with auto gen ID
  Future<void> addStudent({
    required String classId,
    required String name,
    required String email,
    required String password,
  }) async {
    final studentId = await _generateStudentId(classId);
    final passwordHash = sha256Hash(password);
    final student = Student(
      id: studentId,
      classId: classId,
      name: name,
      email: email,
      passwordHash: passwordHash,
      createdAt: DateTime.now().millisecondsSinceEpoch
    );

    await _firestore.collection('students').add(student.toMap());
  }

  Stream<List<MapEntry<String, Student>>> studentsStreamForClass(String classId) {
    // Return list of MapEntry(docId, Student)
    return _firestore
        .collection('students')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MapEntry(doc.id, Student.fromMap(doc.data()))).toList());
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