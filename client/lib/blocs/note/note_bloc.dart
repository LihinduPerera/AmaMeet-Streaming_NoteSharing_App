import 'dart:async';

import 'package:ama_meet/models/note_model.dart';
import 'package:ama_meet/repositories/note_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState>{
  final NoteRepository _repo;
  StreamSubscription<List<NoteModel>>? _notesSub;

  NoteBloc(this._repo) : super(NotesInitial()) {
    on<LoadNotes>(_onLoad);
    on<_NotesUpdated>((event, emit) => emit(NotesLoaded(event.notes)));
    on<_NotesError>((event, emit) => (NotesError(event.message)));
  }

  Future<void> _onLoad(LoadNotes event, Emitter emit) async {
    emit(NotesLoading());
    await _notesSub?.cancel();
    _notesSub = _repo.notesStreamForClass(event.classId).listen(
      (notes) => add(_NotesUpdated(notes)),
      onError: (e) => add(_NotesError(e.toString())),
    );
  }
}

// Internal events used only inside the bloc
class _NotesUpdated extends NoteEvent {
  final List<NoteModel> notes;
  _NotesUpdated(this.notes);
}

class _NotesError extends NoteEvent {
  final String message;
  _NotesError(this.message);
}