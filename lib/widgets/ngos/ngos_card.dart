import 'package:flutter/material.dart';

import '../../models/ngo_model.dart';
import '../../views/ngos_page.dart';

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
