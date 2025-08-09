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

  @override
  List<Object?> get props => [id, name, year, createdAt];
}