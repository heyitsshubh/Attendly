import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/attendee_service.dart';
import 'attendee_event.dart';
import 'attendee_state.dart';

class AttendeeBloc extends Bloc<AttendeeEvent, AttendeeState> {
  final AttendeeService _attendeeService;
  StreamSubscription? _attendeesSubscription;

  AttendeeBloc({required AttendeeService attendeeService})
      : _attendeeService = attendeeService,
        super(AttendeeInitial()) {
    on<LoadAttendeesRequested>(_onLoadAttendeesRequested);
    on<AttendeesUpdated>(_onAttendeesUpdated);
    on<AttendeesLoadFailed>(_onAttendeesLoadFailed);
    on<AddAttendeeRequested>(_onAddAttendeeRequested);
    on<BulkImportAttendeesRequested>(_onBulkImportAttendeesRequested);
  }

  void _onLoadAttendeesRequested(
      LoadAttendeesRequested event, Emitter<AttendeeState> emit) {
    emit(AttendeeLoading());
    _attendeesSubscription?.cancel();
    _attendeesSubscription = _attendeeService
        .getAttendeesForEvent(event.eventId)
        .listen(
      (attendees) {
        add(AttendeesUpdated(attendees));
      },
      onError: (error) {
        add(AttendeesLoadFailed(error.toString()));
      },
    );
  }

  void _onAttendeesUpdated(AttendeesUpdated event, Emitter<AttendeeState> emit) {
    emit(AttendeesLoaded(event.attendees));
  }

  void _onAttendeesLoadFailed(AttendeesLoadFailed event, Emitter<AttendeeState> emit) {
    emit(AttendeeError(event.error));
  }

  Future<void> _onAddAttendeeRequested(
      AddAttendeeRequested event, Emitter<AttendeeState> emit) async {
    // We emit loading but remember current attendees to revert if error
    final currentState = state;
    emit(AttendeeLoading());
    try {
      await _attendeeService.addAttendee(event.eventId, event.attendee);
      emit(const AttendeeOperationSuccess('Attendee added successfully!'));
      // No need to add AttendeesUpdated manually as stream will push changes
    } catch (e) {
      emit(AttendeeError(e.toString()));
      if (currentState is AttendeesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onBulkImportAttendeesRequested(
      BulkImportAttendeesRequested event, Emitter<AttendeeState> emit) async {
    final currentState = state;
    emit(AttendeeLoading());
    try {
      await _attendeeService.bulkAddAttendees(event.eventId, event.attendees);
      emit(AttendeeOperationSuccess('${event.attendees.length} attendees imported!'));
    } catch (e) {
      emit(AttendeeError(e.toString()));
      if (currentState is AttendeesLoaded) {
        emit(currentState);
      }
    }
  }

  @override
  Future<void> close() {
    _attendeesSubscription?.cancel();
    return super.close();
  }
}
