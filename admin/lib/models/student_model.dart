import 'package:equatable/equatable.dart';

class StudentModel extends Equatable{
  final String id;
  final String classId;
  final String name;
  final String email;
  final String passwordHash;
  final int createdAt;

  const StudentModel({
    required this.id,
    required this.classId,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  factory StudentModel.fromMap(Map<dynamic, dynamic> m) {
    return StudentModel(
      id: m['id'] ?? '',
      classId: m['classId'] ?? '',
      name: m['name'] ?? '',
      email: m['email']  ?? '',
      passwordHash: m['passwordHash'] ?? '',
      createdAt: m["createdAt"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'classId': classId,
    'name': name,
    'email': email,
    'passwordHash': passwordHash,
    'createdAt': createdAt,
  };

  @override
  List<Object?> get props => [id, classId, name, email, passwordHash, createdAt];
}