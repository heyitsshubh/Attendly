import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/event_service.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;
  StreamSubscription? _eventsSubscription;

  EventBloc({required EventService eventService})
      : _eventService = eventService,
        super(EventInitial()) {
    on<LoadEventsRequested>(_onLoadEventsRequested);
    on<EventsUpdated>(_onEventsUpdated);
    on<CreateEventRequested>(_onCreateEventRequested);
  }

  void _onLoadEventsRequested(
      LoadEventsRequested event, Emitter<EventState> emit) {
    emit(EventLoading());
    _eventsSubscription?.cancel();
    _eventsSubscription = _eventService
        .getEventsForOrganizer(event.organizerId)
        .listen(
      (events) {
        add(EventsUpdated(events));
      },
      onError: (error) {
        emit(EventError(error.toString()));
      },
    );
  }

  void _onEventsUpdated(EventsUpdated event, Emitter<EventState> emit) {
    emit(EventsLoaded(event.events));
  }

  Future<void> _onCreateEventRequested(
      CreateEventRequested event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _eventService.createEvent(event.event);
      emit(const EventOperationSuccess('Event created successfully!'));
      // We don't need to manually fetch events again because the stream
      // will automatically push the new snapshot and trigger EventsUpdated.
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}
