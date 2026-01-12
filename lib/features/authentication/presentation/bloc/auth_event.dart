import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class GoogleSignInEvent extends AuthEvent {}

class AppleSignInEvent extends AuthEvent {}

class FacebookSignInEvent extends AuthEvent {}

class EmailSignInEvent extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class EmailSignUpEvent extends AuthEvent {
  final String email;
  final String password;

  const EmailSignUpEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class VerifyEmailEvent extends AuthEvent {
  final String email;

  const VerifyEmailEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class SignOutEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}
