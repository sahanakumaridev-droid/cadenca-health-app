import 'package:equatable/equatable.dart';

import '../../domain/entities/signup_data.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupLoaded extends SignupState {
  final SignupData signupData;

  const SignupLoaded({required this.signupData});

  @override
  List<Object> get props => [signupData];
}

class SignupStepSaved extends SignupState {
  final SignupData signupData;
  final String message;

  const SignupStepSaved({required this.signupData, required this.message});

  @override
  List<Object> get props => [signupData, message];
}

class SignupNavigated extends SignupState {
  final SignupData signupData;
  final int currentStep;

  const SignupNavigated({required this.signupData, required this.currentStep});

  @override
  List<Object> get props => [signupData, currentStep];
}

class SignupSubmissionLoading extends SignupState {}

class SignupSubmissionSuccess extends SignupState {
  final String message;

  const SignupSubmissionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SignupError extends SignupState {
  final String message;

  const SignupError({required this.message});

  @override
  List<Object> get props => [message];
}

class SignupCleared extends SignupState {}
