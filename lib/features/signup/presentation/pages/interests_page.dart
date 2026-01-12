import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/signup_data.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final List<String> _selectedCategories = [];
  final List<String> _selectedHobbies = [];
  final List<String> _selectedSkills = [];

  final List<String> _categoryOptions = [
    'Technology',
    'Business',
    'Health & Fitness',
    'Entertainment',
    'Education',
    'Travel',
    'Food & Cooking',
    'Sports',
    'Arts & Culture',
    'Science',
  ];

  final List<String> _hobbyOptions = [
    'Reading',
    'Gaming',
    'Photography',
    'Music',
    'Cooking',
    'Gardening',
    'Hiking',
    'Painting',
    'Writing',
    'Dancing',
    'Cycling',
    'Yoga',
  ];

  final List<String> _skillOptions = [
    'Programming',
    'Design',
    'Writing',
    'Public Speaking',
    'Leadership',
    'Project Management',
    'Marketing',
    'Data Analysis',
    'Languages',
    'Teaching',
  ];

  @override
  void initState() {
    super.initState();
    context.read<SignupBloc>().add(LoadSignupProgressEvent());
  }

  void _loadExistingData(Interests? interests) {
    if (interests != null) {
      setState(() {
        _selectedCategories.clear();
        _selectedCategories.addAll(interests.categories);
        _selectedHobbies.clear();
        _selectedHobbies.addAll(interests.hobbies);
        _selectedSkills.clear();
        _selectedSkills.addAll(interests.skills);
      });
    }
  }

  void _saveAndContinue() {
    final interests = Interests(
      categories: _selectedCategories,
      hobbies: _selectedHobbies,
      skills: _selectedSkills,
    );

    context.read<SignupBloc>().add(SaveInterestsEvent(interests: interests));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.demographics),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoaded) {
            _loadExistingData(state.signupData.interests);
          } else if (state is SignupStepSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.accountSettings);
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
                    value: 4 / 6, // Step 4 of 6
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 4 of 6',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Your Interests',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us what you\'re passionate about.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Categories
                  _buildInterestSection(
                    'Categories',
                    'What topics interest you?',
                    _categoryOptions,
                    _selectedCategories,
                    isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Hobbies
                  _buildInterestSection(
                    'Hobbies',
                    'What do you enjoy doing in your free time?',
                    _hobbyOptions,
                    _selectedHobbies,
                    isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Skills
                  _buildInterestSection(
                    'Skills',
                    'What are you good at or learning?',
                    _skillOptions,
                    _selectedSkills,
                    isLoading,
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
                              context.go(AppRouter.accountSettings);
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

  Widget _buildInterestSection(
    String title,
    String subtitle,
    List<String> options,
    List<String> selectedItems,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: options.map((option) {
                final isSelected = selectedItems.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: isLoading
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected) {
                              selectedItems.add(option);
                            } else {
                              selectedItems.remove(option);
                            }
                          });
                        },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
