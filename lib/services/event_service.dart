import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore;

  EventService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of events for a specific organizer
  Stream<List<EventModel>> getEventsForOrganizer(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  // Create a new event
  Future<void> createEvent(EventModel event) async {
    try {
      final docRef = _firestore.collection('events').doc();
      final newEvent = EventModel(
        id: docRef.id,
        name: event.name,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        location: event.location,
        organizerId: event.organizerId,
        createdAt: event.createdAt,
        totalRegistered: event.totalRegistered,
      );
      await docRef.set(newEvent.toFirestore());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }
}
