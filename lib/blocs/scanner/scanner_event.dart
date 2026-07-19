import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

class ScannerStarted extends ScannerEvent {
  final String eventId;
  const ScannerStarted(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class ScanDetected extends ScannerEvent {
  final String ticketId;
  const ScanDetected(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class ScannerStopped extends ScannerEvent {}
