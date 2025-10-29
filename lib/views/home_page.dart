import 'package:flutter/material.dart';

// --- Renk Tanımlamaları ---
const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kPrimaryColor = Color(0xFFFF5722); // Ana turuncu renk
const Color kCardBackgroundColor = Color(0xFFFFFFFF);
const Color kIconColor = Colors.black54;
const Color kTimeColor = Colors.grey; // Hata düzeltildi (ColorsKodu -> Colors)

// --- Sosyal Akış Gönderi Modeli ---
/// Her bir gönderinin verilerini tutmak için basit bir sınıf.
class Post {
  final String imageUrl;
  final String title;
  final String description;
  final String timeAgo;
  final int likeCount;
  final int commentCount;

  Post({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.likeCount,
    required this.commentCount,
  });
}

// --- Ana Anasayfa Widget'ı (Stateful'a dönüştürüldü) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Veritabanından gelecek olan TÜM gönderilerin listesi.
  // Örnek 10 adet gönderi.
  final List<Post> _allPosts = [
    Post(
      imageUrl: 'https://placehold.co/600x400/81C784/FFFFFF?text=Bahçe+Projesi',
      title: 'Topluluk Bahçesi Projesi İçin Gönüllüler Aranıyor',
      description:
          'Canlı bir topluluk bahçesi oluşturmamıza yardım edin! Dikim, çapalama ve genel bakım konularında gönüllülere ihtiyacımız var. Deneyim gerekmez...',
      timeAgo: '12 saat önce',
      likeCount: 23,
      commentCount: 5,
    ),
    Post(
      imageUrl: 'https://placehold.co/600x400/FFB74D/FFFFFF?text=Barınak',
      title: 'Hayvan Barınağı İçin Bağış Etkinliği',
      description:
          'Yerel hayvan barınağımız için bağış toplamamıza yardımcı olun! Oyunlar, yiyecekler ve müzik içeren bir etkinlik düzenliyoruz...',
      timeAgo: '1 gün önce',
      likeCount: 45,
      commentCount: 12,
    ),
    // --- Daha Fazla Gönderi ---
    Post(
      imageUrl: 'https://placehold.co/600x400/64B5F6/FFFFFF?text=Kitap+Okuma',
      title: 'Çocuklar İçin Kitap Okuma Günü',
      description:
          'İlkokul öğrencileri için gönüllü okuyucular arıyoruz. Cumartesi sabahları 2 saatinizi ayırarak fark yaratabilirsiniz.',
      timeAgo: '2 gün önce',
      likeCount: 68,
      commentCount: 19,
    ),
    Post(
      imageUrl:
          'https://placehold.co/600x400/E57373/FFFFFF?text=Kodlama+Atölyesi',
      title: 'Kodlama Atölyesi İçin Mentor Gerekli',
      description:
          'Gençlere temel Python ve web geliştirme öğretecek mentorlar arıyoruz. Teknolojiye ilgi duyan gençlere yol gösterin.',
      timeAgo: '3 gün önce',
      likeCount: 112,
      commentCount: 25,
    ),
    Post(
      imageUrl:
          'https://placehold.co/600x400/81C784/FFFFFF?text=Bahçe+Projesi+2',
      title: 'Topluluk Bahçesi Projesi İçin Gönüllüler Aranıyor',
      description:
          'Canlı bir topluluk bahçesi oluşturmamıza yardım edin! Dikim, çapalama ve genel bakım konularında gönüllülere ihtiyacımız var. Deneyim gerekmez...',
      timeAgo: '4 gün önce',
      likeCount: 23,
      commentCount: 5,
    ),
    Post(
      imageUrl: 'https://placehold.co/600x400/FFB74D/FFFFFF?text=Barınak+2',
      title: 'Hayvan Barınağı İçin Bağış Etkinliği',
      description:
          'Yerel hayvan barınağımız için bağış toplamamıza yardımcı olun! Oyunlar, yiyecekler ve müzik içeren bir etkinlik düzenliyoruz...',
      timeAgo: '5 gün önce',
      likeCount: 45,
      commentCount: 12,
    ),
    Post(
      imageUrl: 'https://placehold.co/600x400/64B5F6/FFFFFF?text=Kitap+Okuma+2',
      title: 'Çocuklar İçin Kitap Okuma Günü',
      description:
          'İlkokul öğrencileri için gönüllü okuyucular arıyoruz. Cumartesi sabahları 2 saatinizi ayırarak fark yaratabilirsiniz.',
      timeAgo: '6 gün önce',
      likeCount: 68,
      commentCount: 19,
    ),
    Post(
      imageUrl:
          'https://placehold.co/600x400/E57373/FFFFFF?text=Kodlama+Atölyesi+2',
      title: 'Kodlama Atölyesi İçin Mentor Gerekli',
      description:
          'Gençlere temel Python ve web geliştirme öğretecek mentorlar arıyoruz. Teknolojiye ilgi duyan gençlere yol gösterin.',
      timeAgo: '7 gün önce',
      likeCount: 112,
      commentCount: 25,
    ),
    Post(
      imageUrl:
          'https://placehold.co/600x400/81C784/FFFFFF?text=Bahçe+Projesi+3',
      title: 'Topluluk Bahçesi Projesi İçin Gönüllüler Aranıyor',
      description:
          'Canlı bir topluluk bahçesi oluşturmamıza yardım edin! Dikim, çapalama ve genel bakım konularında gönüllülere ihtiyacımız var. Deneyim gerekmez...',
      timeAgo: '8 gün önce',
      likeCount: 23,
      commentCount: 5,
    ),
    Post(
      imageUrl: 'https://placehold.co/600x400/FFB74D/FFFFFF?text=Barınak+3',
      title: 'Hayvan Barınağı İçin Bağış Etkinliği',
      description:
          'Yerel hayvan barınağımız için bağış toplamamıza yardımcı olun! Oyunlar, yiyecekler ve müzik içeren bir etkinlik düzenliyoruz...',
      timeAgo: '9 gün önce',
      likeCount: 45,
      commentCount: 12,
    ),
  ];

  // Başlangıçta gösterilecek gönderi sayısı
  int _visiblePostCount = 2;
  // Her "Daha Fazla Yükle" tıklandığında kaç tane ekleneceği
  final int _loadMoreIncrement = 3;

  /// Daha fazla gönderi yüklemek için state'i güncelleyen fonksiyon
  void _loadMorePosts() {
    setState(() {
      _visiblePostCount += _loadMoreIncrement;
      // Toplam gönderi sayısını aşmamak için kontrol
      if (_visiblePostCount > _allPosts.length) {
        _visiblePostCount = _allPosts.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor, // Arka plan rengini buraya taşıdık
      // Ana gövdeyi SingleChildScrollView ile sardık
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Gönderi listesi
              ListView.separated(
                // Bu ayarlar SingleChildScrollView içinde ListView kullanmak için ZORUNLUDUR
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // ---
                itemCount: _visiblePostCount, // Sadece görünür olanları yükle
                itemBuilder: (context, index) {
                  // Her bir gönderi için özel kart widget'ını oluştur
                  return PostCard(post: _allPosts[index]);
                },
                // Kartlar arasına boşluk ekle
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              ),
              const SizedBox(height: 20), // Liste ile buton arasına boşluk

              // "Daha Fazla Yükle" Butonu
              // Sadece gösterilecek daha fazla gönderi varsa bu butonu göster
              if (_visiblePostCount < _allPosts.length)
                TextButton(
                  onPressed: _loadMorePosts,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: const BorderSide(color: kPrimaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Daha Fazla Yükle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              const SizedBox(height: 20), // Sayfa sonuna ekstra boşluk
            ],
          ),
        ),
      ),
    );
  }
}

