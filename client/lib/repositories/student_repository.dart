import 'package:ama_meet/models/student.dart';
import 'package:ama_meet/utils/hash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  Future<Student?> loginWithIdOrEmail(String idOrEmail, String password) async {
    final hash = sha256Hash(password);

    final querySnap = await _firestore
        .collection('students')
        .where('id', isEqualTo: idOrEmail)
        .get();

    QuerySnapshot<Map<String, dynamic>> result = querySnap;

    // If not found by ID, try email
    if (result.docs.isEmpty) {
      result = await _firestore
          .collection('students')
          .where('email', isEqualTo: idOrEmail)
          .get();
    }

    if (result.docs.isEmpty) return null;

    final student = Student.fromMap(result.docs.first.data());
    if (student.passwordHash != hash) return null;

    await _storage.write(key: 'student', value: student.toMap().toString());
    return student;
  }

  Future<Student?> getSavedStudent() async {
    final data = await _storage.read(key: 'student');
    if (data == null) return null;

    final map = _stringToMap(data);
    return Student.fromMap(map);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'student');
  }

  Map<String, dynamic> _stringToMap(String str) {
    str = str.replaceAll(RegExp(r'^{|}$'), '');
    final Map<String, dynamic> map = {};
    for (var pair in str.split(', ')) {
      final kv = pair.split(': ');
      if (kv.length == 2) {
        map[kv[0]] = kv[1];
      }
    }
    return map;
  }
}
