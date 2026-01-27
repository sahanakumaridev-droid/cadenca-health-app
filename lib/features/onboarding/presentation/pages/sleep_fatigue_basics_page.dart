import 'dart:ui';
import 'package:flutter/material.dart';

class SleepFatigueBasicsPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const SleepFatigueBasicsPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<SleepFatigueBasicsPage> createState() => _SleepFatigueBasicsPageState();
}

class _SleepFatigueBasicsPageState extends State<SleepFatigueBasicsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;

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
    final isMediumScreen = screenHeight >= 700 && screenHeight < 850;

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
                horizontal: screenWidth * 0.06,
                vertical: isSmallScreen ? 12 : (isMediumScreen ? 16 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isSmallScreen ? 25 : (isMediumScreen ? 35 : 45),
                  ),

                  // Icon
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7355).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFF8B7355),
                      size: isSmallScreen ? 26 : 30,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                  ),

                  // Title
                  Text(
                    'Sleep & Fatigue Basics',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 26 : (isMediumScreen ? 29 : 32),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 10),

                  Text(
                    'Here\'s how Cadenca gives you a simple, science-based view',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                      color: const Color(0xFF5A5A5A),
                      height: 1.3,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
                  ),

                  // Feature cards
                  _buildFeatureCard(
                    icon: Icons.bedtime,
                    title: 'How much you slept',
                    description:
                        'We analyze your recent sleep history to understand your baseline.',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  _buildFeatureCard(
                    icon: Icons.schedule,
                    title: 'When you slept',
                    description:
                        'Alignment with your body clock matters as much as duration.',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  _buildFeatureCard(
                    icon: Icons.trending_up,
                    title: 'Weekly patterns',
                    description:
                        'Consistency where possible helps maintain your circadian rhythm.',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 28),

                  // Fatigue Score Card
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Fatigue Score',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: const Color(0xFF5A5A5A),
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'Your score is '),
                              TextSpan(
                                text: 'directional, not diagnostic',
                                style: TextStyle(
                                  color: const Color(0xFF8B7355),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. It shows whether your sleep patterns are trending towards higher or lower fatigue — based on research from circadian and shift-work science.',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: const Color(0xFF8B7355),
                              size: isSmallScreen ? 18 : 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'As we gather more usage and wearable data, the score becomes more personalized and sophisticated.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: const Color(
                                    0xFF5A5A5A,
                                  ).withValues(alpha: 0.8),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 32 : (isMediumScreen ? 36 : 40),
                  ),

                  // Navigation buttons
                  Row(
                    children: [
                      // Back button
                      SizedBox(
                        height: isSmallScreen ? 50 : 54,
                        child: ElevatedButton(
                          onPressed: widget.onBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.6,
                            ),
                            foregroundColor: const Color(0xFF2C2C2C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),

                      SizedBox(width: isSmallScreen ? 12 : 16),

                      // Got it! button
                      Expanded(
                        child: SizedBox(
                          height: isSmallScreen ? 50 : 54,
                          child: ElevatedButton(
                            onPressed: widget.onContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B7355),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Got it!',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 15 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom safe area padding
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B7355),
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: const Color(0xFF5A5A5A),
                    height: 1.3,
                  ),
                ),
              ],
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
