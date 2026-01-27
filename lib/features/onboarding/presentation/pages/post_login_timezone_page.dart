import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/di/injection.dart' as di;
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/timezone_data_with_coords.dart';
import 'dart:math' as math;

class PostLoginTimezonePage extends StatefulWidget {
  final VoidCallback onContinue;

  const PostLoginTimezonePage({super.key, required this.onContinue});

  @override
  State<PostLoginTimezonePage> createState() => _PostLoginTimezonePageState();
}

class _PostLoginTimezonePageState extends State<PostLoginTimezonePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  late Timer _timeTimer;
  String? _selectedTimezone;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTimezones = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  String? _currentLocationText;
  Map<String, dynamic>? _nearestTimezone;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Start with popular US cities
    _filteredTimezones = TimezoneData.getPopularUSCities();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Start time timer
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Try to get current location
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cloudController.dispose();
    _timeTimer.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocationText = 'Location services disabled';
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _currentLocationText = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocationText = 'Location permission permanently denied';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationText = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          locationText = place.locality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          locationText = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationText = place.administrativeArea!;
        }

        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty &&
            locationText != place.administrativeArea) {
          locationText += ', ${place.administrativeArea}';
        }

        // Find nearest timezone
        Map<String, dynamic>? nearest = _findNearestTimezone(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentPosition = position;
          _currentLocationText = locationText;
          _nearestTimezone = nearest;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _currentLocationText = 'Unable to get location';
      });
    }
  }

  Map<String, dynamic>? _findNearestTimezone(double lat, double lng) {
    final allTimezones = TimezoneData.getAllTimezones();
    double minDistance = double.infinity;
    Map<String, dynamic>? nearest;

    for (var tz in allTimezones) {
      double distance = _calculateDistance(lat, lng, tz['lat'], tz['lng']);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = tz;
      }
    }

    return nearest;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  String _getCurrentTimeForTimezone(Map<String, dynamic> timezone) {
    try {
      // Get the offset from the timezone data (e.g., "-8", "+5:30")
      String offsetStr = timezone['offset']?.toString() ?? '+0';

      // Parse the offset
      double offsetHours = 0;
      if (offsetStr.contains(':')) {
        // Handle formats like "+5:30" or "-8:30"
        List<String> parts = offsetStr.replaceAll('+', '').split(':');
        double hours = double.parse(parts[0]);
        double minutes = double.parse(parts[1]) / 60;
        offsetHours = offsetStr.startsWith('-')
            ? -(hours + minutes)
            : (hours + minutes);
      } else {
        // Handle formats like "+5" or "-8"
        offsetHours = double.parse(offsetStr);
      }

      // Calculate the time in the target timezone
      DateTime utcTime = _currentTime.toUtc();
      DateTime timezoneTime = utcTime.add(
        Duration(
          hours: offsetHours.toInt(),
          minutes: ((offsetHours % 1) * 60).toInt(),
        ),
      );

      // Format the time
      String period = timezoneTime.hour >= 12 ? 'PM' : 'AM';
      int displayHour = timezoneTime.hour == 0
          ? 12
          : (timezoneTime.hour > 12
                ? timezoneTime.hour - 12
                : timezoneTime.hour);
      String minute = timezoneTime.minute.toString().padLeft(2, '0');

      return '$displayHour:$minute $period';
    } catch (e) {
      return '--:--';
    }
  }

  void _filterTimezones(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredTimezones = TimezoneData.getPopularUSCities();
      } else {
        // Prioritize US cities in search results
        final allResults = TimezoneData.searchTimezones(query);
        final usResults = allResults
            .where((tz) => tz['region'].toString().startsWith('US'))
            .toList();
        final otherResults = allResults
            .where((tz) => !tz['region'].toString().startsWith('US'))
            .toList();
        _filteredTimezones = [...usResults, ...otherResults];
      }
    });
  }

  void _selectTimezone(Map<String, dynamic> timezone) async {
    setState(() {
      _selectedTimezone = timezone['city']?.toString();
    });

    // Save timezone but don't complete onboarding yet
    final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
    await onboardingDataSource.setUserTimezone(_selectedTimezone!);

    // Auto-advance after selection
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onContinue();
      }
    });
  }

  void _completeOnboarding() async {
    if (_selectedTimezone != null) {
      // Save timezone but don't complete onboarding yet - let the flow continue
      final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
      await onboardingDataSource.setUserTimezone(_selectedTimezone!);

      // Continue to next page in flow
      if (mounted) {
        widget.onContinue();
      }
    }
  }

  void _useCurrentLocation() async {
    if (_nearestTimezone != null) {
      // Save timezone
      final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
      await onboardingDataSource.setUserTimezone(
        _nearestTimezone!['city']?.toString() ?? '',
      );

      _selectTimezone(_nearestTimezone!);
    }
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
          // Background with beige gradient (matching login/splash)
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
          // Geometric shapes for visual interest (matching login/splash)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFF8B7355).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2C2C2C).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: isSmallScreen ? 12 : (isMediumScreen ? 16 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isSmallScreen ? 25 : (isMediumScreen ? 35 : 45),
                  ),

                  // Icon with beige theme
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7355).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.public,
                      color: const Color(0xFF8B7355),
                      size: isSmallScreen ? 26 : 30,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                  ),

                  // Title with dark text for beige background
                  Text(
                    'What do you call home?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 26 : (isMediumScreen ? 29 : 32),
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF2C2C2C,
                      ), // Dark text for beige background
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 10),

                  Text(
                    'Select your primary residence timezone. This helps us calculate your circadian rhythm.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                      color: Color(
                        0xFF5A5A5A,
                      ), // Medium gray for beige background
                      height: 1.3,
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
                  ),

                  // Current Location Card with beige theme
                  if (_currentPosition != null && _nearestTimezone != null) ...[
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8B7355).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: const Color(0xFF8B7355),
                                size: isSmallScreen ? 16 : 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Location',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B7355),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nearestTimezone!['city']?.toString() ??
                                          '',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${_nearestTimezone!['region']} • ${_nearestTimezone!['code']} • GMT${_nearestTimezone!['offset']}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 6),
                                    // Current time for this location
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 8 : 10,
                                        vertical: isSmallScreen ? 4 : 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF8B7355,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: const Color(0xFF8B7355),
                                            size: isSmallScreen ? 12 : 14,
                                          ),
                                          SizedBox(
                                            width: isSmallScreen ? 4 : 6,
                                          ),
                                          Text(
                                            _getCurrentTimeForTimezone(
                                              _nearestTimezone!,
                                            ),
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 12 : 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF8B7355),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: isSmallScreen ? 36 : 40,
                                child: ElevatedButton(
                                  onPressed: _useCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B7355),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Use This',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                  ] else if (_isLoadingLocation) ...[
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: isSmallScreen ? 16 : 18,
                            height: isSmallScreen ? 16 : 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF8B7355),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Getting your location...',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                  ],

                  // Search bar with beige theme
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 16,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterTimezones,
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search US city or timezone',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
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
                              color: Color(0xFF9CA3AF),
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
                  ),

                  // Section header with beige theme
                  if (!_isSearching) ...[
                    Text(
                      'POPULAR US CITIES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Color(0xFF8B7355),
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
                        color: Color(0xFF8B7355),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],

                  // Timezone grid with beige theme
                  if (_filteredTimezones.isEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Color(0xFF9CA3AF),
                            size: isSmallScreen ? 32 : 40,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No cities found',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            'Try searching for a different US city or timezone',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Color(0xFF6B7280),
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
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF8B7355,
                                    ).withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8B7355)
                                    : Color(0xFFE5E7EB),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          0xFF8B7355,
                                        ).withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color(0xFF8B7355),
                                      size: isSmallScreen ? 14 : 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tz['city']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C2C2C),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: const Color(0xFF8B7355),
                                        size: isSmallScreen ? 16 : 18,
                                      ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 3 : 4),
                                Text(
                                  tz['region']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 6),
                                // Current time display
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 6 : 8,
                                    vertical: isSmallScreen ? 2 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8B7355,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: const Color(0xFF8B7355),
                                        size: isSmallScreen ? 10 : 12,
                                      ),
                                      SizedBox(width: isSmallScreen ? 3 : 4),
                                      Text(
                                        _getCurrentTimeForTimezone(tz),
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF8B7355),
                                        ),
                                      ),
                                    ],
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
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    Text(
                                      'GMT${tz['offset']?.toString() ?? ''}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8B7355),
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

                  // Continue button with beige theme
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 50 : 54,
                    child: ElevatedButton(
                      onPressed: _selectedTimezone != null
                          ? _completeOnboarding
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7355),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Color(0xFFE5E7EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: _selectedTimezone != null
                                ? Color(0xFF6D5B47)
                                : Color(0xFFD1D5DB),
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                        shadowColor: Color(0xFF8B7355).withValues(alpha: 0.3),
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

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Location info at bottom with beige theme
                  if (_currentPosition != null &&
                      _currentLocationText != null) ...[
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF8B7355),
                            size: isSmallScreen ? 14 : 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Location: $_currentLocationText',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
}
