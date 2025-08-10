import 'package:ama_meet/models/student.dart';
import 'package:ama_meet/repositories/student_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final StudentRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {

    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      final student = await repo.getSavedStudent();
      if (student != null) {
        emit(AuthAuthenticated(student));
      } else {
        emit(AuthLoggedOut());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final student = await repo.loginWithIdOrEmail(event.idOrEmail, event.password);
      if (student != null) {
        emit(AuthAuthenticated(student));
      } else {
        emit(AuthFailier("Invalid ID/Email or password"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repo.logout();
      emit(AuthLoggedOut());
    });
  }
}