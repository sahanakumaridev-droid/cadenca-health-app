import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/flight_analysis.dart';
import '../../services/flight_analysis_service.dart';
import '../../data/models/flight_schedule.dart';
import '../../data/datasources/mock_flight_data.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_state.dart';

class FlightAnalysisPage extends StatefulWidget {
  final String? flightNumber;
  final String? departureTime;

  const FlightAnalysisPage({super.key, this.flightNumber, this.departureTime});

  @override
  State<FlightAnalysisPage> createState() => _FlightAnalysisPageState();
}

class _FlightAnalysisPageState extends State<FlightAnalysisPage> {
  late FlightAnalysis _analysis;
  late FlightSchedule _schedule;
  List<Flight> _realFlights = [];

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
        'FlightAnalysisPage: Using ${_realFlights.length} real flights',
      ); // Debug log
      _schedule = FlightSchedule(
        flights: _realFlights,
        pilotName: 'Captain',
        scheduleStartDate: _realFlights.isNotEmpty
            ? _realFlights.first.departureTime
            : DateTime.now(),
        scheduleEndDate: _realFlights.isNotEmpty
            ? _realFlights.last.arrivalTime
            : DateTime.now().add(const Duration(days: 7)),
      );
    } else {
      // Fallback to mock data if no real flights available
      print(
        'FlightAnalysisPage: No real flights found, using mock data',
      ); // Debug log
      _schedule = MockFlightData.getSampleSchedule();
      _realFlights = _schedule.flights;
    }

    _analysis = _createAnalysisFromParams();
  }

  FlightAnalysis _createAnalysisFromParams() {
    // If parameters are provided, find the specific flights
    if (widget.flightNumber != null && widget.departureTime != null) {
      try {
        final departureTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.departureTime!),
        );

        Flight firstFlight;
        try {
          // Search in real flights first
          firstFlight = _realFlights.firstWhere(
            (f) =>
                f.flightNumber == widget.flightNumber! &&
                f.departureTime == departureTime,
          );
        } catch (e) {
          // If not found in real flights, try by flight number only
          try {
            firstFlight = _realFlights.firstWhere(
              (f) => f.flightNumber == widget.flightNumber!,
            );
          } catch (e) {
            firstFlight = _getDefaultFirstFlight();
          }
        }

        final nextFlight = _getNextFlightFromReal(firstFlight);

        if (nextFlight != null) {
          return FlightAnalysisService.analyzeFlights(firstFlight, nextFlight);
        }
      } catch (e) {
        // If parsing fails, fall back to default
        print('Error parsing flight parameters: $e');
      }
    }

    // Fallback to default sample
    return _createSampleAnalysis();
  }

  Flight? _getNextFlightFromReal(Flight currentFlight) {
    // Find the next flight in the real flights list
    final currentIndex = _realFlights.indexOf(currentFlight);
    if (currentIndex != -1 && currentIndex < _realFlights.length - 1) {
      return _realFlights[currentIndex + 1];
    }
    return null;
  }

  Flight _getDefaultFirstFlight() {
    if (_realFlights.isNotEmpty) {
      return _realFlights.first;
    }
    return _schedule.sortedFlights.first;
  }

  FlightAnalysis _createSampleAnalysis() {
    // Use real flights if available
    if (_realFlights.length >= 2) {
      return FlightAnalysisService.analyzeFlights(
        _realFlights[0],
        _realFlights[1],
      );
    }

    // Fallback to mock example if no real flights
    final flight1 = Flight(
      flightNumber: 'KL 1969',
      departureAirport: 'AMS',
      arrivalAirport: 'ZAG',
      departureTime: DateTime(2024, 9, 1, 19, 30),
      arrivalTime: DateTime(2024, 9, 1, 21, 40),
      departureTimezone: 'CET',
      arrivalTimezone: 'CET',
      flightDuration: const Duration(hours: 2, minutes: 10),
    );

    final flight2 = Flight(
      flightNumber: 'KL 1968',
      departureAirport: 'ZAG',
      arrivalAirport: 'AMS',
      departureTime: DateTime(2024, 9, 2, 13, 50),
      arrivalTime: DateTime(2024, 9, 2, 16, 0),
      departureTimezone: 'CET',
      arrivalTimezone: 'CET',
      flightDuration: const Duration(hours: 2, minutes: 10),
    );

    return FlightAnalysisService.analyzeFlights(flight1, flight2);
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
                      _buildFlightOverview(),
                      const SizedBox(height: 24),
                      _buildLayoverSummary(),
                      const SizedBox(height: 24),
                      _buildSleepAnalysis(),
                      const SizedBox(height: 24),
                      _buildMealAnalysis(),
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
              'Flight Analysis',
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

  Widget _buildFlightOverview() {
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
          const Text(
            'Flight Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildFlightCard(_analysis.firstFlight, 'First Flight'),
          const SizedBox(height: 12),
          _buildFlightCard(_analysis.secondFlight, 'Next Flight'),
        ],
      ),
    );
  }

  Widget _buildFlightCard(Flight flight, String label) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            children: [
              Text(
                flight.flightNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14B8A6),
                ),
              ),
              const Spacer(),
              Text(
                '${flight.departureAirport} → ${flight.arrivalAirport}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Departure',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    timeFormat.format(flight.departureTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateFormat.format(flight.departureTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.flight_takeoff,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Arrival',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    timeFormat.format(flight.arrivalTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateFormat.format(flight.arrivalTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayoverSummary() {
    final hours = _analysis.layoverDuration.inHours;
    final minutes = _analysis.layoverDuration.inMinutes % 60;

    Color layoverColor;
    IconData layoverIcon;
    String layoverDescription;

    switch (_analysis.layoverType) {
      case LayoverType.quickTurnaround:
        layoverColor = Colors.red;
        layoverIcon = Icons.speed;
        layoverDescription = 'Quick Turnaround';
        break;
      case LayoverType.shortLayover:
        layoverColor = Colors.orange;
        layoverIcon = Icons.schedule;
        layoverDescription = 'Short Layover';
        break;
      case LayoverType.longLayover:
        layoverColor = Colors.green;
        layoverIcon = Icons.hotel;
        layoverDescription = 'Long Layover';
        break;
      case LayoverType.overnight:
        layoverColor = const Color(0xFF14B8A6);
        layoverIcon = Icons.nights_stay;
        layoverDescription = 'Overnight Stay';
        break;
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
                  '${hours}h ${minutes}m between flights',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepAnalysis() {
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
                'Sleep Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSleepQualityIndicator(),
          const SizedBox(height: 16),
          if (_analysis.sleepWindow.duration.inMinutes > 0) ...[
            _buildSleepTimeWindow(),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _analysis.sleepWindow.recommendation,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityIndicator() {
    Color qualityColor;
    String qualityText;
    double qualityValue;

    switch (_analysis.sleepWindow.quality) {
      case SleepQuality.none:
        qualityColor = Colors.red;
        qualityText = 'No Sleep Possible';
        qualityValue = 0.0;
        break;
      case SleepQuality.poor:
        qualityColor = Colors.orange;
        qualityText = 'Poor Sleep Quality';
        qualityValue = 0.2;
        break;
      case SleepQuality.fair:
        qualityColor = Colors.yellow;
        qualityText = 'Fair Sleep Quality';
        qualityValue = 0.4;
        break;
      case SleepQuality.good:
        qualityColor = Colors.lightGreen;
        qualityText = 'Good Sleep Quality';
        qualityValue = 0.7;
        break;
      case SleepQuality.excellent:
        qualityColor = Colors.green;
        qualityText = 'Excellent Sleep Quality';
        qualityValue = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              qualityText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: qualityColor,
              ),
            ),
            if (_analysis.sleepWindow.duration.inMinutes > 0)
              Text(
                '${_analysis.sleepWindow.duration.inHours}h ${_analysis.sleepWindow.duration.inMinutes % 60}m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: qualityValue,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildSleepTimeWindow() {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep Window',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${timeFormat.format(_analysis.sleepWindow.startTime)} - ${timeFormat.format(_analysis.sleepWindow.endTime)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.access_time, color: Color(0xFF8B5CF6), size: 20),
        ],
      ),
    );
  }

  Widget _buildMealAnalysis() {
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
                'Meal Opportunities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._analysis.mealWindows.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealWindow meal) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mealColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(mealIcon, color: mealColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meal.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mealColor,
                      ),
                    ),
                    Text(
                      timeFormat.format(meal.time),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meal.recommendation,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  meal.location,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
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
              // TODO: Save analysis to user's schedule
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analysis saved to your schedule'),
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
                  'Save to Schedule',
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
                  // TODO: Analyze different flights
                  setState(() {
                    _analysis = _createAlternativeAnalysis();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Different Flights',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Share analysis
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analysis shared successfully'),
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

  FlightAnalysis _createAlternativeAnalysis() {
    // Use real flights if available for alternative analysis
    if (_realFlights.length >= 4) {
      // Use different flights from the real data
      return FlightAnalysisService.analyzeFlights(
        _realFlights[2],
        _realFlights[3],
      );
    } else if (_realFlights.length >= 2) {
      // Use the same real flights but different analysis
      return FlightAnalysisService.analyzeFlights(
        _realFlights[1],
        _realFlights[0],
      );
    }

    // Fallback to mock example
    final flight1 = Flight(
      flightNumber: 'KL 1671',
      departureAirport: 'AMS',
      arrivalAirport: 'CTA',
      departureTime: DateTime(2024, 9, 7, 12, 30),
      arrivalTime: DateTime(2024, 9, 7, 14, 4),
      departureTimezone: 'CET',
      arrivalTimezone: 'CET',
      flightDuration: const Duration(hours: 1, minutes: 34),
    );

    final flight2 = Flight(
      flightNumber: 'KL 1672',
      departureAirport: 'CTA',
      arrivalAirport: 'AMS',
      departureTime: DateTime(2024, 9, 7, 14, 58),
      arrivalTime: DateTime(2024, 9, 7, 16, 32),
      departureTimezone: 'CET',
      arrivalTimezone: 'CET',
      flightDuration: const Duration(hours: 1, minutes: 34),
    );

    return FlightAnalysisService.analyzeFlights(flight1, flight2);
  }
}
