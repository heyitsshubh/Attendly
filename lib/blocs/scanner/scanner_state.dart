import 'package:equatable/equatable.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerIdle extends ScannerState {
  const ScannerIdle();
}

class ScanInProgress extends ScannerState {
  const ScanInProgress();
}

class CheckInQueued extends ScannerState {
  final String ticketId;
  const CheckInQueued(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class CheckInSuccess extends ScannerState {
  final String ticketId;
  const CheckInSuccess(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class CheckInDuplicate extends ScannerState {
  final String ticketId;
  const CheckInDuplicate(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class CheckInInvalid extends ScannerState {
  final String ticketId;
  const CheckInInvalid(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}
