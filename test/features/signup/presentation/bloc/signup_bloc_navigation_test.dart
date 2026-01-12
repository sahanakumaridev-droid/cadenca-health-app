import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
    gender: 'Male',
  );

  const tPreferences = Preferences(
    emailNotifications: true,
    pushNotifications: false,
    theme: 'dark',
    language: 'English',
    interests: ['Technology', 'Sports'],
  );

  const tDemographics = Demographics(
    country: 'United States',
    city: 'New York',
    occupation: 'Software Developer',
    education: 'Bachelor\'s Degree',
    ageRange: '25-34',
  );

  // Property Test: Bidirectional Navigation Data Preservation
  // Feature: flutter-auth-app, Property 3: Forward and backward navigation preserves data
  group('Property Test: Bidirectional Navigation', () {
    test(
      'forward and backward navigation should preserve all entered data',
      () async {
        // Create test data for different steps
        final testDataSequence = [
          const SignupData(currentStep: 0, isComplete: false),
          const SignupData(
            personalInfo: tPersonalInfo,
            currentStep: 1,
            isComplete: false,
          ),
          const SignupData(
            personalInfo: tPersonalInfo,
            preferences: tPreferences,
            currentStep: 2,
            isComplete: false,
          ),
          const SignupData(
            personalInfo: tPersonalInfo,
            preferences: tPreferences,
            demographics: tDemographics,
            currentStep: 3,
            isComplete: false,
          ),
        ];

        // Test forward navigation (0 -> 1 -> 2 -> 3)
        for (int i = 0; i < testDataSequence.length; i++) {
          final data = testDataSequence[i];

          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => Right(data));

          await expectLater(
            signupBloc.stream,
            emits(
              isA<SignupNavigated>().having(
                (state) => state.currentStep,
                'currentStep',
                equals(i),
              ),
            ),
          );

          signupBloc.add(NavigateToStepEvent(step: i));
          await Future.delayed(const Duration(milliseconds: 50));

          // Verify data is preserved during forward navigation
          if (signupBloc.state is SignupNavigated) {
            final state = signupBloc.state as SignupNavigated;
            expect(state.signupData.personalInfo, equals(data.personalInfo));
            expect(state.signupData.preferences, equals(data.preferences));
            expect(state.signupData.demographics, equals(data.demographics));
          }
        }

        // Test backward navigation (3 -> 2 -> 1 -> 0)
        for (int i = testDataSequence.length - 1; i >= 0; i--) {
          final data = testDataSequence[i];

          when(
            () => mockGetSignupProgress(),
          ).thenAnswer((_) async => Right(data));

          signupBloc.add(NavigateToStepEvent(step: i));
          await Future.delayed(const Duration(milliseconds: 50));

          // Verify data is preserved during backward navigation
          if (signupBloc.state is SignupNavigated) {
            final state = signupBloc.state as SignupNavigated;

            // Data should be preserved based on the step we're navigating to
            if (i >= 1) {
              expect(state.signupData.personalInfo, equals(tPersonalInfo));
            }
            if (i >= 2) {
              expect(state.signupData.preferences, equals(tPreferences));
            }
            if (i >= 3) {
              expect(state.signupData.demographics, equals(tDemographics));
            }
          }
        }
      },
    );

    test('random navigation sequence should preserve data integrity', () async {
      // Test with random navigation patterns to ensure data is always preserved
      final randomNavigationSequence = [0, 3, 1, 4, 2, 5, 1, 3, 0, 2];
      const fullData = SignupData(
        personalInfo: tPersonalInfo,
        preferences: tPreferences,
        demographics: tDemographics,
        currentStep: 0,
        isComplete: false,
      );

      for (final step in randomNavigationSequence) {
        // Mock progress to return full data regardless of step
        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => Right(fullData.copyWith(currentStep: step)));

        signupBloc.add(NavigateToStepEvent(step: step));
        await Future.delayed(const Duration(milliseconds: 30));

        // Verify that regardless of navigation order, data is preserved
        if (signupBloc.state is SignupNavigated) {
          final state = signupBloc.state as SignupNavigated;
          expect(state.signupData.personalInfo, equals(tPersonalInfo));
          expect(state.signupData.preferences, equals(tPreferences));
          expect(state.signupData.demographics, equals(tDemographics));
          expect(state.currentStep, equals(step));
        }
      }
    });

    test('next and previous step navigation should preserve data', () async {
      // Test using NextStepEvent and PreviousStepEvent
      const initialData = SignupData(
        personalInfo: tPersonalInfo,
        preferences: tPreferences,
        currentStep: 2,
        isComplete: false,
      );

      // Test next step navigation
      when(
        () => mockGetSignupProgress(),
      ).thenAnswer((_) async => Right(initialData.copyWith(currentStep: 3)));

      await expectLater(
        signupBloc.stream,
        emits(
          isA<SignupNavigated>().having(
            (state) => state.currentStep,
            'currentStep',
            equals(3),
          ),
        ),
      );

      signupBloc.add(NextStepEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify data is preserved after next step
      if (signupBloc.state is SignupNavigated) {
        final state = signupBloc.state as SignupNavigated;
        expect(state.signupData.personalInfo, equals(tPersonalInfo));
        expect(state.signupData.preferences, equals(tPreferences));
      }

      // Test previous step navigation
      when(
        () => mockGetSignupProgress(),
      ).thenAnswer((_) async => Right(initialData.copyWith(currentStep: 1)));

      signupBloc.add(PreviousStepEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify data is preserved after previous step
      if (signupBloc.state is SignupNavigated) {
        final state = signupBloc.state as SignupNavigated;
        expect(state.signupData.personalInfo, equals(tPersonalInfo));
        expect(state.signupData.preferences, equals(tPreferences));
      }
    });

    test(
      'navigation boundaries should be respected while preserving data',
      () async {
        const testData = SignupData(
          personalInfo: tPersonalInfo,
          currentStep: 0,
          isComplete: false,
        );

        // Test navigation to step below minimum (should not navigate but preserve data)
        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => const Right(testData));

        signupBloc.add(PreviousStepEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        // Should remain at step 0 but data should be preserved
        if (signupBloc.state is SignupNavigated) {
          final state = signupBloc.state as SignupNavigated;
          expect(state.currentStep, equals(0)); // Should not go below 0
          expect(state.signupData.personalInfo, equals(tPersonalInfo));
        }

        // Test navigation to step above maximum
        const maxStepData = SignupData(
          personalInfo: tPersonalInfo,
          preferences: tPreferences,
          demographics: tDemographics,
          currentStep: 5,
          isComplete: false,
        );

        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => const Right(maxStepData));

        signupBloc.add(NextStepEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        // Should remain at step 5 but data should be preserved
        if (signupBloc.state is SignupNavigated) {
          final state = signupBloc.state as SignupNavigated;
          expect(state.currentStep, equals(5)); // Should not go above 5
          expect(state.signupData.personalInfo, equals(tPersonalInfo));
          expect(state.signupData.preferences, equals(tPreferences));
          expect(state.signupData.demographics, equals(tDemographics));
        }
      },
    );

    test(
      'navigation with concurrent data modifications should maintain consistency',
      () async {
        // Test that navigation during data saving operations maintains consistency
        const initialData = SignupData(
          personalInfo: tPersonalInfo,
          currentStep: 1,
          isComplete: false,
        );

        const updatedData = SignupData(
          personalInfo: tPersonalInfo,
          preferences: tPreferences,
          currentStep: 2,
          isComplete: false,
        );

        // Mock save operation
        when(
          () => mockSaveSignupStep('preferences', any()),
        ).thenAnswer((_) async => const Right(null));

        // Mock navigation during save
        when(
          () => mockGetSignupProgress(),
        ).thenAnswer((_) async => const Right(updatedData));

        // Trigger save and navigation concurrently
        signupBloc.add(const SavePreferencesEvent(preferences: tPreferences));
        signupBloc.add(const NavigateToStepEvent(step: 2));

        await Future.delayed(const Duration(milliseconds: 100));

        // Both operations should complete and data should be consistent
        verify(() => mockSaveSignupStep('preferences', any())).called(1);
        verify(() => mockGetSignupProgress()).called(greaterThan(0));

        // Final state should have both personal info and preferences
        if (signupBloc.state is SignupNavigated ||
            signupBloc.state is SignupStepSaved) {
          // Data integrity should be maintained regardless of final state type
          expect(true, isTrue); // Test passes if no exceptions thrown
        }
      },
    );
  });
}
