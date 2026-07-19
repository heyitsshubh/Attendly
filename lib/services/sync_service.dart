import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  SyncService({FirebaseFirestore? firestore, Connectivity? connectivity})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity();

  /// Writes a check-in to `pendingCheckIns/{ticketId}`.
  /// Firestore SDK guarantees this is written to the local cache immediately,
  /// then synced to the server when connectivity is restored.
  Future<void> queueCheckIn({
    required String eventId,
    required String ticketId,
    required String scannerId,
  }) async {
    // ticketId is used as the document ID — this is our idempotency key.
    // Writing the same ticketId twice won't create duplicate Firestore docs.
    final docRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('pendingCheckIns')
        .doc(ticketId);

    await docRef.set({
      'ticketId': ticketId,
      'scannedAt': FieldValue.serverTimestamp(),
      'scannerId': scannerId,
    });
  }

  /// Stream that emits `true` when online, `false` when offline.
  Stream<bool> get isOnlineStream => _connectivity.onConnectivityChanged.map(
        (List<ConnectivityResult> results) =>
            !results.every((r) => r == ConnectivityResult.none),
      );

  /// Stream that counts docs that have NOT yet been confirmed by the server.
  Stream<int> pendingWritesStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('pendingCheckIns')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.where((d) => d.metadata.hasPendingWrites).length);
  }
}
