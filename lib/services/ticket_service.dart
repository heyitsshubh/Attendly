import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendee.dart';
import '../models/event.dart';

class TicketService {
  final FirebaseFirestore _firestore;

  TicketService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getTicketAndEventByTicketId(String ticketId) async {
    try {
      // Use a collection group query to find the attendee across all events
      final querySnapshot = await _firestore
          .collectionGroup('attendees')
          .where('ticketId', isEqualTo: ticketId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final attendeeDoc = querySnapshot.docs.first;
      final attendee = AttendeeModel.fromFirestore(attendeeDoc);

      // The parent of the attendee document is the 'attendees' collection.
      // The parent of that collection is the 'event' document.
      final eventDocRef = attendeeDoc.reference.parent.parent;
      if (eventDocRef == null) return null;

      final eventDoc = await eventDocRef.get();
      if (!eventDoc.exists) return null;

      final event = EventModel.fromFirestore(eventDoc);

      return {
        'attendee': attendee,
        'event': event,
      };
    } catch (e) {
      throw Exception('Failed to load ticket: $e');
    }
  }
}
