import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class FetchTicketRequested extends TicketEvent {
  final String ticketId;

  const FetchTicketRequested(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}
