import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/sync_service.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService _syncService;
  StreamSubscription? _onlineSubscription;
  StreamSubscription? _pendingWritesSubscription;

  SyncBloc({required SyncService syncService})
      : _syncService = syncService,
        super(const SyncState()) {
    on<StartSyncMonitor>(_onStartSyncMonitor);
    on<SyncStatusUpdated>(_onSyncStatusUpdated);
    on<PendingWritesUpdated>(_onPendingWritesUpdated);
  }

  void _onStartSyncMonitor(StartSyncMonitor event, Emitter<SyncState> emit) {
    // Listen for connectivity changes
    _onlineSubscription?.cancel();
    _onlineSubscription = _syncService.isOnlineStream.listen(
      (isOnline) => add(SyncStatusUpdated(isOnline)),
    );

    // Listen for pending Firestore writes
    _pendingWritesSubscription?.cancel();
    _pendingWritesSubscription =
        _syncService.pendingWritesStream(event.eventId).listen(
      (count) => add(PendingWritesUpdated(count)),
    );
  }

  void _onSyncStatusUpdated(
      SyncStatusUpdated event, Emitter<SyncState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  void _onPendingWritesUpdated(
      PendingWritesUpdated event, Emitter<SyncState> emit) {
    emit(state.copyWith(pendingWritesCount: event.count));
  }

  @override
  Future<void> close() {
    _onlineSubscription?.cancel();
    _pendingWritesSubscription?.cancel();
    return super.close();
  }
}
