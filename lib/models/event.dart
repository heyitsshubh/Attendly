import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String organizerId;
  final DateTime createdAt;
  final int totalRegistered;

  const EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizerId,
    required this.createdAt,
    this.totalRegistered = 0,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception('Event data is null');

    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      organizerId: data['organizerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalRegistered: data['totalRegistered'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'organizerId': organizerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalRegistered': totalRegistered,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startTime,
        endTime,
        location,
        organizerId,
        createdAt,
        totalRegistered,
      ];
}
