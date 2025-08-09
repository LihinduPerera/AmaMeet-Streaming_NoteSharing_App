import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();
  @override
  List<Object?> get props =>  [];
}

class AuthCheckRequested extends AuthEvent{}
class AuthSignId extends AuthEvent {}
class AuthSignedOut extends AuthEvent {}
