import 'package:equatable/equatable.dart';
import '../../models/attendee.dart';

abstract class AttendeeState extends Equatable {
  const AttendeeState();

  @override
  List<Object?> get props => [];
}

class AttendeeInitial extends AttendeeState {}

class AttendeeLoading extends AttendeeState {}

class AttendeesLoaded extends AttendeeState {
  final List<AttendeeModel> attendees;

  const AttendeesLoaded(this.attendees);

  @override
  List<Object> get props => [attendees];
}

class AttendeeOperationSuccess extends AttendeeState {
  final String message;

  const AttendeeOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AttendeeError extends AttendeeState {
  final String message;

  const AttendeeError(this.message);

  @override
  List<Object> get props => [message];
}
