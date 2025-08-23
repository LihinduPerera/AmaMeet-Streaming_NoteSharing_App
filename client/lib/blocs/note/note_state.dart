part of 'note_bloc.dart';

abstract class NoteState {}
class NotesInitial extends NoteState {}
class NotesLoading extends NoteState {}
class NotesLoaded extends NoteState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}
class NotesError extends NoteState {
  final String message;
  NotesError(this.message);
}