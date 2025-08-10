part of 'auth_bloc.dart';

abstract class AuthState extends Equatable{
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final Student student;
  AuthAuthenticated(this.student);

  @override
  List<Object?> get props => [student];
}
class AuthFailier extends AuthState {
  final String message;
  AuthFailier(this.message);

  @override
  List<Object?> get props => [message];
}
class AuthLoggedOut extends AuthState {}