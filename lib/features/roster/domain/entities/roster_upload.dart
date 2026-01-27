import 'dart:io';
import 'flight.dart';

class RosterUpload {
  final String id;
  final File imageFile;
  final DateTime uploadDate;
  final RosterProcessingStatus status;
  final List<Flight> extractedFlights;
  final String? errorMessage;

  const RosterUpload({
    required this.id,
    required this.imageFile,
    required this.uploadDate,
    required this.status,
    this.extractedFlights = const [],
    this.errorMessage,
  });

  RosterUpload copyWith({
    String? id,
    File? imageFile,
    DateTime? uploadDate,
    RosterProcessingStatus? status,
    List<Flight>? extractedFlights,
    String? errorMessage,
  }) {
    return RosterUpload(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
      extractedFlights: extractedFlights ?? this.extractedFlights,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum RosterProcessingStatus { uploading, processing, completed, failed }
