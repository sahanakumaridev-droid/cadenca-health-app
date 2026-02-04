import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/flight.dart';

class FlightPlanCard extends StatelessWidget {
  final Flight flight;
  final bool isPast;
  final bool isToday;

  const FlightPlanCard({
    super.key,
    required this.flight,
    this.isPast = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isToday
            ? Border.all(color: AppTheme.primaryGreen, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPast ? 0.05 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Flight header
          _buildFlightHeader(),

          // Day-by-day flow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildDayByDayFlow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.grey.withValues(alpha: 0.1)
            : isToday
            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
            : AppTheme.primaryGreen.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPast
                      ? Colors.grey.withValues(alpha: 0.2)
                      : AppTheme.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flight_takeoff,
                  color: isPast ? Colors.grey : AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.flightNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isPast ? Colors.grey : AppTheme.darkText,
                      ),
                    ),
                    Text(
                      '${flight.departureAirport} → ${flight.arrivalAirport}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? Colors.grey : AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Departure',
                  DateFormat('MMM dd, HH:mm').format(flight.departureTime),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildTimeInfo(
                  'Arrival',
                  DateFormat('MMM dd, HH:mm').format(flight.arrivalTime),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isPast ? Colors.grey : AppTheme.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPast ? Colors.grey : AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildDayByDayFlow() {
    // Mock data for now - in a real app, this would come from the flight analysis
    final recommendations = _generateMockRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Recommendations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isPast ? Colors.grey : AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => _buildRecommendationItem(rec)),
      ],
    );
  }

  Widget _buildRecommendationItem(Map<String, String> recommendation) {
    final icon = _getIconForRecommendation(recommendation['type']!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.grey.withValues(alpha: 0.1)
                  : AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isPast ? Colors.grey : AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : AppTheme.darkText,
                  ),
                ),
                if (recommendation['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    recommendation['description']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPast ? Colors.grey : AppTheme.lightText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForRecommendation(String type) {
    switch (type) {
      case 'wake_up':
        return Icons.alarm;
      case 'movement':
        return Icons.directions_walk;
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'light_exposure':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.lunch_dining;
      case 'nap':
        return Icons.bedtime;
      case 'dinner':
        return Icons.dinner_dining;
      case 'wind_down':
        return Icons.nightlight;
      default:
        return Icons.schedule;
    }
  }

  List<Map<String, String>> _generateMockRecommendations() {
    // This would be replaced with actual flight analysis data
    final departureHour = flight.departureTime.hour;
    final isEarlyFlight = departureHour < 8;
    final isLateFlight = departureHour > 20;

    List<Map<String, String>> recommendations = [];

    if (isEarlyFlight) {
      recommendations.addAll([
        {
          'type': 'wake_up',
          'title':
              'Wake up: ${DateFormat('HH:mm').format(flight.departureTime.subtract(const Duration(hours: 3)))}',
          'description': 'Early wake-up for morning flight preparation',
        },
        {
          'type': 'light_exposure',
          'title': 'Light exposure: Bright light immediately upon waking',
          'description': 'Help maintain circadian rhythm',
        },
        {
          'type': 'breakfast',
          'title': 'Breakfast: Light meal 2 hours before departure',
          'description': 'Avoid heavy foods before flying',
        },
      ]);
    } else if (isLateFlight) {
      recommendations.addAll([
        {
          'type': 'wake_up',
          'title':
              'Wake up: ${DateFormat('HH:mm').format(flight.departureTime.subtract(const Duration(hours: 8)))}',
          'description': 'Normal wake time for evening flight',
        },
        {
          'type': 'breakfast',
          'title': 'Breakfast: Regular morning meal',
          'description': 'Maintain normal eating schedule',
        },
        {
          'type': 'lunch',
          'title':
              'Lunch: ${DateFormat('HH:mm').format(flight.departureTime.subtract(const Duration(hours: 4)))}',
          'description': 'Light lunch before travel',
        },
        {
          'type': 'nap',
          'title': 'Optional nap: 20-30 minutes if needed',
          'description': 'Short power nap to maintain alertness',
        },
      ]);
    } else {
      recommendations.addAll([
        {
          'type': 'wake_up',
          'title':
              'Wake up: ${DateFormat('HH:mm').format(flight.departureTime.subtract(const Duration(hours: 6)))}',
          'description': 'Standard wake time for midday flight',
        },
        {
          'type': 'breakfast',
          'title': 'Breakfast: Regular morning meal',
          'description': 'Balanced breakfast to start the day',
        },
        {
          'type': 'movement',
          'title': 'Movement: Light exercise or walk',
          'description': 'Stay active before travel',
        },
        {
          'type': 'lunch',
          'title':
              'Lunch: ${DateFormat('HH:mm').format(flight.departureTime.subtract(const Duration(hours: 2)))}',
          'description': 'Light meal before departure',
        },
      ]);
    }

    // Add common recommendations
    recommendations.addAll([
      {
        'type': 'movement',
        'title': 'Movement: Arrive at airport early',
        'description': 'Allow time for check-in and security',
      },
      {
        'type': 'wind_down',
        'title': 'Wind down: Prepare for destination timezone',
        'description': 'Adjust sleep schedule if crossing time zones',
      },
    ]);

    return recommendations;
  }
}
