import 'package:ama_meet_admin/repositories/admin_auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AdminAuthRepository adminRepository;

  AuthBloc({
    required this.adminRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) {
      final user = adminRepository.currentUser;
      if (user != null) emit(Authenticated(user));
      else emit(Unauthenticated());
    });

    on<LoginRequested>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await adminRepository.signIn(event.email, event.password);
        if (user != null) emit(Authenticated(user));
        else emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<GoogleLoginRequested>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await adminRepository.signInWithGoogle();
        if (user != null) emit(Authenticated(user));
        else emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignedOut>((event, emit) async {
      await adminRepository.signOut();
      emit(Unauthenticated());
    });
  }
}
