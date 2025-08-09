import 'package:equatable/equatable.dart';

class ClassRoom extends Equatable {
  final String id;
  final String name;
  final int year;
  final int createdAt;

  const ClassRoom({
    required this.id,
    required this.name,
    required this.year,
    required this.createdAt,
  });

  factory ClassRoom.fromMap(Map<dynamic, dynamic> m) {
    return ClassRoom(
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