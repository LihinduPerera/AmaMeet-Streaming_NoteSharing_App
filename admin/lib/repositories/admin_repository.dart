import 'package:ama_meet_admin/models/classroom.dart';
import 'package:ama_meet_admin/models/student.dart';
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
  }

  //Students
  Future<void> addStudent(Student st) async{
    //auto Id for now
    await _firestore.collection('students').add(st.toMap());
  }

  Stream<List<Student>> studentStreamForClass(String cId) {
    return _firestore.collection('students')
      .where('classId', isEqualTo: cId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Student.fromMap(doc.data())).toList());
  }

  // Delete using doc id for now
  Future<void> deleteStudentByDocId(String docId) async {
    await _firestore.collection('students').doc(docId).delete();
  }
}