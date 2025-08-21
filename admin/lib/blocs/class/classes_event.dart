part of 'classes_bloc.dart';

abstract class ClassesEvent {}

class LoadClasses extends ClassesEvent {}

class ClassesUpdated extends ClassesEvent {
  final List<ClassModel> classes;
  ClassesUpdated(this.classes);
}

class AddClass extends ClassesEvent {
  final ClassModel classRoom;
  AddClass(this.classRoom);
}

class DeleteClass extends ClassesEvent {
  final String classId;
  DeleteClass(this.classId);
}