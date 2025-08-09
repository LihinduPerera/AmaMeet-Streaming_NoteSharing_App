import 'package:equatable/equatable.dart';

class Classroom extends Equatable {
  final String id;
  final String name;
  final int year;
  final int createdAt;

  const Classroom({
    required this.id,
    required this.name,
    required this.year,
    required this.createdAt,
  });

  factory Classroom.fromMap(Map<dynamic, dynamic> m) {
    return Classroom(
      id: m['id'] ?? '',
      name: m['name'] ?? '',
      year: m['year'] ?? 0,
      createdAt: m['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'year': year,
    'createdAt': createdAt,
  };

  @override
  List<Object?> get props => [id, name, year, createdAt];
}