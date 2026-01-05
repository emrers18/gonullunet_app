import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/views/ngo_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/logic/ngo_cubit.dart';
import 'package:gonullunet_app/logic/ngo_state.dart';
import 'package:gonullunet_app/repo/ngo_repository.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/models/ngo_model.dart';

class NgosPage extends StatelessWidget {
  const NgosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NgoCubit(NgoRepository())..loadNgos(),
      child: const NgosView(),
    );
  }
}

class NgosView extends StatefulWidget {
  const NgosView({super.key});

  @override
  State<NgosView> createState() => _NgosViewState();
}

class _NgosViewState extends State<NgosView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Tasarım Renkleri (Tailwind Config'den alındı)
  static const Color kPrimaryColor = Color(0xFFFF6B35);
  static const Color kSecondaryColor = Color(0xFF004E89);
  static const Color kTealColor = Color(0xFF1A659E);
  static const Color kBackgroundColor = Color(0xFFF7F9FC);
  static const Color kTextMain = Color(0xFF1F2937);
  static const Color kTextSub = Color(0xFF6B7280);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      context.read<NgoCubit>().searchNgos(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kurumlar',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            color: kBackgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kTextMain,
                          ),
                          decoration: InputDecoration(
                            hintText: "STK veya kategori ara...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kSecondaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () {
                          // Detaylı filtre modalını aç
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. GRID LİSTE (Scrollable Content) ---
          Expanded(
            child: BlocBuilder<NgoCubit, NgoState>(
              builder: (context, state) {
                if (state is NgoLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor));
                }

                if (state is NgoError) {
                  return Center(child: Text(state.message));
                }

                if (state is NgoLoaded) {
                  if (state.ngos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('Sonuç bulunamadı.',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 Sütun
                      childAspectRatio: 0.75, // Kart oranı (Dikey dikdörtgen)
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.ngos.length,
                    itemBuilder: (context, index) {
                      final ngo = state.ngos[index];
                      return _buildNgoCard(ngo);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: kTextMain, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNgoCard(dynamic ngo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Üst Kısım: Resim ve Badge
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                image: DecorationImage(
                  // Modelinizde imageUrl yoksa placeholder kullanın
                  image: NetworkImage(
                      ngo.imageUrl ?? "https://via.placeholder.com/150"),
                  fit: BoxFit
                      .contain, // Logo olduğu için contain daha iyi durabilir
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Alt Kısım: Bilgiler ve Buton
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      ngo.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextMain,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   ngo.description ?? "Açıklama bulunmuyor.",
                    //   textAlign: TextAlign.center,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: GoogleFonts.plusJakartaSans(
                    //     fontSize: 12,
                    //     color: kTextSub,
                    //     height: 1.4,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NgoDetailPage(ngo: ngo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBackgroundColor,
                      foregroundColor: kTextMain,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Detayları Görüntüle",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
