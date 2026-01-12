import 'dart:ui';
import 'package:flutter/material.dart';

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

  void _checkAndAutoAdvance() {
    // Auto-advance when both gender and age are selected
    if (_selectedGender != null && _selectedAgeGroup != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onContinue();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          _buildClouds(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This helps us personalize your wellness recommendations based on research.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Gender selection
                  Text(
                    'HOW DO YOU IDENTIFY?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: Colors.white.withOpacity(0.5),
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
                          onTap: () {
                            setState(() => _selectedGender = 'female');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Age group selection
                  Text(
                    'YOUR AGE GROUP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          label: '18-24',
                          isSelected: _selectedAgeGroup == '18-24',
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
                          onTap: () {
                            setState(() => _selectedAgeGroup = '65+');
                            _checkAndAutoAdvance();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Privacy note
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your personal data is encrypted and never shared. We only use this to improve your recommendations.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
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
                              backgroundColor: const Color(0xFF14B8A6),
                              foregroundColor: const Color(0xFF0F172A),
                              disabledBackgroundColor: Colors.white.withOpacity(
                                0.1,
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
    required VoidCallback onTap,
    bool autoAdvance = false,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        if (autoAdvance) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              widget.onContinue();
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF14B8A6).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF14B8A6)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [_buildCloud(0.2, 100, 0.03), _buildCloud(0.5, 200, 0.04)],
        );
      },
    );
  }

  Widget _buildCloud(double speed, double top, double opacity) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = _cloudController.value;
    final dx = (progress * screenWidth * speed) % (screenWidth * 1.5);

    return Positioned(
      left: dx - screenWidth * 0.25,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 150,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
