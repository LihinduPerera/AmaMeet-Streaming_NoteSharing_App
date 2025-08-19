import 'package:ama_meet_admin/models/student.dart';
import 'package:ama_meet_admin/repositories/student_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'students_event.dart';
part 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState>{
  final StudentRepository repo;
  final String classId;

  StudentsBloc(this.repo, this.classId) : super(StudentsLoading()) {

    on<LoadStudents>((event, emit) {
      emit(StudentsLoading());
      repo.studentsStreamForClass(classId).listen((students){
        add(StudentUpdated(students));
      });
    });

    on<StudentUpdated>((event, emit) {
      emit(StudentsLoaded(event.students));
    });

    on<AddStudent>((event, emit) async {
      try {
        await repo.addStudent(
          classId: classId,
          name: event.name,
          email: event.email,
          password: event.password,
        );
      } catch (e) {
        emit(StudentsError(e.toString()));
      }
    });

    on<DeleteStudent>((event, emit) async {
      try {
        await repo.deleteStudentByDocId(event.studentDocId);
      } catch (e) {
        emit(StudentsError(e.toString()));
      }
    });
  }
}