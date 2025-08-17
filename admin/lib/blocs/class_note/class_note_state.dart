part of 'class_note_bloc.dart';

abstract class ClassNotesEvent {}
class LoadClassNotes extends ClassNotesEvent {
  final String classId;
  LoadClassNotes(this.classId);
}
class UploadClassNoteEvent extends ClassNotesEvent {
  final String classId;
  final File file;
  final String filename;
  UploadClassNoteEvent({required this.classId, required this.file, required this.filename});
}
class DeleteClassNoteEvent extends ClassNotesEvent {
  final String docId;
  final String publicId;
  final String localFilename; // used to remove cache
  DeleteClassNoteEvent({required this.docId, required this.publicId, required this.localFilename});
}
class UpdateClassNoteEvent extends ClassNotesEvent {
  final String docId;
  final File file;
  final String filename;
  final String localFilenameToRemove;
  UpdateClassNoteEvent({required this.docId, required this.file, required this.filename, required this.localFilenameToRemove});
}