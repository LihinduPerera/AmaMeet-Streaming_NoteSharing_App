import 'dart:async';
import 'dart:io';

import 'package:ama_meet_admin/models/note_model.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'class_note_event.dart';
part 'class_note_state.dart';

class ClassNotesBloc extends Bloc<ClassNotesEvent, ClassNotesState> {
  final ClassNoteRepository _repo;
  StreamSubscription<List<NoteModel>>? _notesSub;

  ClassNotesBloc(this._repo) : super(ClassNotesInitial()) {
    on<LoadClassNotes>(_onLoad);
    on<UploadClassNoteEvent>(_onUpload);
    on<DeleteClassNoteEvent>(_onDelete);
    on<UpdateClassNoteEvent>(_onUpdate);
    on<_ClassNotesUpdated>((event, emit) => emit(ClassNotesLoaded(event.notes)));
    on<_ClassNotesError>((event, emit) => emit(ClassNotesError(event.message)));
  }

  Future<void> _onLoad(LoadClassNotes event, Emitter emit) async {
    emit(ClassNotesLoading());
    await _notesSub?.cancel();
    _notesSub = _repo.notesStreamForClass(event.classId).listen(
      (notes) => add(_ClassNotesUpdated(notes)),
      onError: (e) => add(_ClassNotesError(e.toString())),
    );
  }

  Future<void> _onUpload(UploadClassNoteEvent e, Emitter emit) async {
    try {
      await _repo.uploadClassNote(
        classId: e.classId,
        file: e.file,
        filename: e.filename,
        sectionTitle: e.sectionTitle,
        sectionOrder: e.sectionOrder,
      );
      // Firestore stream will update UI
    } catch (err) {
      emit(ClassNotesError(err.toString()));
    }
  }

  Future<void> _onDelete(DeleteClassNoteEvent e, Emitter emit) async {
    try {
      await _repo.deleteClassNote(docId: e.docId, publicId: e.publicId);
      await _repo.removeCachedFile(e.localFilename);
    } catch (err) {
      emit(ClassNotesError(err.toString()));
    }
  }

  Future<void> _onUpdate(UpdateClassNoteEvent e, Emitter emit) async {
    try {
      await _repo.updateClassNote(
        docId: e.docId,
        file: e.file,
        filename: e.filename,
        sectionTitle: e.sectionTitle,
        sectionOrder: e.sectionOrder,
      );
      await _repo.removeCachedFile(e.localFilenameToRemove);
    } catch (err) {
      emit(ClassNotesError(err.toString()));
    }
  }

  @override
  Future<void> close() {
    _notesSub?.cancel();
    return super.close();
  }
}

// Internal events used only inside the bloc
class _ClassNotesUpdated extends ClassNotesEvent {
  final List<NoteModel> notes;
  _ClassNotesUpdated(this.notes);
}

class _ClassNotesError extends ClassNotesEvent {
  final String message;
  _ClassNotesError(this.message);
}