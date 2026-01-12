import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/signup_data.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _theme = 'system';
  String _language = 'English';
  final List<String> _selectedInterests = [];

  final List<String> _themeOptions = ['light', 'dark', 'system'];
  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
  ];
  final List<String> _interestOptions = [
    'Technology',
    'Sports',
    'Music',
    'Travel',
    'Food',
    'Art',
    'Science',
    'Books',
  ];

  @override
  void initState() {
    super.initState();
    context.read<SignupBloc>().add(LoadSignupProgressEvent());
  }

  void _loadExistingData(Preferences? preferences) {
    if (preferences != null) {
      setState(() {
        _emailNotifications = preferences.emailNotifications;
        _pushNotifications = preferences.pushNotifications;
        _theme = preferences.theme;
        _language = preferences.language;
        _selectedInterests.clear();
        _selectedInterests.addAll(preferences.interests);
      });
    }
  }

  void _saveAndContinue() {
    final preferences = Preferences(
      emailNotifications: _emailNotifications,
      pushNotifications: _pushNotifications,
      theme: _theme,
      language: _language,
      interests: _selectedInterests,
    );

    context.read<SignupBloc>().add(
      SavePreferencesEvent(preferences: preferences),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.personalInfo),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoaded) {
            _loadExistingData(state.signupData.preferences);
          } else if (state is SignupStepSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.demographics);
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
                    value: 2 / 6, // Step 2 of 6
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 2 of 6',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Set your preferences',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your app experience.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Notifications
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Email Notifications'),
                            subtitle: const Text('Receive updates via email'),
                            value: _emailNotifications,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _emailNotifications = value;
                                    });
                                  },
                          ),
                          SwitchListTile(
                            title: const Text('Push Notifications'),
                            subtitle: const Text('Receive push notifications'),
                            value: _pushNotifications,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _pushNotifications = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Theme and Language
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appearance & Language',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _theme,
                            decoration: const InputDecoration(
                              labelText: 'Theme',
                              border: OutlineInputBorder(),
                            ),
                            items: _themeOptions.map((theme) {
                              return DropdownMenuItem(
                                value: theme,
                                child: Text(
                                  theme.substring(0, 1).toUpperCase() +
                                      theme.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _theme = value!;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _language,
                            decoration: const InputDecoration(
                              labelText: 'Language',
                              border: OutlineInputBorder(),
                            ),
                            items: _languageOptions.map((language) {
                              return DropdownMenuItem(
                                value: language,
                                child: Text(language),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _language = value!;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interests
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interests',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select topics you\'re interested in',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _interestOptions.map((interest) {
                              final isSelected = _selectedInterests.contains(
                                interest,
                              );
                              return FilterChip(
                                label: Text(interest),
                                selected: isSelected,
                                onSelected: isLoading
                                    ? null
                                    : (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedInterests.add(interest);
                                          } else {
                                            _selectedInterests.remove(interest);
                                          }
                                        });
                                      },
                              );
                            }).toList(),
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
                              context.go(AppRouter.demographics);
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
}
