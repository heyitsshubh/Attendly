import 'package:equatable/equatable.dart';
import '../../models/attendee.dart';
import '../../models/event.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final AttendeeModel attendee;
  final EventModel event;

  const TicketLoaded(this.attendee, this.event);

  @override
  List<Object> get props => [attendee, event];
}

class TicketNotFound extends TicketState {}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object> get props => [message];
}
