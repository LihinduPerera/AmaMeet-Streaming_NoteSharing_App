import 'package:equatable/equatable.dart';

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String idOrEmail;
  final String password;

  LoginRequested({required this.idOrEmail, required this.password});

  @override
  List<Object?> get props => [idOrEmail, password];
}

class LogoutRequested extends AuthEvent {}