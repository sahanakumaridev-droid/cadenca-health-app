import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<SignupBloc>().add(LoadSignupProgressEvent());
  }

  void _submitSignup() {
    context.read<SignupBloc>().add(SubmitSignupDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.accountSettings),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupSubmissionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.home);
          } else if (state is SignupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) {
            if (state is SignupLoaded) {
              return _buildReviewContent(context, state);
            } else if (state is SignupSubmissionLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Submitting your information...'),
                  ],
                ),
              );
            } else if (state is SignupLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Unable to load signup data'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, SignupLoaded state) {
    final signupData = state.signupData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: 6 / 6, // Step 6 of 6
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text(
            'Step 6 of 6',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Text(
            'Review Your Information',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Completion Status
          Card(
            color: signupData.hasAllRequiredData
                ? Colors.green[50]
                : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    signupData.hasAllRequiredData
                        ? Icons.check_circle
                        : Icons.warning,
                    color: signupData.hasAllRequiredData
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          signupData.hasAllRequiredData
                              ? 'Profile Complete'
                              : 'Profile Incomplete',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: signupData.hasAllRequiredData
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                        ),
                        Text(
                          '${(signupData.completionPercentage * 100).round()}% completed',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: signupData.hasAllRequiredData
                                    ? Colors.green[600]
                                    : Colors.orange[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information
          if (signupData.personalInfo != null) ...[
            _buildSectionCard(
              context,
              'Personal Information',
              Icons.person,
              [
                'Name: ${signupData.personalInfo!.firstName} ${signupData.personalInfo!.lastName}',
                if (signupData.personalInfo!.phoneNumber != null)
                  'Phone: ${signupData.personalInfo!.phoneNumber}',
                if (signupData.personalInfo!.dateOfBirth != null)
                  'Date of Birth: ${_formatDate(signupData.personalInfo!.dateOfBirth!)}',
                if (signupData.personalInfo!.gender != null)
                  'Gender: ${signupData.personalInfo!.gender}',
              ],
              () => context.go(AppRouter.personalInfo),
            ),
            const SizedBox(height: 16),
          ],

          // Preferences
          if (signupData.preferences != null) ...[
            _buildSectionCard(
              context,
              'Preferences',
              Icons.settings,
              [
                'Email Notifications: ${signupData.preferences!.emailNotifications ? "Enabled" : "Disabled"}',
                'Push Notifications: ${signupData.preferences!.pushNotifications ? "Enabled" : "Disabled"}',
                'Theme: ${signupData.preferences!.theme}',
                'Language: ${signupData.preferences!.language}',
                if (signupData.preferences!.interests.isNotEmpty)
                  'Interests: ${signupData.preferences!.interests.join(", ")}',
              ],
              () => context.go(AppRouter.preferences),
            ),
            const SizedBox(height: 16),
          ],

          // Demographics
          if (signupData.demographics != null) ...[
            _buildSectionCard(
              context,
              'Demographics',
              Icons.public,
              [
                if (signupData.demographics!.country != null)
                  'Country: ${signupData.demographics!.country}',
                if (signupData.demographics!.city != null)
                  'City: ${signupData.demographics!.city}',
                if (signupData.demographics!.ageRange != null)
                  'Age Range: ${signupData.demographics!.ageRange}',
                if (signupData.demographics!.occupation != null)
                  'Occupation: ${signupData.demographics!.occupation}',
                if (signupData.demographics!.education != null)
                  'Education: ${signupData.demographics!.education}',
              ],
              () => context.go(AppRouter.demographics),
            ),
            const SizedBox(height: 16),
          ],

          // Interests
          if (signupData.interests != null) ...[
            _buildSectionCard(
              context,
              'Interests',
              Icons.favorite,
              [
                if (signupData.interests!.categories.isNotEmpty)
                  'Categories: ${signupData.interests!.categories.join(", ")}',
                if (signupData.interests!.hobbies.isNotEmpty)
                  'Hobbies: ${signupData.interests!.hobbies.join(", ")}',
                if (signupData.interests!.skills.isNotEmpty)
                  'Skills: ${signupData.interests!.skills.join(", ")}',
              ],
              () => context.go(AppRouter.interests),
            ),
            const SizedBox(height: 16),
          ],

          // Account Settings
          if (signupData.accountSettings != null) ...[
            _buildSectionCard(
              context,
              'Account Settings',
              Icons.security,
              [
                'Profile Visibility: ${signupData.accountSettings!.isProfilePublic ? "Public" : "Private"}',
                'Privacy Level: ${signupData.accountSettings!.privacyLevel}',
                'Two-Factor Auth: ${signupData.accountSettings!.enableTwoFactor ? "Enabled" : "Disabled"}',
                'Data Collection: ${signupData.accountSettings!.allowDataCollection ? "Allowed" : "Disabled"}',
              ],
              () => context.go(AppRouter.accountSettings),
            ),
            const SizedBox(height: 32),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Complete Signup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Terms and Conditions
          Text(
            'By completing signup, you agree to our Terms of Service and Privacy Policy. '
            'You can update your information anytime in your account settings.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
    VoidCallback onEdit,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                'No information provided',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
