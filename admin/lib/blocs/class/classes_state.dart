part of 'classes_bloc.dart';

abstract class ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;
  ClassesLoaded(this.classes);
}

class ClassesError extends ClassesState {
  final String message;
  ClassesError(this.message);
}