import 'package:flutter/material.dart';

import '../models/ngo_model.dart';
import '../widgets/ngos/ngos_card.dart';

const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kFollowButtonColor = Color(0xFFF5EBE0);
const Color kFollowButtonTextColor = Color(0xFF6D4C41);
const Color kPrimaryColor = Color(0xFFFF5722);

class NgosPage extends StatelessWidget {
  NgosPage({super.key});

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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: ngos.length,
        itemBuilder: (context, index) {
          return NgoCard(ngo: ngos[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 24),
      ),
    );
  }
}
