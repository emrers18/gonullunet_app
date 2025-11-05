import 'package:cloud_firestore/cloud_firestore.dart';

class Ngo {
  final String id; //stknın uidsi
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  Ngo({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
  });

  //firestoredan gelen userstaki veriyi ngo yapıyor
  factory Ngo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Ngo(
      id: data['uid'] ?? doc.id,
      name: data['stkName'] ?? 'STK Adı Yok',
      location: data['location'] ?? 'Konum Belirtilmemiş',
      description: data['description'] ?? 'Açıklama Yok',
      imageUrl: data['imageUrl'] ??
          'https://placehold.co/150x150/9E9E9E/FFFFFF?text=STK',
    );
  }
}
