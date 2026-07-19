import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/sync_service.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final SyncService _syncService;
  final FirebaseFirestore _firestore;

  String? _currentEventId;
  Timer? _debounceTimer;
  final Set<String> _recentlyScanned = {};

  ScannerBloc({
    required SyncService syncService,
    FirebaseFirestore? firestore,
  })  : _syncService = syncService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ScannerIdle()) {
    on<ScannerStarted>(_onScannerStarted);
    on<ScanDetected>(_onScanDetected);
    on<ScannerStopped>(_onScannerStopped);
  }

  void _onScannerStarted(ScannerStarted event, Emitter<ScannerState> emit) {
    _currentEventId = event.eventId;
    _recentlyScanned.clear();
    emit(const ScannerIdle());
  }

  Future<void> _onScanDetected(
      ScanDetected event, Emitter<ScannerState> emit) async {
    final ticketId = event.ticketId;
    final eventId = _currentEventId;
    if (eventId == null) return;

    // --- 400ms Debounce ---
    // Prevent spamming the database if the scanner catches the same barcode twice.
    if (_recentlyScanned.contains(ticketId)) return;

    _recentlyScanned.add(ticketId);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _recentlyScanned.remove(ticketId);
    });

    emit(ScanInProgress());

    try {
      // Check the attendee subcollection for a matching ticketId
      final attendeeQuery = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .where('ticketId', isEqualTo: ticketId)
          .limit(1)
          .get();

      if (attendeeQuery.docs.isEmpty) {
        emit(CheckInInvalid(ticketId));
        return;
      }

      final attendeeDoc = attendeeQuery.docs.first;
      final data = attendeeDoc.data();

      // Check if already checked in (locally or server-confirmed)
      if (data['checkedIn'] == true) {
        emit(CheckInDuplicate(ticketId));
        return;
      }

      // Queue the check-in into pendingCheckIns (works offline!)
      await _syncService.queueCheckIn(
        eventId: eventId,
        ticketId: ticketId,
        scannerId: 'volunteer-device-1', // In a full app, use the device/user ID
      );

      emit(CheckInQueued(ticketId));

      // After a short display window, return to idle
      await Future.delayed(const Duration(seconds: 2));
      if (!isClosed) emit(const ScannerIdle());
    } catch (e) {
      emit(CheckInInvalid(ticketId));
    }
  }

  void _onScannerStopped(ScannerStopped event, Emitter<ScannerState> emit) {
    _currentEventId = null;
    _recentlyScanned.clear();
    _debounceTimer?.cancel();
    emit(const ScannerIdle());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
