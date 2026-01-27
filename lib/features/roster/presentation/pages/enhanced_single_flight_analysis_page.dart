import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/sleep_analysis.dart';
import '../../services/sleep_scientist_service.dart';
import '../../data/datasources/mock_flight_data.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_state.dart';

class EnhancedSingleFlightAnalysisPage extends StatefulWidget {
  final String? flightNumber;
  final String? departureTime;

  const EnhancedSingleFlightAnalysisPage({
    super.key,
    this.flightNumber,
    this.departureTime,
  });

  @override
  State<EnhancedSingleFlightAnalysisPage> createState() =>
      _EnhancedSingleFlightAnalysisPageState();
}

class _EnhancedSingleFlightAnalysisPageState
    extends State<EnhancedSingleFlightAnalysisPage> {
  late Flight _selectedFlight;
  Flight? _nextFlight;
  late SleepAnalysis _sleepAnalysis;
  List<Flight> _realFlights = [];
  final Map<String, String> _airportNames = MockFlightData.getAirportNames();
  final Map<String, String> _countryFlags = MockFlightData.getCountryFlags();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Get real flights from RosterBloc
    final rosterState = context.read<RosterBloc>().state;
    if (rosterState is RosterProcessed) {
      _realFlights = rosterState.flights;
      print(
        'EnhancedSingleFlightAnalysisPage: Using ${_realFlights.length} real flights',
      );
    } else {
      print(
        'EnhancedSingleFlightAnalysisPage: No real flights found, using mock data',
      );
      _realFlights = MockFlightData.getSampleSchedule().flights;
    }

    _selectedFlight = _getSelectedFlight();
    _nextFlight = _getNextFlight();
    _sleepAnalysis = SleepScientistService.analyzeFlight(
      _selectedFlight,
      nextFlight: _nextFlight,
    );
  }

  Flight _getSelectedFlight() {
    // If parameters are provided, find the specific flight
    if (widget.flightNumber != null && widget.departureTime != null) {
      try {
        final departureTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.departureTime!),
        );

        try {
          // Search in real flights first
          return _realFlights.firstWhere(
            (f) =>
                f.flightNumber == widget.flightNumber! &&
                f.departureTime == departureTime,
          );
        } catch (e) {
          // If not found in real flights, try by flight number only
          try {
            return _realFlights.firstWhere(
              (f) => f.flightNumber == widget.flightNumber!,
            );
          } catch (e) {
            print('Flight not found, using first available flight');
          }
        }
      } catch (e) {
        print('Error parsing flight parameters: $e');
      }
    }

    // Fallback to first flight
    return _realFlights.isNotEmpty ? _realFlights.first : _getDefaultFlight();
  }

  Flight? _getNextFlight() {
    if (_realFlights.length >= 2) {
      final currentIndex = _realFlights.indexOf(_selectedFlight);
      if (currentIndex != -1 && currentIndex < _realFlights.length - 1) {
        return _realFlights[currentIndex + 1];
      }
    }
    return null;
  }

  Flight _getDefaultFlight() {
    return Flight(
      flightNumber: 'KL 1969',
      departureAirport: 'AMS',
      arrivalAirport: 'ZAG',
      departureTime: DateTime(2024, 9, 1, 19, 30),
      arrivalTime: DateTime(2024, 9, 1, 21, 40),
      departureTimezone: 'CET',
      arrivalTimezone: 'CET',
      flightDuration: const Duration(hours: 2, minutes: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFlightHeader(),
                      const SizedBox(height: 24),
                      _buildLayoverSummary(),
                      const SizedBox(height: 24),
                      _buildSleepRecommendations(),
                      const SizedBox(height: 24),
                      _buildMealRecommendations(),
                      const SizedBox(height: 24),
                      _buildMovementRecommendations(),
                      const SizedBox(height: 24),
                      if (_sleepAnalysis.napRecommendations.isNotEmpty)
                        _buildNapRecommendations(),
                      if (_sleepAnalysis.napRecommendations.isNotEmpty)
                        const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRouter.home),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Sleep Scientist Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF14B8A6).withValues(alpha: 0.2),
            const Color(0xFF14B8A6).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedFlight.flightNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAirportColumn(
                  _selectedFlight.departureAirport,
                  'Departure',
                  true,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedFlight.flightDuration.inHours}h ${_selectedFlight.flightDuration.inMinutes % 60}m',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildAirportColumn(
                  _selectedFlight.arrivalAirport,
                  'Arrival',
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirportColumn(
    String airportCode,
    String label,
    bool isDeparture,
  ) {
    final airportName = _airportNames[airportCode] ?? airportCode;
    final flag = _countryFlags[airportCode] ?? '';
    final time = isDeparture
        ? _selectedFlight.departureTime
        : _selectedFlight.arrivalTime;
    final timeFormat = DateFormat('HH:mm');

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isDeparture) ...[
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
            ],
            Text(
              airportCode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isDeparture) ...[
              const SizedBox(width: 6),
              Text(flag, style: const TextStyle(fontSize: 20)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          airportName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          timeFormat.format(time),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14B8A6),
          ),
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(time),
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoverSummary() {
    if (_nextFlight == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Single Flight Analysis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Individual flight with sleep scientist recommendations',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final hours = _sleepAnalysis.layoverDuration.inHours;
    final minutes = _sleepAnalysis.layoverDuration.inMinutes % 60;

    Color layoverColor;
    IconData layoverIcon;
    String layoverDescription;

    if (hours >= 12) {
      layoverColor = const Color(0xFF14B8A6);
      layoverIcon = Icons.nights_stay;
      layoverDescription = 'Overnight Layover';
    } else if (hours >= 8) {
      layoverColor = Colors.green;
      layoverIcon = Icons.hotel;
      layoverDescription = 'Long Layover';
    } else if (hours >= 4) {
      layoverColor = Colors.orange;
      layoverIcon = Icons.schedule;
      layoverDescription = 'Medium Layover';
    } else {
      layoverColor = Colors.red;
      layoverIcon = Icons.speed;
      layoverDescription = 'Quick Turnaround';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            layoverColor.withValues(alpha: 0.2),
            layoverColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: layoverColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: layoverColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(layoverIcon, color: layoverColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layoverDescription,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: layoverColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hours}h ${minutes}m until next flight',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next: ${_nextFlight!.flightNumber} to ${_nextFlight!.arrivalAirport}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime, color: Color(0xFF8B5CF6), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Sleep Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sleepAnalysis.sleepRecommendations.map(
            (rec) => _buildSleepCard(rec),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(SleepRecommendation rec) {
    final timeFormat = DateFormat('HH:mm');

    Color typeColor;
    IconData typeIcon;

    switch (rec.type) {
      case SleepType.mainSleep:
        typeColor = const Color(0xFF8B5CF6);
        typeIcon = Icons.hotel;
        break;
      case SleepType.strategicNap:
        typeColor = Colors.blue;
        typeIcon = Icons.power_settings_new;
        break;
      case SleepType.rest:
        typeColor = Colors.orange;
        typeIcon = Icons.self_improvement;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, color: typeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                rec.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              const Spacer(),
              Text(
                '${rec.duration.inHours}h ${rec.duration.inMinutes % 60}m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local Time',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${timeFormat.format(rec.localTime)} - ${timeFormat.format(rec.endTime)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Home Time (PT)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${timeFormat.format(rec.homeTime)} - ${timeFormat.format(rec.homeTime.add(rec.duration))}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rec.recommendation,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Meal Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sleepAnalysis.mealRecommendations.map(
            (meal) => _buildMealCard(meal),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealRecommendation meal) {
    final timeFormat = DateFormat('HH:mm');

    IconData mealIcon;
    Color mealColor;

    switch (meal.type) {
      case MealType.breakfast:
        mealIcon = Icons.free_breakfast;
        mealColor = const Color(0xFFF59E0B);
        break;
      case MealType.lunch:
        mealIcon = Icons.lunch_dining;
        mealColor = const Color(0xFF10B981);
        break;
      case MealType.dinner:
        mealIcon = Icons.dinner_dining;
        mealColor = const Color(0xFF8B5CF6);
        break;
      case MealType.snack:
        mealIcon = Icons.local_cafe;
        mealColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mealColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mealColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(mealIcon, color: mealColor, size: 20),
              const SizedBox(width: 8),
              Text(
                meal.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: mealColor,
                ),
              ),
              const Spacer(),
              Text(
                timeFormat.format(meal.localTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meal.recommendation,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            meal.location,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Home Time: ${timeFormat.format(meal.homeTime)} (${meal.homeTimeType.name})',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_walk,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Movement & Light Exposure',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sleepAnalysis.movementRecommendations.map(
            (movement) => _buildMovementCard(movement),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard(MovementRecommendation movement) {
    final timeFormat = DateFormat('HH:mm');

    IconData movementIcon;
    Color movementColor;

    switch (movement.type) {
      case MovementType.lightExposure:
        movementIcon = Icons.wb_sunny;
        movementColor = const Color(0xFFF59E0B);
        break;
      case MovementType.exercise:
        movementIcon = Icons.fitness_center;
        movementColor = const Color(0xFF10B981);
        break;
      case MovementType.stretching:
        movementIcon = Icons.self_improvement;
        movementColor = const Color(0xFF8B5CF6);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: movementColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: movementColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(movementIcon, color: movementColor, size: 20),
              const SizedBox(width: 8),
              Text(
                movement.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: movementColor,
                ),
              ),
              const Spacer(),
              Text(
                '${timeFormat.format(movement.localTime)} (${movement.duration.inMinutes}min)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            movement.recommendation,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            movement.location,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNapRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.power_settings_new,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Optional Naps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sleepAnalysis.napRecommendations.map((nap) => _buildNapCard(nap)),
        ],
      ),
    );
  }

  Widget _buildNapCard(NapRecommendation nap) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.power_settings_new,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                nap.type.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              Text(
                '${timeFormat.format(nap.localTime)} (${nap.duration.inMinutes}min)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nap.recommendation,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sleep analysis saved to your profile'),
                  backgroundColor: Color(0xFF14B8A6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt, size: 20),
                SizedBox(width: 8),
                Text(
                  'Save Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminders set for all recommendations'),
                      backgroundColor: Color(0xFF14B8A6),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Set Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sleep analysis shared'),
                      backgroundColor: Color(0xFF14B8A6),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
