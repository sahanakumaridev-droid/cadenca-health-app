import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/timezone_data_with_coords.dart';
import '../../services/google_places_service.dart';
import 'dart:math' as math;
import 'dart:async';

class ProfessionalTimezonePage extends StatefulWidget {
  final VoidCallback onContinue;

  const ProfessionalTimezonePage({super.key, required this.onContinue});

  @override
  State<ProfessionalTimezonePage> createState() =>
      _ProfessionalTimezonePageState();
}

class _ProfessionalTimezonePageState extends State<ProfessionalTimezonePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedTimezone;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // Can hold both local and Google results
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  bool _isLoadingSearch = false;
  Position? _currentPosition;
  String? _currentLocationText;
  Map<String, dynamic>? _nearestTimezone;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start with popular US cities
    _searchResults = TimezoneData.getPopularUSCities();

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Try to get current location
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocationText = 'Location services disabled';
        });
        return;
      }

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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

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

        Map<String, dynamic>? nearest = _findNearestUSTimezone(
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

  Map<String, dynamic>? _findNearestUSTimezone(double lat, double lng) {
    final usTimezones = TimezoneData.usTimezones;
    double minDistance = double.infinity;
    Map<String, dynamic>? nearest;

    for (var tz in usTimezones) {
      double distance = _calculateDistance(lat, lng, tz['lat'], tz['lng']);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = tz;
      }
    }

    if (minDistance > 500) {
      final allTimezones = TimezoneData.getAllTimezones();
      for (var tz in allTimezones) {
        double distance = _calculateDistance(lat, lng, tz['lat'], tz['lng']);
        if (distance < minDistance) {
          minDistance = distance;
          nearest = tz;
        }
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
    const double earthRadius = 6371;

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

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    // Cancel previous timer
    _searchTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = TimezoneData.getPopularUSCities();
        _isLoadingSearch = false;
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoadingSearch = true;
    });

    // Debounce search to avoid too many API calls
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      // First, search local database for quick results
      final localResults = TimezoneData.searchTimezones(query);
      final usResults = localResults
          .where((tz) => tz['region'].toString().startsWith('US'))
          .toList();
      final otherResults = localResults
          .where((tz) => !tz['region'].toString().startsWith('US'))
          .toList();

      // Combine local results (US first)
      List<dynamic> combinedResults = [...usResults, ...otherResults];

      // If we have few local results, fetch from Google Places
      if (combinedResults.length < 5) {
        try {
          final googleResults = await GooglePlacesService.getPlaceSuggestions(
            query,
          );

          // Convert Google results to our format for display
          final googleCities = googleResults
              .map(
                (place) => {
                  'city': place.mainText,
                  'region': place.secondaryText,
                  'code': 'TBD',
                  'offset': 'TBD',
                  'isGoogleResult': true,
                  'placeId': place.placeId,
                  'description': place.description,
                },
              )
              .toList();

          // Add Google results after local ones
          combinedResults.addAll(googleCities);
        } catch (e) {
          print('Google Places API error: $e');
          // Continue with local results only
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = combinedResults;
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoadingSearch = false;
        });
      }
    }
  }

  Future<void> _selectTimezone(dynamic item) async {
    if (item['isGoogleResult'] == true) {
      // Handle Google Places result
      setState(() {
        _isLoadingSearch = true;
      });

      try {
        final placeDetails = await GooglePlacesService.getPlaceDetails(
          item['placeId'],
        );
        if (placeDetails != null) {
          // Find nearest timezone based on coordinates
          final nearestTz = _findNearestUSTimezone(
            placeDetails.latitude,
            placeDetails.longitude,
          );
          if (nearestTz != null) {
            setState(() {
              _selectedTimezone = item['city'];
              _isLoadingSearch = false;
            });

            // Auto-advance after selection
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                widget.onContinue();
              }
            });
          }
        }
      } catch (e) {
        setState(() {
          _isLoadingSearch = false;
        });
      }
    } else {
      // Handle local timezone result
      setState(() {
        _selectedTimezone = item['city']?.toString();
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onContinue();
        }
      });
    }
  }

  void _useCurrentLocation() {
    if (_nearestTimezone != null) {
      _selectTimezone(_nearestTimezone!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1426),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1426), Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header with USA flag accent
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E40AF), Color(0xFFDC2626)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E40AF,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                'Select Your Timezone',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Main title
                    const Text(
                      'What do you call home?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Search any city worldwide. We\'ll automatically detect your timezone and optimize your circadian rhythm.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Current Location Card
                    if (_nearestTimezone != null && !_isLoadingLocation) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1E40AF).withValues(alpha: 0.2),
                              const Color(0xFF1E40AF).withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF1E40AF,
                            ).withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E40AF,
                              ).withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1E40AF,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Color(0xFF60A5FA),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Current Location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF60A5FA),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'GPS DETECTED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nearestTimezone!['city']?.toString() ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_nearestTimezone!['region']} • ${_nearestTimezone!['code']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1E40AF,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'GMT${_nearestTimezone!['offset']?.toString() ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF60A5FA),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _useCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E40AF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Use This',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else if (_isLoadingLocation) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF60A5FA),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Detecting your location...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Professional Search bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search any city worldwide...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                          prefixIcon: _isLoadingSearch
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF60A5FA),
                                          ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 24,
                                ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF1E40AF),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isSearching
                              ? 'SEARCH RESULTS (${_searchResults.length})'
                              : 'POPULAR US CITIES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Results list
                    if (_searchResults.isEmpty &&
                        _isSearching &&
                        !_isLoadingSearch) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cities found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final isSelected =
                              _selectedTimezone == item['city']?.toString();
                          final isGoogleResult = item['isGoogleResult'] == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _selectTimezone(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF1E40AF,
                                            ).withValues(alpha: 0.2),
                                            const Color(
                                              0xFF1E40AF,
                                            ).withValues(alpha: 0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1E40AF)
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF1E40AF,
                                            ).withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    // Clean design without icons
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['city']?.toString() ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['region']?.toString() ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    if (!isGoogleResult) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF1E40AF,
                                                ).withValues(alpha: 0.3)
                                              : Colors.white.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'GMT${item['offset']?.toString() ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF60A5FA)
                                                : Colors.white.withValues(
                                                    alpha: 0.7,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Continue button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedTimezone != null
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E40AF,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedTimezone != null
                            ? widget.onContinue
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTimezone != null
                              ? const Color(0xFF1E40AF)
                              : Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location info at bottom
                    if (_currentPosition != null &&
                        _currentLocationText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Location Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Detected: $_currentLocationText',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coordinates: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bottom safe area padding
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
