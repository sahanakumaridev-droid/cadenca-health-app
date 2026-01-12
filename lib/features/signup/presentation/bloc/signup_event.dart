import 'package:equatable/equatable.dart';

import '../../domain/entities/signup_data.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class LoadSignupProgressEvent extends SignupEvent {}

class SavePersonalInfoEvent extends SignupEvent {
  final PersonalInfo personalInfo;

  const SavePersonalInfoEvent({required this.personalInfo});

  @override
  List<Object> get props => [personalInfo];
}

class SavePreferencesEvent extends SignupEvent {
  final Preferences preferences;

  const SavePreferencesEvent({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class SaveDemographicsEvent extends SignupEvent {
  final Demographics demographics;

  const SaveDemographicsEvent({required this.demographics});

  @override
  List<Object> get props => [demographics];
}

class SaveInterestsEvent extends SignupEvent {
  final Interests interests;

  const SaveInterestsEvent({required this.interests});

  @override
  List<Object> get props => [interests];
}

class SaveAccountSettingsEvent extends SignupEvent {
  final AccountSettings accountSettings;

  const SaveAccountSettingsEvent({required this.accountSettings});

  @override
  List<Object> get props => [accountSettings];
}

class NavigateToStepEvent extends SignupEvent {
  final int step;

  const NavigateToStepEvent({required this.step});

  @override
  List<Object> get props => [step];
}

class NextStepEvent extends SignupEvent {}

class PreviousStepEvent extends SignupEvent {}

class SubmitSignupDataEvent extends SignupEvent {}

class ClearSignupDataEvent extends SignupEvent {}
