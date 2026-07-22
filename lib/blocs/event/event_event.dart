import 'package:equatable/equatable.dart';
import '../../models/event.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventsRequested extends EventEvent {
  final String organizerId;

  const LoadEventsRequested(this.organizerId);

  @override
  List<Object> get props => [organizerId];
}

class EventsUpdated extends EventEvent {
  final List<EventModel> events;

  const EventsUpdated(this.events);

  @override
  List<Object> get props => [events];
}

class CreateEventRequested extends EventEvent {
  final EventModel event;

  const CreateEventRequested(this.event);

  @override
  List<Object> get props => [event];
}

class EventsLoadFailed extends EventEvent {
  final String error;

  const EventsLoadFailed(this.error);

  @override
  List<Object> get props => [error];
}

