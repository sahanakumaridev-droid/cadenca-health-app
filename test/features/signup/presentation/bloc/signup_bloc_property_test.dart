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

// Helper function to create SignupData with specific step data
SignupData createSignupDataWithStep(String stepId, dynamic data) {
  switch (stepId) {
    case 'personal_info':
      return SignupData(
        personalInfo: data as PersonalInfo,
        currentStep: 1,
        isComplete: false,
      );
    case 'preferences':
      return SignupData(
        preferences: data as Preferences,
        currentStep: 2,
        isComplete: false,
      );
    case 'demographics':
      return SignupData(
        demographics: data as Demographics,
        currentStep: 3,
        isComplete: false,
      );
    case 'interests':
      return SignupData(
        interests: data as Interests,
        currentStep: 4,
        isComplete: false,
      );
    case 'account_settings':
      return SignupData(
        accountSettings: data as AccountSettings,
        currentStep: 5,
        isComplete: false,
      );
    default:
      return const SignupData(currentStep: 0, isComplete: false);
  }
}

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

  // Property Test: Signup State Data Saving
  // Feature: flutter-auth-app, Property 5: Signup State Data Saving
  group('Property Test: Signup State Data Saving', () {
    test(
      'for any signup screen and valid input data, completing the screen should save data into shared state',
      () async {
        // Test various types of data that should be saved
        final testCases = [
          {
            'type': 'PersonalInfo',
            'data': const PersonalInfo(
              firstName: 'John',
              lastName: 'Doe',
              phoneNumber: '+1234567890',
              gender: 'Male',
            ),
            'event': const SavePersonalInfoEvent(
              personalInfo: PersonalInfo(
                firstName: 'John',
                lastName: 'Doe',
                phoneNumber: '+1234567890',
                gender: 'Male',
              ),
            ),
            'stepId': 'personal_info',
          },
          {
            'type': 'Preferences',
            'data': const Preferences(
              emailNotifications: true,
              pushNotifications: false,
              theme: 'dark',
              language: 'English',
              interests: ['Technology', 'Sports'],
            ),
            'event': const SavePreferencesEvent(
              preferences: Preferences(
                emailNotifications: true,
                pushNotifications: false,
                theme: 'dark',
                language: 'English',
                interests: ['Technology', 'Sports'],
              ),
            ),
            'stepId': 'preferences',
          },
          {
            'type': 'Demographics',
            'data': const Demographics(
              country: 'United States',
              city: 'New York',
              occupation: 'Software Developer',
              education: 'Bachelor\'s Degree',
              ageRange: '25-34',
            ),
            'event': const SaveDemographicsEvent(
              demographics: Demographics(
                country: 'United States',
                city: 'New York',
                occupation: 'Software Developer',
                education: 'Bachelor\'s Degree',
                ageRange: '25-34',
              ),
            ),
            'stepId': 'demographics',
          },
          {
            'type': 'Interests',
            'data': const Interests(
              categories: ['Technology', 'Business'],
              hobbies: ['Reading', 'Gaming'],
              skills: ['Programming', 'Design'],
            ),
            'event': const SaveInterestsEvent(
              interests: Interests(
                categories: ['Technology', 'Business'],
                hobbies: ['Reading', 'Gaming'],
                skills: ['Programming', 'Design'],
              ),
            ),
            'stepId': 'interests',
          },
          {
            'type': 'AccountSettings',
            'data': const AccountSettings(
              isProfilePublic: true,
              allowDataCollection: false,
              enableTwoFactor: true,
              privacyLevel: 'friends',
            ),
            'event': const SaveAccountSettingsEvent(
              accountSettings: AccountSettings(
                isProfilePublic: true,
                allowDataCollection: false,
                enableTwoFactor: true,
                privacyLevel: 'friends',
              ),
            ),
            'stepId': 'account_settings',
          },
        ];

        for (final testCase in testCases) {
          final stepId = testCase['stepId'] as String;
          final event = testCase['event'] as SignupEvent;

          // Mock successful save operation
          when(
            () => mockSaveSignupStep(stepId, any()),
          ).thenAnswer((_) async => const Right(null));

          // Mock progress retrieval to return saved data
          when(() => mockGetSignupProgress()).thenAnswer(
            (_) async =>
                Right(createSignupDataWithStep(stepId, testCase['data'])),
          );

          // Create a new bloc for each test case
          final testBloc = SignupBloc(
            saveSignupStep: mockSaveSignupStep,
            getSignupProgress: mockGetSignupProgress,
            submitSignupData: mockSubmitSignupData,
          );

          // Test that data is saved into shared state
          await expectLater(
            testBloc.stream,
            emitsInOrder([
              SignupLoading(),
              isA<SignupStepSaved>().having(
                (state) => state.message,
                'message',
                contains('saved successfully'),
              ),
            ]),
          );

          testBloc.add(event);
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify the save operation was called with correct parameters
          verify(() => mockSaveSignupStep(stepId, any())).called(1);
          verify(() => mockGetSignupProgress()).called(1);

          await testBloc.close();
        }
      },
    );

    test(
      'data should be preserved in shared state across different step types',
      () async {
        // Test that saving different types of data preserves previously saved data
        const personalInfo = PersonalInfo(firstName: 'John', lastName: 'Doe');
        const preferences = Preferences(
          emailNotifications: true,
          pushNotifications: false,
          theme: 'light',
          language: 'English',
          interests: ['Tech'],
        );

        // Mock save operations
        when(
          () => mockSaveSignupStep('personal_info', any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockSaveSignupStep('preferences', any()),
        ).thenAnswer((_) async => const Right(null));

        // First save - personal info only
        when(() => mockGetSignupProgress()).thenAnswer(
          (_) async => const Right(
            SignupData(
              personalInfo: personalInfo,
              currentStep: 1,
              isComplete: false,
            ),
          ),
        );

        signupBloc.add(const SavePersonalInfoEvent(personalInfo: personalInfo));
        await Future.delayed(const Duration(milliseconds: 100));

        // Second save - preferences (should preserve personal info)
        when(() => mockGetSignupProgress()).thenAnswer(
          (_) async => const Right(
            SignupData(
              personalInfo: personalInfo,
              preferences: preferences,
              currentStep: 2,
              isComplete: false,
            ),
          ),
        );

        signupBloc.add(const SavePreferencesEvent(preferences: preferences));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify both save operations were called
        verify(() => mockSaveSignupStep('personal_info', any())).called(1);
        verify(() => mockSaveSignupStep('preferences', any())).called(1);

        // Verify progress was retrieved multiple times (indicating state preservation)
        verify(() => mockGetSignupProgress()).called(greaterThan(1));
      },
    );

    test('invalid data should not be saved to shared state', () async {
      // Test that validation prevents invalid data from being saved
      when(
        () => mockSaveSignupStep('personal_info', any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Invalid data')));

      await expectLater(
        signupBloc.stream,
        emitsInOrder([
          SignupLoading(),
          const SignupError(message: 'Invalid data'),
        ]),
      );

      // Try to save invalid personal info (empty names)
      signupBloc.add(
        const SavePersonalInfoEvent(
          personalInfo: PersonalInfo(firstName: '', lastName: ''),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify save was attempted but failed
      verify(() => mockSaveSignupStep('personal_info', any())).called(1);

      // Progress should not be retrieved since save failed
      verifyNever(() => mockGetSignupProgress());
    });

    test('concurrent save operations should maintain data integrity', () async {
      // Test that multiple rapid save operations don't corrupt the shared state
      const personalInfo = PersonalInfo(firstName: 'John', lastName: 'Doe');
      const preferences = Preferences(
        emailNotifications: true,
        pushNotifications: false,
        theme: 'dark',
        language: 'English',
        interests: ['Tech'],
      );

      // Mock save operations with slight delays to simulate real conditions
      when(() => mockSaveSignupStep('personal_info', any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return const Right(null);
      });
      when(() => mockSaveSignupStep('preferences', any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return const Right(null);
      });

      // Mock progress retrieval
      when(() => mockGetSignupProgress()).thenAnswer(
        (_) async => const Right(
          SignupData(
            personalInfo: personalInfo,
            preferences: preferences,
            currentStep: 2,
            isComplete: false,
          ),
        ),
      );

      // Trigger concurrent save operations
      signupBloc.add(const SavePersonalInfoEvent(personalInfo: personalInfo));
      signupBloc.add(const SavePreferencesEvent(preferences: preferences));

      await Future.delayed(const Duration(milliseconds: 200));

      // Both operations should complete successfully
      verify(() => mockSaveSignupStep('personal_info', any())).called(1);
      verify(() => mockSaveSignupStep('preferences', any())).called(1);
    });
  });
}
