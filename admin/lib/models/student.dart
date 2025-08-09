import 'package:equatable/equatable.dart';

class Student extends Equatable{
  final String id;
  final String classId;
  final String name;
  final String email;
  final String passwordHash;
  final int createdAt;

  const Student({
    required this.id,
    required this.classId,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  factory Student.fromMap(Map<dynamic, dynamic> m) {
    return Student(
      id: m['id'] ?? '',
      classId: m['classId'] ?? '',
      name: m['name'] ?? '',
      email: m['email']  ?? '',
      passwordHash: m['passwordHash'] ?? '',
      createdAt: m["createdAt"] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, classId, name, email, passwordHash, createdAt];
}