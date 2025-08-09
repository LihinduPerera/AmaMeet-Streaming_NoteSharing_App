part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();
  @override
  List<Object?> get props =>  [];
}

class AuthCheckRequested extends AuthEvent{}

class AuthSignedIn extends AuthEvent {
  final String email, password;
  AuthSignedIn(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignedOut extends AuthEvent {}
