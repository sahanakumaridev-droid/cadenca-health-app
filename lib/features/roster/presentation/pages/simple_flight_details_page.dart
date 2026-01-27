import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/flight.dart';
import '../../data/datasources/mock_flight_data.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_state.dart';

class SimpleFlightDetailsPage extends StatefulWidget {
  final String? flightNumber;
  final String? departureTime;

  const SimpleFlightDetailsPage({
    super.key,
    this.flightNumber,
    this.departureTime,
  });

  @override
  State<SimpleFlightDetailsPage> createState() =>
      _SimpleFlightDetailsPageState();
}

class _SimpleFlightDetailsPageState extends State<SimpleFlightDetailsPage> {
  late Flight _selectedFlight;
  List<Flight> _realFlights = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final rosterState = context.read<RosterBloc>().state;
    if (rosterState is RosterProcessed) {
      _realFlights = rosterState.flights;
    } else {
      _realFlights = MockFlightData.getSampleSchedule().flights;
    }

    _selectedFlight = _getSelectedFlight();
  }

  Flight _getSelectedFlight() {
    if (widget.flightNumber != null && widget.departureTime != null) {
      try {
        final departureTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.departureTime!),
        );

        try {
          return _realFlights.firstWhere(
            (f) =>
                f.flightNumber == widget.flightNumber! &&
                f.departureTime == departureTime,
          );
        } catch (e) {
          return _realFlights.firstWhere(
            (f) => f.flightNumber == widget.flightNumber!,
          );
        }
      } catch (e) {
        // Error parsing
      }
    }

    return _realFlights.isNotEmpty
        ? _realFlights.first
        : Flight(
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Flight Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedFlight.flightNumber,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14B8A6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              _selectedFlight.departureAirport,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'HH:mm',
                              ).format(_selectedFlight.departureTime),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.flight_takeoff,
                          color: Colors.white,
                          size: 32,
                        ),
                        Column(
                          children: [
                            Text(
                              _selectedFlight.arrivalAirport,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'HH:mm',
                              ).format(_selectedFlight.arrivalTime),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flight Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Duration',
                        '${_selectedFlight.flightDuration.inHours}h ${_selectedFlight.flightDuration.inMinutes % 60}m',
                      ),
                      _buildInfoRow(
                        'Departure',
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(_selectedFlight.departureTime),
                      ),
                      _buildInfoRow(
                        'Arrival',
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(_selectedFlight.arrivalTime),
                      ),
                      _buildInfoRow(
                        'Route',
                        '${_selectedFlight.departureAirport} → ${_selectedFlight.arrivalAirport}',
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
