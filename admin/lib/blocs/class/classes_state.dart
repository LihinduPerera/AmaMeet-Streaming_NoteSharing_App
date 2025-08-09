part of 'classes_bloc.dart';

import 'package:ama_meet_admin/models/classroom.dart';

abstract class ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassRoom> classes;
  ClassesLoaded(this.classes);
}

class ClassesError extends ClassesState {
  final String message;
  ClassesError(this.message);
}