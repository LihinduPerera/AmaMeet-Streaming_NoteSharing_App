import 'package:equatable/equatable.dart';

class Student extends Equatable {
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
    int createdAtValue = 0;
    final createdAtRaw = m["createdAt"];
    if (createdAtRaw is int) {
      createdAtValue = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAtValue = int.tryParse(createdAtRaw) ?? 0;
    }

    return Student(
      id: m['id'] ?? '',
      classId: m['classId'] ?? '',
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      passwordHash: m['passwordHash'] ?? '',
      createdAt: createdAtValue,
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
