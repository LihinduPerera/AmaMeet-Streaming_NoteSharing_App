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
      try {
        final student = await repo.getSavedStudent();
        if (student != null) {
          emit(AuthAuthenticated(student));
        } else {
          emit(AuthLoggedOut());
        }
      } catch (e) {
        emit(AuthFailure("Failed to fetch saved student: ${e.toString()}"));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final student = await repo.loginWithIdOrEmail(event.idOrEmail, event.password);
        if (student != null) {
          emit(AuthAuthenticated(student));
        } else {
          emit(AuthFailure("Invalid ID/Email or password"));
        }
      } catch (e) {
        emit(AuthFailure("Login failed: ${e.toString()}"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await repo.logout();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthFailure("Logout failed: ${e.toString()}"));
      }
    });
  }
}
