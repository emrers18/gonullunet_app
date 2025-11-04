import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String date;
  final String title;
  final String location;
  final String imageUrl;

  final String id;

  Event({
    required this.id,
    required this.date,
    required this.title,
    required this.location,
    required this.imageUrl,
  });

  // Firestore'dan veri okuma
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String formattedDate = 'Tarih Yok';
    if (data['eventDate'] != null && data['eventDate'] is Timestamp) {
      DateTime date = (data['eventDate'] as Timestamp).toDate();

      formattedDate = "${date.day}.${date.month}.${date.year}";
    } else if (data['date'] != null) {
      formattedDate = data['date'];
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? 'Başlık Yok',
      location: data['location'] ?? 'Konum Yok',
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/100x50',
      date: formattedDate,
    );
  }
}
