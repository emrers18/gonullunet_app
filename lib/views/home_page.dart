import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../utils/app_colors.dart';
import '../widgets/posts/post_card.dart';

const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kPrimaryColor = Color(0xFFFF5722);
const Color kCardBackgroundColor = Color(0xFFFFFFFF);
const Color kIconColor = Colors.black54;
const Color kTimeColor = Colors.grey;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  int _visiblePostCount = 2;
  final int _loadMoreIncrement = 3;

  void _loadMorePosts() {
    setState(() {
      _visiblePostCount += _loadMoreIncrement;
      if (_visiblePostCount > _allPosts.length) {
        _visiblePostCount = _allPosts.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kBackgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visiblePostCount,
                itemBuilder: (context, index) {
                  return PostCard(post: _allPosts[index]);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
