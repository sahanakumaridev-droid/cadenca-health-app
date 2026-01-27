import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/roster_processing_service.dart';
import '../../domain/entities/roster_upload.dart';
import '../../domain/entities/flight.dart';
import 'roster_event.dart';
import 'roster_state.dart';

class RosterBloc extends Bloc<RosterEvent, RosterState> {
  RosterUpload? _currentUpload;

  RosterBloc() : super(const RosterInitial()) {
    on<UploadRosterEvent>(_onUploadRoster);
    on<LoadRosterDataEvent>(_onLoadRosterData);
    on<ClearRosterDataEvent>(_onClearRosterData);
  }

  Future<void> _onUploadRoster(
    UploadRosterEvent event,
    Emitter<RosterState> emit,
  ) async {
    try {
      print('Starting roster upload process'); // Debug log
      emit(const RosterUploading());

      // Process the roster document
      print(
        'Calling RosterProcessingService.processRosterDocument',
      ); // Debug log
      final upload = await RosterProcessingService.processRosterDocument(
        event.imageFile,
      );
      _currentUpload = upload;

      print('Upload status: ${upload.status}'); // Debug log
      print(
        'Extracted flights: ${upload.extractedFlights.length}',
      ); // Debug log

      if (upload.status == RosterProcessingStatus.completed) {
        print('Emitting RosterProcessed state'); // Debug log
        emit(RosterProcessed(upload, upload.extractedFlights));
      } else if (upload.status == RosterProcessingStatus.failed) {
        print('Emitting RosterError state'); // Debug log
        emit(RosterError(upload.errorMessage ?? 'Failed to process roster'));
      }
    } catch (e) {
      print('Exception in _onUploadRoster: $e'); // Debug log
      emit(RosterError('Error processing roster: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRosterData(
    LoadRosterDataEvent event,
    Emitter<RosterState> emit,
  ) async {
    if (_currentUpload != null &&
        _currentUpload!.status == RosterProcessingStatus.completed) {
      emit(RosterProcessed(_currentUpload!, _currentUpload!.extractedFlights));
    } else {
      emit(const RosterInitial());
    }
  }

  Future<void> _onClearRosterData(
    ClearRosterDataEvent event,
    Emitter<RosterState> emit,
  ) async {
    _currentUpload = null;
    emit(const RosterInitial());
  }

  List<Flight> get currentFlights => _currentUpload?.extractedFlights ?? [];
  bool get hasFlightData =>
      _currentUpload != null && _currentUpload!.extractedFlights.isNotEmpty;
}
