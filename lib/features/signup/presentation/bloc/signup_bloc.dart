import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_signup_progress.dart';
import '../../domain/usecases/save_signup_step.dart';
import '../../domain/usecases/submit_signup_data.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SaveSignupStepUseCase saveSignupStep;
  final GetSignupProgressUseCase getSignupProgress;
  final SubmitSignupDataUseCase submitSignupData;

  SignupBloc({
    required this.saveSignupStep,
    required this.getSignupProgress,
    required this.submitSignupData,
  }) : super(SignupInitial()) {
    on<LoadSignupProgressEvent>(_onLoadSignupProgress);
    on<SavePersonalInfoEvent>(_onSavePersonalInfo);
    on<SavePreferencesEvent>(_onSavePreferences);
    on<SaveDemographicsEvent>(_onSaveDemographics);
    on<SaveInterestsEvent>(_onSaveInterests);
    on<SaveAccountSettingsEvent>(_onSaveAccountSettings);
    on<NavigateToStepEvent>(_onNavigateToStep);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<SubmitSignupDataEvent>(_onSubmitSignupData);
    on<ClearSignupDataEvent>(_onClearSignupData);
  }

  Future<void> _onLoadSignupProgress(
    LoadSignupProgressEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final result = await getSignupProgress();

    result.fold(
      (failure) => emit(SignupError(message: failure.message)),
      (signupData) => emit(SignupLoaded(signupData: signupData)),
    );
  }

  Future<void> _onSavePersonalInfo(
    SavePersonalInfoEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final personalInfoData = {
      'firstName': event.personalInfo.firstName,
      'lastName': event.personalInfo.lastName,
      'phoneNumber': event.personalInfo.phoneNumber,
      'dateOfBirth': event.personalInfo.dateOfBirth?.toIso8601String(),
      'gender': event.personalInfo.gender,
    };

    final result = await saveSignupStep('personal_info', personalInfoData);

    await result.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (_) async {
        final progressResult = await getSignupProgress();
        progressResult.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (signupData) => emit(
            SignupStepSaved(
              signupData: signupData,
              message: 'Personal information saved successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSavePreferences(
    SavePreferencesEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final preferencesData = {
      'emailNotifications': event.preferences.emailNotifications,
      'pushNotifications': event.preferences.pushNotifications,
      'theme': event.preferences.theme,
      'language': event.preferences.language,
      'interests': event.preferences.interests,
    };

    final result = await saveSignupStep('preferences', preferencesData);

    await result.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (_) async {
        final progressResult = await getSignupProgress();
        progressResult.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (signupData) => emit(
            SignupStepSaved(
              signupData: signupData,
              message: 'Preferences saved successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSaveDemographics(
    SaveDemographicsEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final demographicsData = {
      'country': event.demographics.country,
      'city': event.demographics.city,
      'occupation': event.demographics.occupation,
      'education': event.demographics.education,
      'ageRange': event.demographics.ageRange,
    };

    final result = await saveSignupStep('demographics', demographicsData);

    await result.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (_) async {
        final progressResult = await getSignupProgress();
        progressResult.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (signupData) => emit(
            SignupStepSaved(
              signupData: signupData,
              message: 'Demographics saved successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSaveInterests(
    SaveInterestsEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final interestsData = {
      'categories': event.interests.categories,
      'hobbies': event.interests.hobbies,
      'skills': event.interests.skills,
    };

    final result = await saveSignupStep('interests', interestsData);

    await result.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (_) async {
        final progressResult = await getSignupProgress();
        progressResult.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (signupData) => emit(
            SignupStepSaved(
              signupData: signupData,
              message: 'Interests saved successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSaveAccountSettings(
    SaveAccountSettingsEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    final accountSettingsData = {
      'isProfilePublic': event.accountSettings.isProfilePublic,
      'allowDataCollection': event.accountSettings.allowDataCollection,
      'enableTwoFactor': event.accountSettings.enableTwoFactor,
      'privacyLevel': event.accountSettings.privacyLevel,
    };

    final result = await saveSignupStep(
      'account_settings',
      accountSettingsData,
    );

    await result.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (_) async {
        final progressResult = await getSignupProgress();
        progressResult.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (signupData) => emit(
            SignupStepSaved(
              signupData: signupData,
              message: 'Account settings saved successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onNavigateToStep(
    NavigateToStepEvent event,
    Emitter<SignupState> emit,
  ) async {
    final progressResult = await getSignupProgress();

    progressResult.fold(
      (failure) => emit(SignupError(message: failure.message)),
      (signupData) {
        final updatedData = signupData.copyWith(currentStep: event.step);
        emit(SignupNavigated(signupData: updatedData, currentStep: event.step));
      },
    );
  }

  Future<void> _onNextStep(
    NextStepEvent event,
    Emitter<SignupState> emit,
  ) async {
    final progressResult = await getSignupProgress();

    progressResult.fold(
      (failure) => emit(SignupError(message: failure.message)),
      (signupData) {
        final nextStep = signupData.currentStep + 1;
        if (nextStep <= 5) {
          // Maximum 6 steps (0-5)
          final updatedData = signupData.copyWith(currentStep: nextStep);
          emit(SignupNavigated(signupData: updatedData, currentStep: nextStep));
        }
      },
    );
  }

  Future<void> _onPreviousStep(
    PreviousStepEvent event,
    Emitter<SignupState> emit,
  ) async {
    final progressResult = await getSignupProgress();

    progressResult.fold(
      (failure) => emit(SignupError(message: failure.message)),
      (signupData) {
        final previousStep = signupData.currentStep - 1;
        if (previousStep >= 0) {
          final updatedData = signupData.copyWith(currentStep: previousStep);
          emit(
            SignupNavigated(signupData: updatedData, currentStep: previousStep),
          );
        }
      },
    );
  }

  Future<void> _onSubmitSignupData(
    SubmitSignupDataEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupSubmissionLoading());

    final progressResult = await getSignupProgress();

    await progressResult.fold(
      (failure) async => emit(SignupError(message: failure.message)),
      (signupData) async {
        if (!signupData.hasAllRequiredData) {
          emit(
            const SignupError(message: 'Please complete all required steps'),
          );
          return;
        }

        final result = await submitSignupData(signupData);

        result.fold(
          (failure) => emit(SignupError(message: failure.message)),
          (_) => emit(
            const SignupSubmissionSuccess(
              message: 'Signup completed successfully!',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onClearSignupData(
    ClearSignupDataEvent event,
    Emitter<SignupState> emit,
  ) async {
    // In a real implementation, you would call a clear data use case
    emit(SignupCleared());
    emit(SignupInitial());
  }
}
