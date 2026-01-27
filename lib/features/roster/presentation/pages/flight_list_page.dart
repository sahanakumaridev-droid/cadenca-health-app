import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/flight.dart';
import '../../data/models/flight_schedule.dart';
import '../../data/datasources/mock_flight_data.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_state.dart';
import '../../../../core/router/app_router.dart';

class FlightListPage extends StatefulWidget {
  const FlightListPage({super.key});

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  late FlightSchedule _schedule;
  final Map<String, String> _airportNames = MockFlightData.getAirportNames();
  final Map<String, String> _countryFlags = MockFlightData.getCountryFlags();

  @override
  void initState() {
    super.initState();
    _schedule = FlightSchedule(
      flights: [],
      pilotName: 'Captain',
      scheduleStartDate: DateTime.now(),
      scheduleEndDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RosterBloc, RosterState>(
      builder: (context, state) {
        if (state is RosterProcessed) {
          _schedule = FlightSchedule(
            flights: state.flights,
            pilotName: 'Captain',
            scheduleStartDate: state.flights.isNotEmpty
                ? state.flights.first.departureTime
                : DateTime.now(),
            scheduleEndDate: state.flights.isNotEmpty
                ? state.flights.last.arrivalTime
                : DateTime.now().add(const Duration(days: 7)),
          );
        }

        return _buildScaffold(state);
      },
    );
  }

  Widget _buildScaffold(RosterState state) {
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
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RosterState state) {
    if (state is RosterInitial) {
      return _buildNoDataState();
    } else if (state is RosterError) {
      return _buildErrorState(state.message);
    } else if (_schedule.flights.isEmpty) {
      return _buildNoDataState();
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleHeader(),
            const SizedBox(height: 24),
            _buildFlightsList(),
          ],
        ),
      );
    }
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flight_takeoff,
                size: 60,
                color: Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Flight Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your roster to see flight analysis and sleep recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push(AppRouter.rosterUpload),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Upload Roster',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Flights',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push(AppRouter.rosterUpload),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
              'Flight Schedule',
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

  Widget _buildScheduleHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy');

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Color(0xFF14B8A6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _schedule.pilotName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(_schedule.scheduleStartDate)} - ${dateFormat.format(_schedule.scheduleEndDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Total Flights',
                '${_schedule.flights.length}',
                Icons.flight,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Available',
                '${_schedule.flights.where((f) => _schedule.canAnalyze(f)).length}',
                Icons.info_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
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
          children: [
            Icon(icon, color: const Color(0xFF14B8A6), size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightsList() {
    final sortedFlights = _schedule.sortedFlights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Flights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedFlights.asMap().entries.map((entry) {
          final index = entry.key;
          final flight = entry.value;
          final nextFlight = _schedule.getNextFlight(flight);
          final canAnalyze = nextFlight != null;

          return _buildFlightCard(flight, nextFlight, canAnalyze, index);
        }),
      ],
    );
  }

  Widget _buildFlightCard(
    Flight flight,
    Flight? nextFlight,
    bool canAnalyze,
    int index,
  ) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEE, MMM dd');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canAnalyze
              ? () => _navigateToAnalysis(flight, nextFlight!)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        flight.flightNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14B8A6),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (canAnalyze)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Last Flight',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAirportInfo(
                        flight.departureAirport,
                        timeFormat.format(flight.departureTime),
                        dateFormat.format(flight.departureTime),
                        'Departure',
                        true,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${flight.flightDuration.inHours}h ${flight.flightDuration.inMinutes % 60}m',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildAirportInfo(
                        flight.arrivalAirport,
                        timeFormat.format(flight.arrivalTime),
                        dateFormat.format(flight.arrivalTime),
                        'Arrival',
                        false,
                      ),
                    ),
                  ],
                ),
                if (nextFlight != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                        Icon(
                          Icons.schedule,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Next: ${nextFlight.flightNumber} at ${timeFormat.format(nextFlight.departureTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getLayoverDuration(flight, nextFlight),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (canAnalyze) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Tap to view flight details',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAirportInfo(
    String code,
    String time,
    String date,
    String label,
    bool isDeparture,
  ) {
    final airportName = _airportNames[code] ?? code;
    final flag = _countryFlags[code] ?? '';

    return Column(
      crossAxisAlignment: isDeparture
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDeparture) ...[
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              code,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isDeparture) ...[
              const SizedBox(width: 4),
              Text(flag, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          airportName,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: isDeparture ? TextAlign.start : TextAlign.end,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF14B8A6),
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getLayoverDuration(Flight currentFlight, Flight nextFlight) {
    final layover = nextFlight.departureTime.difference(
      currentFlight.arrivalTime,
    );
    final hours = layover.inHours;
    final minutes = layover.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m layover';
    } else {
      return '${minutes}m layover';
    }
  }

  void _navigateToAnalysis(Flight selectedFlight, Flight nextFlight) {
    // Navigate to enhanced sleep scientist analysis page
    context.push(
      '${AppRouter.enhancedFlightAnalysis}?flightNumber=${selectedFlight.flightNumber}&departureTime=${selectedFlight.departureTime.millisecondsSinceEpoch}',
    );
  }
}
