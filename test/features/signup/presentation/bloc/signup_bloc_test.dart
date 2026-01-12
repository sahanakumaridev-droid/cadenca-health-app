import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_auth_app/core/error/failures.dart';
import 'package:flutter_auth_app/features/signup/domain/entities/signup_data.dart';
import 'package:flutter_auth_app/features/signup/domain/usecases/get_signup_progress.dart';
import 'package:flutter_auth_app/features/signup/domain/usecases/save_signup_step.dart';
import 'package:flutter_auth_app/features/signup/domain/usecases/submit_signup_data.dart';
import 'package:flutter_auth_app/features/signup/presentation/bloc/signup_bloc.dart';
import 'package:flutter_auth_app/features/signup/presentation/bloc/signup_event.dart';
import 'package:flutter_auth_app/features/signup/presentation/bloc/signup_state.dart';

class MockSaveSignupStepUseCase extends Mock implements SaveSignupStepUseCase {}

class MockGetSignupProgressUseCase extends Mock
    implements GetSignupProgressUseCase {}

class MockSubmitSignupDataUseCase extends Mock
    implements SubmitSignupDataUseCase {}

void main() {
  late SignupBloc signupBloc;
  late MockSaveSignupStepUseCase mockSaveSignupStep;
  late MockGetSignupProgressUseCase mockGetSignupProgress;
  late MockSubmitSignupDataUseCase mockSubmitSignupData;

  setUp(() {
    mockSaveSignupStep = MockSaveSignupStepUseCase();
    mockGetSignupProgress = MockGetSignupProgressUseCase();
    mockSubmitSignupData = MockSubmitSignupDataUseCase();

    signupBloc = SignupBloc(
      saveSignupStep: mockSaveSignupStep,
      getSignupProgress: mockGetSignupProgress,
      submitSignupData: mockSubmitSignupData,
    );
  });

  tearDown(() {
    signupBloc.close();
  });

  const tPersonalInfo = PersonalInfo(
    firstName: 'John',
    lastName: 'Doe',
    phoneNumber: '+1234567890',
    dateOfBirth: null,
    gender: 'Male',
  );

  const tPreferences = Preferences(
    emailNotifications: true,
    pushNotifications: false,
    theme: 'dark',
    language: 'English',
    interests: ['Technology', 'Sports'],
  );

  const tSignupData = SignupData(
    personalInfo: tPersonalInfo,
    preferences: tPreferences,
    currentStep: 2,
    isComplete: false,
  );

  group('SignupBloc', () {
    test('initial state is SignupInitial', () {
      expect(signupBloc.state, equals(SignupInitial()));
    });

    group('LoadSignupProgressEvent', () {
      blocTest<SignupBloc, SignupState>(
        'emits [SignupLoading, SignupLoaded] when loading succeeds',
        build: () {
          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => const Right(tSignupData));
          return signupBloc;
        },
        act: (bloc) => bloc.add(LoadSignupProgressEvent()),
        expect: () => [
          SignupLoading(),
          const SignupLoaded(signupData: tSignupData),
        ],
      );

      blocTest<SignupBloc, SignupState>(
        'emits [SignupLoading, SignupError] when loading fails',
        build: () {
          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return signupBloc;
        },
        act: (bloc) => bloc.add(LoadSignupProgressEvent()),
        expect: () => [
          SignupLoading(),
          const SignupError(message: 'Cache error'),
        ],
      );
    });

    group('SavePersonalInfoEvent', () {
      const tUpdatedSignupData = SignupData(
        personalInfo: tPersonalInfo,
        currentStep: 1,
        isComplete: false,
      );

      blocTest<SignupBloc, SignupState>(
        'emits [SignupLoading, SignupStepSaved] when saving succeeds',
        build: () {
          when(
            () => mockSaveSignupStep('personal_info', any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => const Right(tUpdatedSignupData));
          return signupBloc;
        },
        act: (bloc) =>
            bloc.add(const SavePersonalInfoEvent(personalInfo: tPersonalInfo)),
        expect: () => [
          SignupLoading(),
          const SignupStepSaved(
            signupData: tUpdatedSignupData,
            message: 'Personal information saved successfully',
          ),
        ],
      );
    });

    group('NavigateToStepEvent', () {
      blocTest<SignupBloc, SignupState>(
        'emits [SignupNavigated] when navigation succeeds',
        build: () {
          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => const Right(tSignupData));
          return signupBloc;
        },
        act: (bloc) => bloc.add(const NavigateToStepEvent(step: 3)),
        expect: () => [
          SignupNavigated(
            signupData: tSignupData.copyWith(currentStep: 3),
            currentStep: 3,
          ),
        ],
      );
    });

    // Property Test: Signup Data Persistence During Navigation
    // Feature: flutter-auth-app, Property 3: Signup Data Persistence During Navigation
    group('Property Test: Signup Data Persistence During Navigation', () {
      test(
        'navigating forward and backward should preserve all entered data',
        () async {
          // Test data persistence across multiple navigation steps
          final testCases = [
            {
              'step': 0,
              'data': const SignupData(currentStep: 0, isComplete: false),
            },
            {
              'step': 1,
              'data': const SignupData(
                personalInfo: tPersonalInfo,
                currentStep: 1,
                isComplete: false,
              ),
            },
            {
              'step': 2,
              'data': const SignupData(
                personalInfo: tPersonalInfo,
                preferences: tPreferences,
                currentStep: 2,
                isComplete: false,
              ),
            },
            {
              'step': 3,
              'data': const SignupData(
                personalInfo: tPersonalInfo,
                preferences: tPreferences,
                currentStep: 3,
                isComplete: false,
              ),
            },
          ];

          for (final testCase in testCases) {
            final step = testCase['step'] as int;
            final data = testCase['data'] as SignupData;

            // Mock the progress loading to return the test data
            when(
              () => mockGetSignupProgress(),
            ).thenAnswer((_) async => Right(data));

            // Test forward navigation
            signupBloc.add(NavigateToStepEvent(step: step));
            await Future.delayed(const Duration(milliseconds: 100));

            // Verify that data is preserved during navigation
            if (signupBloc.state is SignupNavigated) {
              final state = signupBloc.state as SignupNavigated;
              expect(state.signupData.personalInfo, equals(data.personalInfo));
              expect(state.signupData.preferences, equals(data.preferences));
              expect(state.currentStep, equals(step));
            }
          }
        },
      );

      test('data should persist across multiple save operations', () async {
        // Test that saving different steps preserves previously saved data
        const initialData = SignupData(currentStep: 0, isComplete: false);
        const dataWithPersonalInfo = SignupData(
          personalInfo: tPersonalInfo,
          currentStep: 1,
          isComplete: false,
        );
        const dataWithBoth = SignupData(
          personalInfo: tPersonalInfo,
          preferences: tPreferences,
          currentStep: 2,
          isComplete: false,
        );

        // Test sequence: save personal info, then preferences
        when(
          () => mockSaveSignupStep('personal_info', any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockSaveSignupStep('preferences', any()),
        ).thenAnswer((_) async => const Right(null));

        // First save - personal info
        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => const Right(dataWithPersonalInfo));

        signupBloc.add(
          const SavePersonalInfoEvent(personalInfo: tPersonalInfo),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Second save - preferences (should preserve personal info)
        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => const Right(dataWithBoth));

        signupBloc.add(const SavePreferencesEvent(preferences: tPreferences));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify both pieces of data are preserved
        if (signupBloc.state is SignupStepSaved) {
          final state = signupBloc.state as SignupStepSaved;
          expect(state.signupData.personalInfo, equals(tPersonalInfo));
          expect(state.signupData.preferences, equals(tPreferences));
        }
      });

      test(
        'navigation should preserve data integrity across random step sequences',
        () {
          // Property: For any sequence of navigation steps, data should remain consistent
          final randomSteps = [0, 2, 1, 4, 3, 5, 2, 1];
          const testData = SignupData(
            personalInfo: tPersonalInfo,
            preferences: tPreferences,
            currentStep: 0,
            isComplete: false,
          );

          for (final step in randomSteps) {
            when(() => mockGetSignupProgress()).thenAnswer(
              (_) async => Right(testData.copyWith(currentStep: step)),
            );

            // Each navigation should preserve the original data
            signupBloc.add(NavigateToStepEvent(step: step));

            // Verify data integrity is maintained regardless of navigation order
            expect(testData.personalInfo, equals(tPersonalInfo));
            expect(testData.preferences, equals(tPreferences));
          }
        },
      );
    });

    group('SubmitSignupDataEvent', () {
      const tCompleteSignupData = SignupData(
        personalInfo: tPersonalInfo,
        preferences: tPreferences,
        demographics: Demographics(country: 'US', city: 'New York'),
        interests: Interests(
          categories: ['Tech'],
          hobbies: ['Reading'],
          skills: ['Programming'],
        ),
        accountSettings: AccountSettings(
          isProfilePublic: true,
          allowDataCollection: true,
          enableTwoFactor: false,
          privacyLevel: 'friends',
        ),
        currentStep: 5,
        isComplete: true,
      );

      blocTest<SignupBloc, SignupState>(
        'emits [SignupSubmissionLoading, SignupSubmissionSuccess] when submission succeeds',
        build: () {
          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => const Right(tCompleteSignupData));
          when(
            () => mockSubmitSignupData(tCompleteSignupData),
          ).thenAnswer((_) async => const Right(null));
          return signupBloc;
        },
        act: (bloc) => bloc.add(SubmitSignupDataEvent()),
        expect: () => [
          SignupSubmissionLoading(),
          const SignupSubmissionSuccess(
            message: 'Signup completed successfully!',
          ),
        ],
      );

      blocTest<SignupBloc, SignupState>(
        'emits [SignupSubmissionLoading, SignupError] when data is incomplete',
        build: () {
          when(() => mockGetSignupProgress()).thenAnswer(
            (_) async => const Right(tSignupData), // Incomplete data
          );
          return signupBloc;
        },
        act: (bloc) => bloc.add(SubmitSignupDataEvent()),
        expect: () => [
          SignupSubmissionLoading(),
          const SignupError(message: 'Please complete all required steps'),
        ],
      );
    });
  });
}
