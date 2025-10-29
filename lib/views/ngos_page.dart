import 'package:flutter/material.dart';

// --- Renk Tanımlamaları ---
// Bu renkleri events_page.dart'tan veya ana tema dosyanızdan alabilirsiniz.
const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kFollowButtonColor =
    Color(0xFFF5EBE0); // 'Takip Et' butonu arka planı
const Color kFollowButtonTextColor =
    Color(0xFF6D4C41); // 'Takip Et' butonu metni
const Color kPrimaryColor = Color(0xFFFF5722); // Ana turuncu renk

// --- STK Veri Modeli ---
/// Her bir STK'nın verilerini tutmak için basit bir sınıf.
class Ngo {
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  Ngo({
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
  });
}

// --- Ana STK'lar Sayfası Widget'ı ---
class NgosPage extends StatelessWidget {
  NgosPage({super.key});

  // Veritabanından gelecek olan STK'ların geçici (mock) listesi.
  final List<Ngo> ngos = [
    Ngo(
      name: 'Eğitim Gönüllüleri Vakfı (TEGV)',
      location: 'İstanbul, Türkiye',
      description: 'İlköğretim çağı çocuklarımızın daha güzel bir gelecek...',
      imageUrl: 'https://placehold.co/150x150/E57373/FFFFFF?text=TEGV',
    ),
    Ngo(
      name: 'TEMA Vakfı',
      location: 'Türkiye Geneli',
      description:
          'Türkiye\'nin doğal varlıklarını ve çevresel değerlerini koruma...',
      imageUrl: 'https://placehold.co/150x150/81C784/FFFFFF?text=TEMA',
    ),
    Ngo(
      name: 'LÖSEV',
      location: 'Ankara, Türkiye',
      description: 'Lösemili ve kan hastası çocukların sağlık ve eğitim...',
      imageUrl: 'https://placehold.co/150x150/64B5F6/FFFFFF?text=LÖSEV',
    ),
    Ngo(
      name: 'Darüşşafaka Cemiyeti',
      location: 'İstanbul, Türkiye',
      description: 'Eğitimde fırsat eşitliği misyonuyla 1863 yılından beri...',
      imageUrl: 'https://placehold.co/150x150/FFB74D/FFFFFF?text=Darüşşafaka',
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
        // Bu başlık main_page.dart tarafından yönetiliyorsa bu AppBar'ı
        // kaldırabilir veya oradaki başlıkla eşleşmesini sağlayabilirsiniz.
        title: const Text(
          'STK\'lar',
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
        itemCount: ngos.length,
        itemBuilder: (context, index) {
          // Her bir STK için özel kart widget'ını oluştur
          return NgoCard(ngo: ngos[index]);
        },
        // Kartlar arasına boşluk ekle
        separatorBuilder: (context, index) => const SizedBox(height: 24),
      ),
    );
  }
}

// --- Tek Bir STK Kartı Widget'ı ---
class NgoCard extends StatelessWidget {
  final Ngo ngo;

  const NgoCard({super.key, required this.ngo});

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
              // STK Adı
              Text(
                ngo.name,
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
                ngo.location,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Açıklama
              Text(
                ngo.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3, // Açıklamayı 3 satır ile sınırla
                overflow: TextOverflow.ellipsis, // Sığmazsa ... koy
              ),
              const SizedBox(height: 12),
              // Takip Et Butonu
              TextButton(
                onPressed: () {
                  // STK'yı takip etme mantığı
                },
                style: TextButton.styleFrom(
                  backgroundColor: kFollowButtonColor,
                  foregroundColor: kFollowButtonTextColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Takip Et',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16), // Araya boşluk

        // Sağ Taraf: Resim (Logo)
        Expanded(
          flex: 1, // Resim alanı (1/3 oranında)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AspectRatio(
              aspectRatio: 1 / 1, // Logo için 1:1 (kare) oran daha iyi
              child: Image.network(
                ngo.imageUrl,
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
                    child:
                        const Icon(Icons.business_outlined, color: Colors.grey),
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
