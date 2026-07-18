import 'package:equatable/equatable.dart';
import '../../models/attendee.dart';

abstract class AttendeeEvent extends Equatable {
  const AttendeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendeesRequested extends AttendeeEvent {
  final String eventId;

  const LoadAttendeesRequested(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class AttendeesUpdated extends AttendeeEvent {
  final List<AttendeeModel> attendees;

  const AttendeesUpdated(this.attendees);

  @override
  List<Object> get props => [attendees];
}

class AddAttendeeRequested extends AttendeeEvent {
  final String eventId;
  final AttendeeModel attendee;

  const AddAttendeeRequested(this.eventId, this.attendee);

  @override
  List<Object> get props => [eventId, attendee];
}

class BulkImportAttendeesRequested extends AttendeeEvent {
  final String eventId;
  final List<AttendeeModel> attendees;

  const BulkImportAttendeesRequested(this.eventId, this.attendees);

  @override
  List<Object> get props => [eventId, attendees];
}
