import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class RosterEvent extends Equatable {
  const RosterEvent();

  @override
  List<Object?> get props => [];
}

class UploadRosterEvent extends RosterEvent {
  final File imageFile;

  const UploadRosterEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class LoadRosterDataEvent extends RosterEvent {
  const LoadRosterDataEvent();
}

class ClearRosterDataEvent extends RosterEvent {
  const ClearRosterDataEvent();
}
