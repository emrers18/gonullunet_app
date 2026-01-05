import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../logic/event_detail_cubit.dart';
import '../logic/event_detail_state.dart';
import '../models/event_model.dart';
import '../repo/event_repository.dart';
import '../utils/app_colors.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventDetailCubit(EventRepository(), event),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: _EventBody(event: event),
      ),
    );
  }
}

class _EventBody extends StatelessWidget {
  final Event event;

  const _EventBody({required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;
    final bool isJoined = user != null && event.participants.contains(user.uid);

    final formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(event.date);
    final formattedTime = DateFormat('HH:mm').format(event.date);
    final dayName = DateFormat('EEEE', 'tr_TR').format(event.date);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.45,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: event.imageUrl.isNotEmpty
                    ? NetworkImage(event.imageUrl)
                    : const AssetImage('lib/assets/images/logo.png')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.38),
                Container(
                  constraints: BoxConstraints(minHeight: size.height * 0.62),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 40,
                          offset: Offset(0, -10)),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tutamaç
                      Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kategori Etiketi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A659E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ETKİNLİK",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF1A659E),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Başlık
                      Text(
                        event.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Konum
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.kPrimaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Organizatör
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Düzenleyen",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  // FutureBuilder gitti, yerine BlocBuilder'dan gelen state'i kullanıyoruz
                                  BlocBuilder<EventDetailCubit,
                                      EventDetailState>(
                                    builder: (context, state) {
                                      if (state is EventDetailLoaded) {
                                        return Text(
                                          state
                                              .organizerName, // Veriyi direkt Cubit'ten alıyoruz
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        );
                                      }
                                      // Veri yüklenirken
                                      return const Text(
                                        "Yükleniyor...",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      BlocBuilder<EventDetailCubit, EventDetailState>(
                          builder: (context, state) {
                        int count = event.participants.length;
                        if (state is EventDetailUpdated) {
                          count = state.participantCount;
                        }
                        return Row(
                          children: [
                            Expanded(
                                child: _buildInfoCard(
                                    Icons.calendar_month,
                                    "Tarih",
                                    formattedDate,
                                    "$dayName, $formattedTime",
                                    AppColors.kPrimaryColor)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildInfoCard(
                                    Icons.group,
                                    "Katılımcı",
                                    "$count Kişi",
                                    "Şimdiye kadar",
                                    const Color(0xFF004E89))),
                          ],
                        );
                      }),
                      const SizedBox(height: 32),

                      // Açıklama
                      Text("Etkinlik Hakkında",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937))),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                  Row(
                    children: [
                      _buildGlassButton(Icons.ios_share, () {}),
                      const SizedBox(width: 12),
                      _buildGlassButton(Icons.favorite_border, () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 4. KATMAN: Sabit Alt Buton
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: BlocBuilder<EventDetailCubit, EventDetailState>(
            builder: (context, state) {
              // Varsayılan durum
              bool isJoined = false;

              // Eğer Cubit bir state yaymışsa onu kullan
              if (state is EventDetailUpdated) {
                isJoined = state.isJoined;
              }

              return SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<EventDetailCubit>().toggleJoin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isJoined ? Colors.green : AppColors.kPrimaryColor,
                    foregroundColor: Colors.white,
                    shadowColor:
                        (isJoined ? Colors.green : AppColors.kPrimaryColor)
                            .withOpacity(0.4),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isJoined
                          ? Icons.check_circle
                          : Icons.volunteer_activism),
                      const SizedBox(width: 10),
                      Text(
                        isJoined ? "Katıldın" : "Katıl",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, String sub,
      Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937))),
          Text(sub,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
