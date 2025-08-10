import 'dart:convert';
import 'package:ama_meet/models/student.dart';
import 'package:ama_meet/utils/hash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  Future<Student?> loginWithIdOrEmail(String idOrEmail, String password) async {
    try {
      final hash = sha256Hash(password);

      var querySnap = await _firestore
          .collection('students')
          .where('id', isEqualTo: idOrEmail)
          .get();

      if (querySnap.docs.isEmpty) {
        querySnap = await _firestore
            .collection('students')
            .where('email', isEqualTo: idOrEmail)
            .get();
      }

      if (querySnap.docs.isEmpty) {
        throw Exception("Student not found with ID/Email: $idOrEmail");
      }

      final student = Student.fromMap(querySnap.docs.first.data());
      if (student.passwordHash != hash) {
        throw Exception("Incorrect password.");
      }

      // Store JSON string, not just .toString()
      await _storage.write(key: 'student', value: jsonEncode(student.toMap()));
      return student;
    } catch (e) {
      throw Exception("Login error: ${e.toString()}");
    }
  }

  Future<Student?> getSavedStudent() async {
    try {
      final data = await _storage.read(key: 'student');
      if (data == null) return null;

      // Parse JSON string back to Map
      final map = jsonDecode(data) as Map<String, dynamic>;
      return Student.fromMap(map);
    } catch (e) {
      throw Exception("Failed to fetch saved student: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'student');
    } catch (e) {
      throw Exception("Failed to log out: ${e.toString()}");
    }
  }
}
