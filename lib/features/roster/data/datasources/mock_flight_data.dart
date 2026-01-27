import '../../domain/entities/flight.dart';
import '../models/flight_schedule.dart';

class MockFlightData {
  static FlightSchedule getSampleSchedule() {
    final flights = [
      // September 1st - Amsterdam to Zagreb
      Flight(
        flightNumber: 'KL 1969',
        departureAirport: 'AMS',
        arrivalAirport: 'ZAG',
        departureTime: DateTime(2024, 9, 1, 19, 30),
        arrivalTime: DateTime(2024, 9, 1, 21, 40),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 10),
      ),

      // September 2nd - Zagreb to Amsterdam (Long layover example)
      Flight(
        flightNumber: 'KL 1968',
        departureAirport: 'ZAG',
        arrivalAirport: 'AMS',
        departureTime: DateTime(2024, 9, 2, 13, 50),
        arrivalTime: DateTime(2024, 9, 2, 16, 0),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 10),
      ),

      // September 3rd - Amsterdam to Rome
      Flight(
        flightNumber: 'KL 1605',
        departureAirport: 'AMS',
        arrivalAirport: 'FCO',
        departureTime: DateTime(2024, 9, 3, 8, 15),
        arrivalTime: DateTime(2024, 9, 3, 10, 45),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 30),
      ),

      // September 3rd - Rome to Amsterdam (Short layover example)
      Flight(
        flightNumber: 'KL 1606',
        departureAirport: 'FCO',
        arrivalAirport: 'AMS',
        departureTime: DateTime(2024, 9, 3, 12, 30),
        arrivalTime: DateTime(2024, 9, 3, 15, 0),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 30),
      ),

      // September 4th - Amsterdam to Barcelona
      Flight(
        flightNumber: 'KL 1673',
        departureAirport: 'AMS',
        arrivalAirport: 'BCN',
        departureTime: DateTime(2024, 9, 4, 14, 20),
        arrivalTime: DateTime(2024, 9, 4, 16, 35),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 15),
      ),

      // September 4th - Barcelona to Amsterdam (Quick turnaround example)
      Flight(
        flightNumber: 'KL 1674',
        departureAirport: 'BCN',
        arrivalAirport: 'AMS',
        departureTime: DateTime(2024, 9, 4, 17, 25),
        arrivalTime: DateTime(2024, 9, 4, 19, 40),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 2, minutes: 15),
      ),

      // September 5th - Amsterdam to London
      Flight(
        flightNumber: 'KL 1007',
        departureAirport: 'AMS',
        arrivalAirport: 'LHR',
        departureTime: DateTime(2024, 9, 5, 11, 45),
        arrivalTime: DateTime(2024, 9, 5, 12, 0),
        departureTimezone: 'CET',
        arrivalTimezone: 'GMT',
        flightDuration: const Duration(hours: 1, minutes: 15),
      ),

      // September 6th - London to Amsterdam (Overnight layover example)
      Flight(
        flightNumber: 'KL 1008',
        departureAirport: 'LHR',
        arrivalAirport: 'AMS',
        departureTime: DateTime(2024, 9, 6, 14, 15),
        arrivalTime: DateTime(2024, 9, 6, 16, 30),
        departureTimezone: 'GMT',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 1, minutes: 15),
      ),

      // September 7th - Amsterdam to Milan
      Flight(
        flightNumber: 'KL 1615',
        departureAirport: 'AMS',
        arrivalAirport: 'MXP',
        departureTime: DateTime(2024, 9, 7, 9, 30),
        arrivalTime: DateTime(2024, 9, 7, 11, 15),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 1, minutes: 45),
      ),

      // September 7th - Milan to Amsterdam
      Flight(
        flightNumber: 'KL 1616',
        departureAirport: 'MXP',
        arrivalAirport: 'AMS',
        departureTime: DateTime(2024, 9, 7, 13, 0),
        arrivalTime: DateTime(2024, 9, 7, 14, 45),
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: const Duration(hours: 1, minutes: 45),
      ),
    ];

    return FlightSchedule(
      flights: flights,
      pilotName: 'Captain Sarah Johnson',
      scheduleStartDate: DateTime(2024, 9, 1),
      scheduleEndDate: DateTime(2024, 9, 7),
    );
  }

  static Map<String, String> getAirportNames() {
    return {
      'AMS': 'Amsterdam Schiphol',
      'ZAG': 'Zagreb',
      'FCO': 'Rome Fiumicino',
      'BCN': 'Barcelona',
      'LHR': 'London Heathrow',
      'MXP': 'Milan Malpensa',
      'CTA': 'Catania',
    };
  }

  static Map<String, String> getCountryFlags() {
    return {
      'AMS': '🇳🇱',
      'ZAG': '🇭🇷',
      'FCO': '🇮🇹',
      'BCN': '🇪🇸',
      'LHR': '🇬🇧',
      'MXP': '🇮🇹',
      'CTA': '🇮🇹',
    };
  }
}
