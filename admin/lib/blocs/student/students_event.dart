part of 'students_bloc.dart';

abstract class StudentsEvent {}

class LoadStudents extends StudentsEvent {}

class StudentUpdated extends StudentsEvent {
  final List<MapEntry<String, Student>> students; // docId + Student
  StudentUpdated(this.students);
}

class AddStudent extends StudentsEvent {
  final String name;
  final String email;
  final String password;
  AddStudent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class DeleteStudent extends StudentsEvent {
  final String studentDocId;
  DeleteStudent(this.studentDocId);
}