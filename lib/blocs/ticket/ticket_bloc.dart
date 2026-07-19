import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/ticket_service.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketService _ticketService;

  TicketBloc({required TicketService ticketService})
      : _ticketService = ticketService,
        super(TicketInitial()) {
    on<FetchTicketRequested>(_onFetchTicketRequested);
  }

  Future<void> _onFetchTicketRequested(
      FetchTicketRequested event, Emitter<TicketState> emit) async {
    emit(TicketLoading());
    try {
      final result = await _ticketService.getTicketAndEventByTicketId(event.ticketId);
      if (result == null) {
        emit(TicketNotFound());
      } else {
        emit(TicketLoaded(result['attendee'], result['event']));
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
