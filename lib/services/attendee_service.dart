import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendee.dart';

class AttendeeService {
  final FirebaseFirestore _firestore;

  AttendeeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of attendees for a specific event
  Stream<List<AttendeeModel>> getAttendeesForEvent(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendeeModel.fromFirestore(doc))
            .toList());
  }

  // Add a single attendee
  Future<void> addAttendee(String eventId, AttendeeModel attendee) async {
    try {
      final docRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc();
          
      final newAttendee = AttendeeModel(
        id: docRef.id,
        name: attendee.name,
        email: attendee.email,
        phone: attendee.phone,
        ticketId: attendee.ticketId,
        registeredAt: attendee.registeredAt,
        checkedIn: attendee.checkedIn,
      );
      
      await docRef.set(newAttendee.toFirestore());
      
      // Increment totalRegistered in the event document
      await _firestore.collection('events').doc(eventId).update({
        'totalRegistered': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to add attendee: $e');
    }
  }

  // Bulk add attendees from CSV import
  Future<void> bulkAddAttendees(String eventId, List<AttendeeModel> attendees) async {
    try {
      final batch = _firestore.batch();
      
      for (final attendee in attendees) {
        final docRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('attendees')
            .doc();
            
        final newAttendee = AttendeeModel(
          id: docRef.id,
          name: attendee.name,
          email: attendee.email,
          phone: attendee.phone,
          ticketId: attendee.ticketId,
          registeredAt: attendee.registeredAt,
          checkedIn: attendee.checkedIn,
        );
        
        batch.set(docRef, newAttendee.toFirestore());
      }
      
      // Update totalRegistered count in a single operation
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'totalRegistered': FieldValue.increment(attendees.length),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk add attendees: $e');
    }
  }
}
