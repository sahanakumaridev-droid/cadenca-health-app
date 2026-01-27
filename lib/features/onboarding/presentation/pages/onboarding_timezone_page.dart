import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/timezone_data_with_coords.dart';

class OnboardingTimezonePage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const OnboardingTimezonePage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<OnboardingTimezonePage> createState() => _OnboardingTimezonePageState();
}

class _OnboardingTimezonePageState extends State<OnboardingTimezonePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  String? _selectedTimezone;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTimezones = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Start with popular US cities
    _filteredTimezones = TimezoneData.getPopularUSCities();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  void _filterTimezones(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredTimezones = TimezoneData.searchTimezones(query);
    });
  }

  void _selectTimezone(Map<String, dynamic> timezone) {
    setState(() {
      _selectedTimezone = timezone['city']?.toString();
    });

    // Auto-advance after selection
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onContinue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 850;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          _buildClouds(),
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
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.public,
                      color: const Color(0xFF14B8A6),
                      size: isSmallScreen ? 26 : 30,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                  ),

                  // Title
                  Text(
                    'What do you call home?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 26 : (isMediumScreen ? 29 : 32),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 10),

                  Text(
                    'Select your primary residence timezone. This helps us calculate your circadian rhythm.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
                  ),

                  // Search bar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 16,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterTimezones,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search city, timezone, or region',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: isSmallScreen ? 14 : 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterTimezones('');
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
                  ),

                  // Section header
                  if (!_isSearching) ...[
                    Text(
                      'POPULAR US CITIES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ] else ...[
                    Text(
                      'SEARCH RESULTS (${_filteredTimezones.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],

                  // Timezone grid
                  if (_filteredTimezones.isEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: isSmallScreen ? 32 : 40,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No cities found',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            'Try searching for a different city or timezone',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: isSmallScreen ? 10 : 12,
                        mainAxisSpacing: isSmallScreen ? 10 : 12,
                        childAspectRatio: isSmallScreen ? 1.4 : 1.3,
                      ),
                      itemCount: _filteredTimezones.length,
                      itemBuilder: (context, index) {
                        final tz = _filteredTimezones[index];
                        final isSelected =
                            _selectedTimezone == tz['city']?.toString();

                        return InkWell(
                          onTap: () => _selectTimezone(tz),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF14B8A6,
                                    ).withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF14B8A6)
                                    : Colors.white.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color(0xFF14B8A6),
                                      size: isSmallScreen ? 14 : 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tz['city']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: const Color(0xFF14B8A6),
                                        size: isSmallScreen ? 16 : 18,
                                      ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 3 : 4),
                                Text(
                                  tz['region']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tz['code']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'GMT${tz['offset']?.toString() ?? ''}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF14B8A6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  SizedBox(
                    height: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
                  ),

                  // Navigation buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: isSmallScreen ? 50 : 54,
                          child: ElevatedButton(
                            onPressed: _selectedTimezone != null
                                ? widget.onContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14B8A6),
                              foregroundColor: const Color(0xFF0F172A),
                              disabledBackgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
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

  Widget _buildClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [_buildCloud(0.2, 120, 0.03), _buildCloud(0.5, 280, 0.04)],
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
