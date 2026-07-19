import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object> get props => [];
}

class StartSyncMonitor extends SyncEvent {
  final String eventId;
  const StartSyncMonitor(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class SyncStatusUpdated extends SyncEvent {
  final bool isOnline;
  const SyncStatusUpdated(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}

class PendingWritesUpdated extends SyncEvent {
  final int count;
  const PendingWritesUpdated(this.count);

  @override
  List<Object> get props => [count];
}
