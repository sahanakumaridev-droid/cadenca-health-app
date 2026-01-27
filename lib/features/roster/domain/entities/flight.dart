class Flight {
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String departureTimezone;
  final String arrivalTimezone;
  final Duration flightDuration;

  const Flight({
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureTimezone,
    required this.arrivalTimezone,
    required this.flightDuration,
  });

  @override
  String toString() {
    return 'Flight{flightNumber: $flightNumber, route: $departureAirport → $arrivalAirport}';
  }
}
