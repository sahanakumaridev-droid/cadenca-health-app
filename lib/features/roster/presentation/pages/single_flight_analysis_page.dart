import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/navigation_helper.dart';
import '../../domain/entities/flight.dart';
import '../../data/datasources/mock_flight_data.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_state.dart';

class SingleFlightAnalysisPage extends StatefulWidget {
  final String? flightNumber;
  final String? departureTime;

  const SingleFlightAnalysisPage({
    super.key,
    this.flightNumber,
    this.departureTime,
  });

  @override
  State<SingleFlightAnalysisPage> createState() =>
      _SingleFlightAnalysisPageState();
}

class _SingleFlightAnalysisPageState extends State<SingleFlightAnalysisPage> {
  late Flight _selectedFlight;
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
    } else {
      _realFlights = MockFlightData.getSampleSchedule().flights;
    }

    _selectedFlight = _getSelectedFlight();
  }

  Flight _getSelectedFlight() {
    // If parameters are provided, find the specific flight
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
          try {
            return _realFlights.firstWhere(
              (f) => f.flightNumber == widget.flightNumber!,
            );
          } catch (e) {
            // Flight not found, use first available
          }
        }
      } catch (e) {
        // Error parsing parameters
      }
    }

    // Fallback to first flight
    return _realFlights.isNotEmpty ? _realFlights.first : _getDefaultFlight();
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
                      _buildFlightDetails(),
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
          NavigationHelper.buildBackButton(context),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Flight Details',
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

  Widget _buildFlightDetails() {
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
            'Flight Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Flight Number', _selectedFlight.flightNumber),
          _buildDetailRow(
            'Route',
            '${_selectedFlight.departureAirport} → ${_selectedFlight.arrivalAirport}',
          ),
          _buildDetailRow(
            'Duration',
            '${_selectedFlight.flightDuration.inHours}h ${_selectedFlight.flightDuration.inMinutes % 60}m',
          ),
          _buildDetailRow(
            'Departure Timezone',
            _selectedFlight.departureTimezone,
          ),
          _buildDetailRow('Arrival Timezone', _selectedFlight.arrivalTimezone),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Flight added to calendar'),
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
                Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add to Calendar',
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
                      content: Text(
                        'Reminder set for 2 hours before departure',
                      ),
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
                      'Set Reminder',
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
                      content: Text('Flight details shared'),
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
