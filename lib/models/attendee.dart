import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AttendeeModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String ticketId;
  final DateTime registeredAt;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final String? gateId;

  const AttendeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.ticketId,
    required this.registeredAt,
    this.checkedIn = false,
    this.checkedInAt,
    this.checkedInBy,
    this.gateId,
  });

  factory AttendeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception('Attendee data is null');

    return AttendeeModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      ticketId: data['ticketId'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      checkedIn: data['checkedIn'] ?? false,
      checkedInAt: data['checkedInAt'] != null ? (data['checkedInAt'] as Timestamp).toDate() : null,
      checkedInBy: data['checkedInBy'],
      gateId: data['gateId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'ticketId': ticketId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'checkedIn': checkedIn,
      'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'checkedInBy': checkedInBy,
      'gateId': gateId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        ticketId,
        registeredAt,
        checkedIn,
        checkedInAt,
        checkedInBy,
        gateId,
      ];
}
