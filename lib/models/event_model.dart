import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final GeoPoint? geoPoint;
  final DateTime date;
  final String imageUrl;
  final String organizerId;
  final List<String> participants;
  final String category;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.geoPoint,
    required this.date,
    required this.imageUrl,
    required this.organizerId,
    required this.participants,
    required this.category,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      title: data['title'] ?? 'Başlık Yok',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Konum Belirtilmemiş',
      geoPoint: data['geoPoint'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] ?? '',
      organizerId: data['organizerId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      category: data['category'] ?? 'Genel',
    );
  }
}
