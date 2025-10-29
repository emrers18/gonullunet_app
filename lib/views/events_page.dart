import 'package:flutter/material.dart';

// --- Renk Tanımlamaları ---
// Bu renkleri projenizin ana tema dosyasından da alabilirsiniz.
const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kDateColor =
    Color(0xFF9A6D5F); // Görseldeki tarih rengi (kahverengi tonu)
const Color kJoinButtonColor = Color(0xFFF5EBE0); // 'Join' butonu arka planı
const Color kJoinButtonTextColor = Color(0xFF6D4C41); // 'Join' butonu metni
const Color kPrimaryColor = Color(0xFFFF5722); // Ana turuncu renk

// --- Etkinlik Veri Modeli ---
/// Her bir etkinliğin verilerini tutmak için basit bir sınıf.
class Event {
  final String date;
  final String title;
  final String location;
  final String imageUrl;

  Event({
    required this.date,
    required this.title,
    required this.location,
    required this.imageUrl,
  });
}

// --- Ana Etkinlikler Sayfası Widget'ı ---
class EventsPage extends StatelessWidget {
  EventsPage({super.key});

  // Veritabanından gelecek olan etkinliklerin geçici (mock) listesi.
  final List<Event> events = [
    Event(
      date: '12 May',
      title: 'Community Cleanup',
      location: 'Central Park, New York',
      // Placeholder resim
      imageUrl: 'https://placehold.co/150x180/5F9E4F/FFFFFF?text=Etkinlik+1',
    ),
    Event(
      date: '15 May',
      title: 'Elderly Care Visit',
      location: 'Harmony Home, New York',
      imageUrl: 'https://placehold.co/150x180/4A90E2/FFFFFF?text=Etkinlik+2',
    ),
    Event(
      date: '18 May',
      title: 'Environmental Awareness',
      location: 'Green Space Center, New York',
      imageUrl: 'https://placehold.co/150x180/7B5E46/FFFFFF?text=Etkinlik+3',
    ),
    Event(
      date: '20 May',
      title: 'Food Drive',
      location: 'Community Center, New York',
      imageUrl: 'https://placehold.co/150x180/F5A623/FFFFFF?text=Etkinlik+4',
    ),
  ];

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          // Her bir etkinlik için özel kart widget'ını oluştur
          return EventCard(event: events[index]);
        },
        // Kartlar arasına boşluk ekle
        separatorBuilder: (context, index) => const SizedBox(height: 24),
      ),
    );
  }
}

// --- Tek Bir Etkinlik Kartı Widget'ı ---
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
          flex: 2, // Metin alanı resimden daha geniş (2/3 oranında)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih
              Text(
                event.date.toUpperCase(),
                style: const TextStyle(
                  color: kDateColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              // Başlık
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.3, // Satır yüksekliği
                ),
              ),
              const SizedBox(height: 6),
              // Konum
              Text(
                event.location,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Katıl Butonu
              TextButton(
                onPressed: () {
                  // Etkinliğe katılma mantığı
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
        const SizedBox(width: 16), // Araya boşluk

        // Sağ Taraf: Resim
        Expanded(
          flex: 1, // Resim alanı (1/3 oranında)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AspectRatio(
              aspectRatio: 3 / 4, // Resim en-boy oranı (görseldeki gibi)
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover, // Resim alanı doldursun
                // Yüklenirken gösterilecek
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
                // Hata durumunda gösterilecek
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
