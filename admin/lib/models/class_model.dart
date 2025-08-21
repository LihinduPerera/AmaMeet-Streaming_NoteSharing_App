import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String name;
  final int year;
  final int createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.year,
    required this.createdAt,
  });

  factory ClassModel.fromMap(Map<dynamic, dynamic> m) {
    return ClassModel(
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