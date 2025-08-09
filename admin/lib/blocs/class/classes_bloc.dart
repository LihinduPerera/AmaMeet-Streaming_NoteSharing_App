import 'package:ama_meet_admin/models/classroom.dart';
import 'package:ama_meet_admin/repositories/admin_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'classes_event.dart';
part 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final AdminRepository repo;
  ClassesBloc(this.repo) : super(ClassesLoading()) {

    on<LoadClasses>((event, emit) {
      emit(ClassesLoading());
      repo.classStream().listen((classes){
        add(ClassesUpdated(classes));
      });
    });

    on<ClassesUpdated>((event, emit) {
      emit(ClassesLoaded(event.classes));
    });

    on<AddClass>((event, emit) async {
      try {
        await repo.addClass(event.classRoom);
      } catch (e) {
        emit(ClassesError(e.toString()));
      }
    });

    on<DeleteClass>((event, emit) async {
      try {
        await repo.deleteClass(event.classId);
      } catch (e) {
        emit(ClassesError(e.toString()));
      }
    });
  }
}