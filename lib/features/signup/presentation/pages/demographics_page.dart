import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/signup_data.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedOccupation;
  String? _selectedEducation;
  String? _selectedAgeRange;

  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Australia',
    'Japan',
    'Other',
  ];

  final List<String> _occupations = [
    'Software Developer',
    'Designer',
    'Manager',
    'Teacher',
    'Doctor',
    'Engineer',
    'Student',
    'Other',
  ];

  final List<String> _educationLevels = [
    'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Trade School',
    'Other',
  ];

  final List<String> _ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];

  @override
  void initState() {
    super.initState();
    context.read<SignupBloc>().add(LoadSignupProgressEvent());
  }

  void _loadExistingData(Demographics? demographics) {
    if (demographics != null) {
      setState(() {
        _selectedCountry = demographics.country;
        _selectedCity = demographics.city;
        _selectedOccupation = demographics.occupation;
        _selectedEducation = demographics.education;
        _selectedAgeRange = demographics.ageRange;
      });
    }
  }

  void _saveAndContinue() {
    final demographics = Demographics(
      country: _selectedCountry,
      city: _selectedCity,
      occupation: _selectedOccupation,
      education: _selectedEducation,
      ageRange: _selectedAgeRange,
    );

    context.read<SignupBloc>().add(
      SaveDemographicsEvent(demographics: demographics),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demographics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.preferences),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoaded) {
            _loadExistingData(state.signupData.demographics);
          } else if (state is SignupStepSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.interests);
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
                    value: 3 / 6, // Step 3 of 6
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 3 of 6',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Demographics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us understand our community better (all optional).',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Country
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // City
                  TextFormField(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter your city',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    onChanged: (value) {
                      _selectedCity = value.trim().isEmpty
                          ? null
                          : value.trim();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Age Range
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAgeRange,
                    decoration: const InputDecoration(
                      labelText: 'Age Range',
                      border: OutlineInputBorder(),
                    ),
                    items: _ageRanges.map((ageRange) {
                      return DropdownMenuItem(
                        value: ageRange,
                        child: Text(ageRange),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAgeRange = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Occupation
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOccupation,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder(),
                    ),
                    items: _occupations.map((occupation) {
                      return DropdownMenuItem(
                        value: occupation,
                        child: Text(occupation),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedOccupation = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Education
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEducation,
                    decoration: const InputDecoration(
                      labelText: 'Education Level',
                      border: OutlineInputBorder(),
                    ),
                    items: _educationLevels.map((education) {
                      return DropdownMenuItem(
                        value: education,
                        child: Text(education),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedEducation = value;
                            });
                          },
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
                              context.go(AppRouter.interests);
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
