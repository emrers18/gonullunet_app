import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';
import '../repo/user_repository.dart';
import '../utils/app_colors.dart';
import '../utils/gamification_utils.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/gamification/level_badge.dart';

/// STK'ların başvuran gönüllünün profilini inceleyeceği sayfa.
class ApplicantProfilePage extends StatefulWidget {
  final String userId;

  const ApplicantProfilePage({super.key, required this.userId});

  @override
  State<ApplicantProfilePage> createState() => _ApplicantProfilePageState();
}

class _ApplicantProfilePageState extends State<ApplicantProfilePage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserRepository().getUserById(widget.userId);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  int? _calculateAge(Timestamp? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final bd = birthDate.toDate();
    int age = now.year - bd.year;
    if (now.month < bd.month || (now.month == bd.month && now.day < bd.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        title: Text(
          'Başvuran Profili',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF181210),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F5).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181210)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : _user == null
              ? Center(
                  child: Text(
                    'Kullanıcı bulunamadı.',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- Avatar & Name ---
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: (_user!.imageUrl != null &&
                                  _user!.imageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      _user!.imageUrl!),
                                  fit: BoxFit.cover)
                              : null,
                          color: Colors.grey.shade200,
                        ),
                        child: (_user!.imageUrl == null ||
                                _user!.imageUrl!.isEmpty)
                            ? Center(
                                child: Text(
                                  _user!.initials,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.kPrimaryColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _user!.displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF181210),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LevelBadge(xp: _user!.xp),
                      const SizedBox(height: 16),
                      _buildXpProgressBar(_user!.xp),
                      const SizedBox(height: 24),

                      // --- Info Cards ---
                      if (_user!.bio != null && _user!.bio!.isNotEmpty)
                        _buildSection(
                          icon: Icons.person_outline,
                          title: 'Hakkında',
                          child: Text(
                            _user!.bio!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFF4B4B4B),
                              height: 1.5,
                            ),
                          ),
                        ),

                      if (_user!.interests.isNotEmpty)
                        _buildSection(
                          icon: Icons.interests_outlined,
                          title: 'İlgi Alanları',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _user!.interests
                                .map((e) => _buildTag(e, Colors.blue))
                                .toList(),
                          ),
                        ),

                      if (_user!.skills.isNotEmpty)
                        _buildSection(
                          icon: Icons.build_outlined,
                          title: 'Yetenekler',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _user!.skills
                                .map((e) => _buildTag(e, Colors.teal))
                                .toList(),
                          ),
                        ),

                      _buildInfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Doğum Tarihi',
                        value: _user!.birthDate != null
                            ? '${DateFormat('d MMMM yyyy', 'tr_TR').format(_user!.birthDate!.toDate())} (${_calculateAge(_user!.birthDate)} yaş)'
                            : 'Belirtilmemiş',
                      ),

                      _buildInfoRow(
                        icon: Icons.school_outlined,
                        label: 'Eğitim / Meslek',
                        value: (_user!.education != null &&
                                _user!.education!.isNotEmpty)
                            ? _user!.education!
                            : 'Belirtilmemiş',
                      ),

                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Konum',
                        value: (_user!.city != null && _user!.city!.isNotEmpty)
                            ? _user!.city!
                            : 'Belirtilmemiş',
                      ),

                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefon',
                        value:
                            (_user!.phone != null && _user!.phone!.isNotEmpty)
                                ? _user!.phone!
                                : 'Belirtilmemiş',
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF181210),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8D6A5E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF181210),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }


  Widget _buildXpProgressBar(int xp) {
    final level = GamificationUtils.getLevelInfo(xp);
    final progress = GamificationUtils.getProgress(xp);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gönüllü Seviyesi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8D6A5E),
              ),
            ),
            Text(
              '$xp XP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: level.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 10,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        level.color.withOpacity(0.7),
                        level.color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: level.color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Etkinliklere katılarak, paylaşım yaparak ve etkileşim kurarak XP kazanabilirsin.\nRozetler: Gözlemci (0+), Aktif (100+), Öncü (500+), Usta (1500+), Efsane (5000+)",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
