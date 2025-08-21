part of 'class_note_bloc.dart';

abstract class ClassNotesState {}
class ClassNotesInitial extends ClassNotesState {}
class ClassNotesLoading extends ClassNotesState {}
class ClassNotesLoaded extends ClassNotesState {
  final List<NoteModel> notes;
  ClassNotesLoaded(this.notes);
}
class ClassNotesError extends ClassNotesState {
  final String message;
  ClassNotesError(this.message);
}