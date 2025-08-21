part of 'students_bloc.dart';

abstract class StudentsState {}

class StudentsLoading extends StudentsState {}

class StudentsLoaded extends StudentsState {
  final List<MapEntry<String, StudentModel>> students; // docId + Student
  StudentsLoaded(this.students);
}

class StudentsError extends StudentsState {
  final String message;
  StudentsError(this.message);
}