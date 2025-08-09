part of 'classes_bloc.dart';

import 'package:ama_meet_admin/models/classroom.dart';

abstract class ClassesEvent {}

class LoadClasses extends ClassesEvent {}

class ClassesUpdated extends ClassesEvent {
  final List<ClassRoom> classes;
  ClassesUpdated(this.classes);
}

class AddClass extends ClassesEvent {
  final ClassRoom classRoom;
  AddClass(this.classRoom);
}

class DeleteClass extends ClassesEvent {
  final String classId;
  DeleteClass(this.classId);
}