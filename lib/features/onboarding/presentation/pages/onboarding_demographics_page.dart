import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart' as di;
import '../../data/datasources/onboarding_local_datasource.dart';

class OnboardingDemographicsPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const OnboardingDemographicsPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<OnboardingDemographicsPage> createState() =>
      _OnboardingDemographicsPageState();
}

class _OnboardingDemographicsPageState extends State<OnboardingDemographicsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  String? _selectedGender;
  String? _selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  void _checkAndAutoAdvance() async {
    // Auto-advance when both gender and age are selected
    if (_selectedGender != null && _selectedAgeGroup != null) {
      // Save demographics data
      final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
      await onboardingDataSource.setUserGender(_selectedGender!);
      await onboardingDataSource.setUserAgeGroup(_selectedAgeGroup!);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          widget.onContinue();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Stack(
        children: [
          // Background with beige gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0E6D2), // Stronger beige
                  Color(0xFFEADDC4), // Deeper beige
                  Color(0xFFF0E6D2), // Back to stronger beige
                  Color(0xFFF5EBD8), // Lighter but more visible beige
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // Geometric shapes for visual interest
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: isSmallScreen ? 16 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This helps us personalize your wellness recommendations based on research.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Gender selection
                  Text(
                    'HOW DO YOU IDENTIFY?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: const Color(0xFF5A5A5A).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          icon: '👨',
                          label: 'Male',
                          isSelected: _selectedGender == 'male',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedGender = 'male');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          icon: '👩',
                          label: 'Female',
                          isSelected: _selectedGender == 'female',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedGender = 'female');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Age group selection
                  Text(
                    'YOUR AGE GROUP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: const Color(0xFF5A5A5A).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          label: '18-24',
                          isSelected: _selectedAgeGroup == '18-24',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '18-24');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          label: '25-34',
                          isSelected: _selectedAgeGroup == '25-34',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '25-34');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          label: '35-44',
                          isSelected: _selectedAgeGroup == '35-44',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '35-44');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          label: '45-54',
                          isSelected: _selectedAgeGroup == '45-54',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '45-54');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          label: '55-64',
                          isSelected: _selectedAgeGroup == '55-64',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '55-64');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          label: '65+',
                          isSelected: _selectedAgeGroup == '65+',
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            setState(() => _selectedAgeGroup = '65+');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Privacy note
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: const Color(0xFF5A5A5A).withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your personal data is encrypted and never shared. We only use this to improve your recommendations.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: const Color(
                              0xFF5A5A5A,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 40),

                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF2C2C2C),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _selectedGender != null &&
                                    _selectedAgeGroup != null
                                ? widget.onContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B7355),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF8B7355,
                              ).withValues(alpha: 0.4),
                              disabledForegroundColor: Colors.white.withValues(
                                alpha: 0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    String? icon,
    required String label,
    required bool isSelected,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B7355).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B7355)
                : const Color(0xFF8B7355).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Text(icon, style: TextStyle(fontSize: isSmallScreen ? 28 : 32)),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClouds() {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }

  Widget _buildCloud(double speed, double top, double opacity) {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }
}
