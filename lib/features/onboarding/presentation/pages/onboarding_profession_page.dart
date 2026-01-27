import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart' as di;
import '../../data/datasources/onboarding_local_datasource.dart';

class OnboardingProfessionPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const OnboardingProfessionPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<OnboardingProfessionPage> createState() =>
      _OnboardingProfessionPageState();
}

class _OnboardingProfessionPageState extends State<OnboardingProfessionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  String? _selectedProfession;

  final List<Map<String, dynamic>> _professions = [
    {
      'id': 'long_haul_pilot',
      'icon': Icons.flight,
      'title': 'Long Haul Pilot',
      'subtitle': 'Flights over 6 hours',
    },
    {
      'id': 'short_haul_pilot',
      'icon': Icons.flight_takeoff,
      'title': 'Short Haul Pilot',
      'subtitle': 'Regional & domestic flights',
    },
    {
      'id': 'long_haul_cabin',
      'icon': Icons.airline_seat_recline_normal,
      'title': 'Long Haul Cabin Crew',
      'subtitle': 'International routes',
    },
    {
      'id': 'short_haul_cabin',
      'icon': Icons.airline_seat_flat,
      'title': 'Short Haul Cabin Crew',
      'subtitle': 'Regional routes',
    },
    {
      'id': 'other',
      'icon': Icons.work_outline,
      'title': 'Other Airline Staff',
      'subtitle': 'Ground crew, operations, etc.',
    },
  ];

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
                    'What is your profession?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Different roles have different fatigue profiles. We\'ll tailor recommendations accordingly.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Profession list
                  ..._professions.map((profession) {
                    final isSelected = _selectedProfession == profession['id'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            _selectedProfession = profession['id'];
                          });

                          // Save profession data
                          final onboardingDataSource = di
                              .sl<OnboardingLocalDataSource>();
                          await onboardingDataSource.setUserProfession(
                            profession['title'],
                          );

                          // Auto-advance after selection with visual feedback
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              widget.onContinue();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B7355).withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8B7355)
                                  : const Color(
                                      0xFF8B7355,
                                    ).withValues(alpha: 0.4),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B7355,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  profession['icon'],
                                  color: const Color(0xFF8B7355),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profession['title'],
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 15 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C2C2C),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profession['subtitle'],
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 14,
                                        color: const Color(0xFF5A5A5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF8B7355),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: isSmallScreen ? 20 : 24),

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
                            onPressed: _selectedProfession != null
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

  Widget _buildClouds() {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }

  Widget _buildCloud(double speed, double top, double opacity) {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }
}
