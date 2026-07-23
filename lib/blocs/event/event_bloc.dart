import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/event_service.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;
  StreamSubscription? _eventsSubscription;
  String? _currentOrganizerId; // remember who we're watching

  EventBloc({required EventService eventService})
      : _eventService = eventService,
        super(EventInitial()) {
    on<LoadEventsRequested>(_onLoadEventsRequested);
    on<EventsUpdated>(_onEventsUpdated);
    on<EventsLoadFailed>(_onEventsLoadFailed);
    on<CreateEventRequested>(_onCreateEventRequested);
  }

  void _onLoadEventsRequested(
      LoadEventsRequested event, Emitter<EventState> emit) {
    _currentOrganizerId = event.organizerId;
    emit(EventLoading());
    _eventsSubscription?.cancel();
    _eventsSubscription = _eventService
        .getEventsForOrganizer(event.organizerId)
        .listen(
      (events) {
        add(EventsUpdated(events));
      },
      onError: (error) {
        add(EventsLoadFailed(error.toString()));
      },
    );
  }

  void _onEventsUpdated(EventsUpdated event, Emitter<EventState> emit) {
    emit(EventsLoaded(event.events));
  }

  void _onEventsLoadFailed(EventsLoadFailed event, Emitter<EventState> emit) {
    emit(EventError(event.error));
  }

  Future<void> _onCreateEventRequested(
      CreateEventRequested event, Emitter<EventState> emit) async {
    // Don't emit EventLoading here — it would tear down the stream subscription
    // and leave the dashboard stuck. Just save and let the stream auto-update.
    try {
      await _eventService.createEvent(event.event);
      emit(const EventOperationSuccess('Event created successfully!'));
      // Re-subscribe to the stream so the dashboard gets the new event
      if (_currentOrganizerId != null) {
        _eventsSubscription?.cancel();
        _eventsSubscription = _eventService
            .getEventsForOrganizer(_currentOrganizerId!)
            .listen(
          (events) {
            add(EventsUpdated(events));
          },
          onError: (error) {
            add(EventsLoadFailed(error.toString()));
          },
        );
      }
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
