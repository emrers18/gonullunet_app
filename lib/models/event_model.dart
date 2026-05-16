import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final GeoPoint? geoPoint;
  final DateTime date;
  final DateTime? endDate;
  final String imageUrl;
  final String organizerId;
  final List<String> participants;
  final String category;
  final String type; // 'Etkinlik' veya 'Proje'
  final int? quota;
  final List<String> approvedVolunteers;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.geoPoint,
    required this.date,
    this.endDate,
    required this.imageUrl,
    required this.organizerId,
    required this.participants,
    required this.category,
    required this.type,
    this.quota,
    required this.approvedVolunteers,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime startDateTime = DateTime.now();
    if (data['startDate'] != null) {
      startDateTime = (data['startDate'] as Timestamp).toDate();
    } else if (data['date'] != null) {
      startDateTime = (data['date'] as Timestamp).toDate();
    }

    DateTime? endDateTime;
    if (data['endDate'] != null) {
      endDateTime = (data['endDate'] as Timestamp).toDate();
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? 'Başlık Yok',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Konum Belirtilmemiş',
      geoPoint: data['geoPoint'],
      date: startDateTime,
      endDate: endDateTime,
      imageUrl: data['imageUrl'] ?? '',
      organizerId: data['organizerId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      category: data['category'] ?? 'Genel',
      type: data['type'] ?? 'Etkinlik',
      quota: data['quota'],
      approvedVolunteers:
          List<String>.from(data['approved_volunteers'] ?? []),
    );
  }

  /// Cache (SharedPreferences) için JSON'a çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'geoLat': geoPoint?.latitude,
        'geoLng': geoPoint?.longitude,
        'date': date.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
        'imageUrl': imageUrl,
        'organizerId': organizerId,
        'participants': participants,
        'category': category,
        'type': type,
        'quota': quota,
        'approvedVolunteers': approvedVolunteers,
      };

  /// Cache'den Event nesnesi oluşturur.
  factory Event.fromJson(Map<String, dynamic> j) {
    GeoPoint? geoPoint;
    if (j['geoLat'] != null && j['geoLng'] != null) {
      geoPoint = GeoPoint(
        (j['geoLat'] as num).toDouble(),
        (j['geoLng'] as num).toDouble(),
      );
    }
    return Event(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String,
      location: j['location'] as String,
      geoPoint: geoPoint,
      date: DateTime.fromMillisecondsSinceEpoch(j['date'] as int),
      endDate: j['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(j['endDate'] as int)
          : null,
      imageUrl: j['imageUrl'] as String,
      organizerId: j['organizerId'] as String,
      participants: List<String>.from(j['participants'] ?? []),
      category: j['category'] as String,
      type: j['type'] as String,
      quota: j['quota'] as int?,
      approvedVolunteers: List<String>.from(j['approvedVolunteers'] ?? []),
    );
  }
}
