import 'package:ama_meet_admin/models/class_model.dart';
import 'package:ama_meet_admin/repositories/class_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'classes_event.dart';
part 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final ClassRepository clsRepo;
  ClassesBloc(this.clsRepo) : super(ClassesLoading()) {

    on<LoadClasses>((event, emit) {
      emit(ClassesLoading());
      clsRepo.classStream().listen((classes){
        add(ClassesUpdated(classes));
      });
    });

    on<ClassesUpdated>((event, emit) {
      emit(ClassesLoaded(event.classes));
    });

    on<AddClass>((event, emit) async {
      try {
        await clsRepo.addClass(event.classRoom);
      } catch (e) {
        emit(ClassesError(e.toString()));
      }
    });

    on<DeleteClass>((event, emit) async {
      try {
        await clsRepo.deleteClass(event.classId);
      } catch (e) {
        emit(ClassesError(e.toString()));
      }
    });
  }
}