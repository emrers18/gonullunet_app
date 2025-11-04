import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/services/auth.dart'; // Auth servisini import et

// --- Renk Tanımlamaları ---
const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kDateColor = Color(0xFF9A6D5F);
const Color kJoinButtonColor = Color(0xFFF5EBE0);
const Color kJoinButtonTextColor = Color(0xFF6D4C41);
const Color kPrimaryColor = Color(0xFFFF5722);
// AppColors'u da import edebilirsin, ben kPrimaryColor'u kullandım
// import 'package:gonullunet_app/utils/app_colors.dart';

// --- Etkinlik Veri Modeli ---
class Event {
  final String date;
  final String title;
  final String location;
  final String imageUrl;
  // Belge ID'sini tutmak iyi bir pratiktir (örn: detay sayfasına gitmek için)
  final String id;

  Event({
    required this.id,
    required this.date,
    required this.title,
    required this.location,
    required this.imageUrl,
  });

  // Firestore'dan gelen veriyi (Map) Event objesine dönüştüren factory
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Firestore'daki tarih (Timestamp) objesini String'e çevirelim
    // 'eventDate' adında bir Timestamp alanı bekliyoruz
    String formattedDate = 'Tarih Yok';
    if (data['eventDate'] != null && data['eventDate'] is Timestamp) {
      DateTime date = (data['eventDate'] as Timestamp).toDate();
      // Tarihi istediğin formatta (örn: 12 May) formatlayabilirsin
      // Şimdilik basitçe DD.MM.YYYY yapalım
      formattedDate = "${date.day}.${date.month}.${date.year}";
    } else if (data['date'] != null) {
      // Veya 'date' alanını String olarak kaydettiysen:
      formattedDate = data['date'];
    }

    return Event(
      id: doc.id, // Belgenin ID'si
      title: data['title'] ?? 'Başlık Yok',
      location: data['location'] ?? 'Konum Yok',
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/150x180',
      date: formattedDate, // Formatlanmış tarih
    );
  }
}

// --- Ana Etkinlikler Sayfası Widget'ı (STATEFUL'a dönüştü) ---
class EventsPage extends StatefulWidget {
  const EventsPage({super.key}); // const event listesini kaldırdık

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // Firebase servislerini tanımla
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dinlenecek stream'ler
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  Stream<QuerySnapshot>? _eventsStream;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında stream'leri ayarla
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // 1. Giriş yapan kullanıcının rolünü dinle
      _userStream =
          _firestore.collection('users').doc(currentUser.uid).snapshots();
    }
    // 2. 'events' koleksiyonundaki tüm etkinlikleri dinle
    // (Tarihe göre sıralayabilirsin, örn: .orderBy('eventDate', descending: true))
    _eventsStream = _firestore.collection('events').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Etkinlikler',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {
              // Filtreleme mantığı buraya eklenecek
            },
          ),
        ],
      ),

      // BODY: Artık statik liste yerine Firestore'u dinleyen bir StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          // 1. Veri bekleniyor
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Hata oluştu
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          // 3. Veri yok veya koleksiyon boş
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Gösterilecek etkinlik bulunamadı.'));
          }

          // 4. Veri başarıyla alındı
          final eventDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              // Her bir belgeyi (document) Event objesine dönüştür
              final event = Event.fromFirestore(eventDocs[index]);
              // Her bir etkinlik için özel kart widget'ını oluştur
              return EventCard(event: event);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 24),
          );
        },
      ),

      // FLOATING ACTION BUTTON: Kullanıcı rolünü dinleyen StreamBuilder
      floatingActionButton:
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream,
        builder: (context, snapshot) {
          // Veri geldiyse ve döküman mevcutsa
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data();
            final String userType = userData?['userType'] ?? 'volunteer';

            // Sadece STK (ngo) ise butonu göster
            if (userType == 'ngo') {
              return FloatingActionButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => AddEventPage()));
                  // ignore: avoid_print
                  print('STK etkinlik ekleme butonuna bastı.');
                },
                backgroundColor: kPrimaryColor, // Veya AppColors.accentColor
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
          }
          // Diğer tüm durumlarda (Gönüllü, veri yükleniyor, hata vs.) boş kutu göster
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// --- Tek Bir Etkinlik Kartı Widget'ı ---
// (Bu widget'ta hiçbir değişiklik yapmana gerek yok, aynen kalabilir)
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol Taraf: Metinler ve Buton
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.date.toUpperCase(), // '12 May' veya '12.05.2025'
                style: const TextStyle(
                  color: kDateColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                event.location,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // ignore: avoid_print
                  print('${event.title} etkinliğine katıl tıklandı.');
                },
                style: TextButton.styleFrom(
                  backgroundColor: kJoinButtonColor,
                  foregroundColor: kJoinButtonTextColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Sağ Taraf: Resim
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                // Yüklenme ve Hata builder'ların çok güzel, aynen kalmalı
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
