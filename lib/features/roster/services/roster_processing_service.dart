import 'dart:io';
import 'dart:math';
import '../domain/entities/flight.dart';
import '../domain/entities/roster_upload.dart';

class RosterProcessingService {
  static Future<RosterUpload> processRosterDocument(File documentFile) async {
    print('Starting roster processing for: ${documentFile.path}'); // Debug log

    final uploadId = _generateUploadId();

    // Create initial upload record
    var upload = RosterUpload(
      id: uploadId,
      imageFile: documentFile,
      uploadDate: DateTime.now(),
      status: RosterProcessingStatus.processing,
    );

    try {
      print('Processing roster document...'); // Debug log

      // Simulate document processing delay (reduced for testing)
      await Future.delayed(const Duration(seconds: 1));

      // Extract flights from document (simulated)
      final extractedFlights = await _extractFlightsFromDocument(documentFile);

      print('Extracted ${extractedFlights.length} flights'); // Debug log

      // Update upload with results
      upload = upload.copyWith(
        status: RosterProcessingStatus.completed,
        extractedFlights: extractedFlights,
      );

      print('Roster processing completed successfully'); // Debug log
      return upload;
    } catch (e) {
      print('Roster processing failed: $e'); // Debug log

      // Handle processing error
      upload = upload.copyWith(
        status: RosterProcessingStatus.failed,
        errorMessage: 'Failed to process roster document: ${e.toString()}',
      );

      return upload;
    }
  }

  static Future<List<Flight>> _extractFlightsFromDocument(
    File documentFile,
  ) async {
    // Simulate document processing (reduced for testing)
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, return realistic sample data based on document analysis
    // In production, this would use different services based on file type:
    // - PDF: AWS Textract or similar OCR service
    // - Excel: Direct parsing with excel package
    // - Word: Document parsing libraries
    // - Images: OCR services
    return _generateRealisticFlightData();
  }

  static List<Flight> _generateRealisticFlightData() {
    final random = Random();
    final now = DateTime.now();
    final flights = <Flight>[];

    // Generate 3-7 flights over the next few days
    final flightCount = 3 + random.nextInt(5);
    var currentDate = now.add(Duration(days: random.nextInt(2)));

    final airports = ['AMS', 'LHR', 'CDG', 'FCO', 'BCN', 'ZAG', 'VIE', 'MXP'];
    final flightNumbers = ['KL', 'AF', 'LH', 'BA'];

    for (int i = 0; i < flightCount; i++) {
      final departureAirport = airports[random.nextInt(airports.length)];
      var arrivalAirport = airports[random.nextInt(airports.length)];

      // Ensure different airports
      while (arrivalAirport == departureAirport) {
        arrivalAirport = airports[random.nextInt(airports.length)];
      }

      // Generate realistic flight times
      final departureHour = 6 + random.nextInt(16); // 6 AM to 10 PM
      final departureMinute = [0, 15, 30, 45][random.nextInt(4)];
      final departureTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        departureHour,
        departureMinute,
      );

      // Flight duration between 1-4 hours
      final flightDurationMinutes = 60 + random.nextInt(180);
      final arrivalTime = departureTime.add(
        Duration(minutes: flightDurationMinutes),
      );

      final flight = Flight(
        flightNumber:
            '${flightNumbers[random.nextInt(flightNumbers.length)]} ${1000 + random.nextInt(9000)}',
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        departureTimezone: 'CET',
        arrivalTimezone: 'CET',
        flightDuration: Duration(minutes: flightDurationMinutes),
      );

      flights.add(flight);

      // Next flight could be same day or next day
      if (random.nextBool() && i < flightCount - 1) {
        // Same day return flight (2-8 hours later)
        final layoverHours = 2 + random.nextInt(7);
        currentDate = arrivalTime.add(Duration(hours: layoverHours));
      } else {
        // Next day
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    return flights;
  }

  static String _generateUploadId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'roster_${timestamp}_$random';
  }

  // Simulate different roster formats and extraction accuracy
  static Future<List<Flight>> processWithVariableAccuracy(
    File documentFile,
  ) async {
    final random = Random();

    // Simulate different success rates based on document quality/type
    if (random.nextDouble() < 0.1) {
      // 10% chance of processing failure
      throw Exception(
        'Unable to extract flight data from document. Please ensure the roster is in a supported format.',
      );
    }

    if (random.nextDouble() < 0.2) {
      // 20% chance of partial extraction
      final flights = _generateRealisticFlightData();
      return flights.take(flights.length ~/ 2).toList();
    }

    // 70% chance of successful extraction
    return _generateRealisticFlightData();
  }
}
