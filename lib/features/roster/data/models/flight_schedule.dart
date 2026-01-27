import '../../domain/entities/flight.dart';

class FlightSchedule {
  final List<Flight> flights;
  final String pilotName;
  final DateTime scheduleStartDate;
  final DateTime scheduleEndDate;

  const FlightSchedule({
    required this.flights,
    required this.pilotName,
    required this.scheduleStartDate,
    required this.scheduleEndDate,
  });

  List<Flight> get sortedFlights {
    final sorted = List<Flight>.from(flights);
    sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    return sorted;
  }

  Flight? getNextFlight(Flight currentFlight) {
    final sorted = sortedFlights;
    final currentIndex = sorted.indexWhere(
      (f) =>
          f.flightNumber == currentFlight.flightNumber &&
          f.departureTime == currentFlight.departureTime,
    );

    if (currentIndex == -1 || currentIndex == sorted.length - 1) {
      return null; // No next flight
    }

    return sorted[currentIndex + 1];
  }

  bool canAnalyze(Flight flight) {
    return getNextFlight(flight) != null;
  }
}
