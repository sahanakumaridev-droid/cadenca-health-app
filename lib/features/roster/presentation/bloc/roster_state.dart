import 'package:equatable/equatable.dart';
import '../../domain/entities/roster_upload.dart';
import '../../domain/entities/flight.dart';

abstract class RosterState extends Equatable {
  const RosterState();

  @override
  List<Object?> get props => [];
}

class RosterInitial extends RosterState {
  const RosterInitial();
}

class RosterUploading extends RosterState {
  const RosterUploading();
}

class RosterProcessing extends RosterState {
  final RosterUpload upload;

  const RosterProcessing(this.upload);

  @override
  List<Object?> get props => [upload];
}

class RosterProcessed extends RosterState {
  final RosterUpload upload;
  final List<Flight> flights;

  const RosterProcessed(this.upload, this.flights);

  @override
  List<Object?> get props => [upload, flights];
}

class RosterError extends RosterState {
  final String message;

  const RosterError(this.message);

  @override
  List<Object?> get props => [message];
}
