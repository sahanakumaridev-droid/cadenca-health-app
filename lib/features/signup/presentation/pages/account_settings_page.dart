import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/signup_data.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _isProfilePublic = false;
  bool _allowDataCollection = true;
  bool _enableTwoFactor = false;
  String _privacyLevel = 'friends';

  final List<String> _privacyOptions = ['public', 'friends', 'private'];

  @override
  void initState() {
    super.initState();
    context.read<SignupBloc>().add(LoadSignupProgressEvent());
  }

  void _loadExistingData(AccountSettings? accountSettings) {
    if (accountSettings != null) {
      setState(() {
        _isProfilePublic = accountSettings.isProfilePublic;
        _allowDataCollection = accountSettings.allowDataCollection;
        _enableTwoFactor = accountSettings.enableTwoFactor;
        _privacyLevel = accountSettings.privacyLevel;
      });
    }
  }

  void _saveAndContinue() {
    final accountSettings = AccountSettings(
      isProfilePublic: _isProfilePublic,
      allowDataCollection: _allowDataCollection,
      enableTwoFactor: _enableTwoFactor,
      privacyLevel: _privacyLevel,
    );

    context.read<SignupBloc>().add(
      SaveAccountSettingsEvent(accountSettings: accountSettings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.interests),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoaded) {
            _loadExistingData(state.signupData.accountSettings);
          } else if (state is SignupStepSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.review);
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
            final isLoading = state is SignupLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: 5 / 6, // Step 5 of 6
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 5 of 6',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure your privacy and security preferences.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Privacy Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Settings',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          SwitchListTile(
                            title: const Text('Public Profile'),
                            subtitle: const Text(
                              'Make your profile visible to everyone',
                            ),
                            value: _isProfilePublic,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _isProfilePublic = value;
                                    });
                                  },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Privacy Level',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),

                          ...ListTile.divideTiles(
                            context: context,
                            tiles: _privacyOptions.map((option) {
                              return RadioListTile<String>(
                                title: Text(_getPrivacyTitle(option)),
                                subtitle: Text(_getPrivacySubtitle(option)),
                                value: option,
                                groupValue: _privacyLevel,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _privacyLevel = value!;
                                        });
                                      },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Settings',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          SwitchListTile(
                            title: const Text('Two-Factor Authentication'),
                            subtitle: const Text(
                              'Add an extra layer of security to your account',
                            ),
                            value: _enableTwoFactor,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _enableTwoFactor = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Settings',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          SwitchListTile(
                            title: const Text('Allow Data Collection'),
                            subtitle: const Text(
                              'Help us improve our services with anonymous usage data',
                            ),
                            value: _allowDataCollection,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _allowDataCollection = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveAndContinue,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Skip Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.go(AppRouter.review);
                            },
                      child: const Text('Skip for now'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getPrivacyTitle(String option) {
    switch (option) {
      case 'public':
        return 'Public';
      case 'friends':
        return 'Friends Only';
      case 'private':
        return 'Private';
      default:
        return option;
    }
  }

  String _getPrivacySubtitle(String option) {
    switch (option) {
      case 'public':
        return 'Anyone can see your profile and activity';
      case 'friends':
        return 'Only your friends can see your profile and activity';
      case 'private':
        return 'Only you can see your profile and activity';
      default:
        return '';
    }
  }
}