// --- Tek Bir Gönderi Kartı Widget'ı ---
// (Bu widget'ta değişiklik yapılmadı)
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardBackgroundColor,
      elevation: 0, // Hafif gölge veya sıfır
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // Kenarlık eklemek isterseniz:
        // side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias, // Resmin kenarlıklarını yuvarlat
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gönderi Resmi
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200, // Resim yüksekliği
            // Yükleme ve hata widget'ları eklenebilir
          ),

          // Metin İçeriği Alanı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Açıklama
                Text(
                  post.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    height: 1.4, // Satır yüksekliği
                  ),
                ),
                const SizedBox(height: 8),
                // Zaman
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Buton Alanı (Beğen, Yorum Yap)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border_outlined,
                  text: post.likeCount.toString(),
                  onPressed: () {
                    // Beğenme mantığı
                  },
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  text: post.commentCount.toString(),
                  onPressed: () {
                    // Yorum yapma mantığı
                  },
                ),
                // Paylaşma ikonu isteğiniz üzerine kaldırıldı.
              ],
            ),
          ),
          const SizedBox(height: 8), // Kartın altında ekstra boşluk
        ],
      ),
    );
  }

  /// Beğen/Yorum Yap butonu için yardımcı widget
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: kIconColor,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: kIconColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
