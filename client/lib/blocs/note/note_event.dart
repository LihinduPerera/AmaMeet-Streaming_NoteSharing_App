part of 'note_bloc.dart';

abstract class NoteEvent {}

class LoadNotes extends NoteEvent {
  final String classId;
  LoadNotes(this.classId);
}