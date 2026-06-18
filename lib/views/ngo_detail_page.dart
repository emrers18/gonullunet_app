import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/models/ngo_model.dart';
import 'package:gonullunet_app/models/post_model.dart';

import 'package:gonullunet_app/widgets/events/event_card.dart';
import 'package:gonullunet_app/widgets/posts/post_card.dart';
import 'package:gonullunet_app/logic/post_cubit.dart';
import 'package:gonullunet_app/logic/post_state.dart';
import 'package:gonullunet_app/repo/post_repository.dart';

import '../widgets/ngos/build_contact_title_widget.dart';
import '../widgets/ngos/build_info_card_widget.dart';
import '../widgets/ngos/build_section_title.dart';
import '../widgets/ngos/build_social_button_widget.dart';
import '../widgets/ngos/build_stat_item_widget.dart';
import '../widgets/ngos/silver_appbar_delegate.dart';
import '../widgets/app_loading_indicator.dart';

class NgoDetailPage extends StatefulWidget {
  final Ngo ngo;

  const NgoDetailPage({super.key, required this.ngo});

  @override
  State<NgoDetailPage> createState() => _NgoDetailPageState();
}

class _NgoDetailPageState extends State<NgoDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // STK'nın detaylı verilerini (Vizyon, Misyon, Telefon vb.) çekmek için StreamBuilder
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(widget.ngo.id).snapshots(),
        builder: (context, snapshot) {
          // Varsayılan veriler (Liste ekranından gelenler)
          String name = widget.ngo.name;
          String location = widget.ngo.location;
          String description = widget.ngo.description;
          String imageUrl = widget.ngo.imageUrl;
          String? vision;
          String? mission;
          String? phone;
          String? email;

          // Eğer detaylı veri geldiyse güncelle
          int followersCount = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['stkName'] ?? name;
            location = data['location'] ?? location;
            description = data['description'] ?? description;
            imageUrl = data['imageUrl'] ?? imageUrl;
            vision = data['vision'];
            mission = data['mission'];
            phone = data['phone'];
            email = data['email'];
            followersCount = data['followersCount'] ?? 0;
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 1. App Bar (Sabit Üst Kısım)
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.white.withOpacity(0.95),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.kTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    AppLocalizations.of(context).ngoDetail,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined,
                          color: AppColors.kTextColor),
                      onPressed: () {},
                    ),
                  ],
                ),

                // 2. Profil Başlığı (Scroll ile kaybolan kısım)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white, // surface-light
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      children: [
                        // Logo (Yuvarlak ve Gölgeli)
                        Hero(
                          tag: 'ngo_image_${widget.ngo.id}',
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Online durumunu gösteren yeşil nokta (Opsiyonel)
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // İsim ve Kategori
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).civilSocietyOrg,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Butonlar (Takip Et / İletişim)
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, userState) {
                            bool isFollowing = false;
                            if (userState is UserLoaded) {
                              isFollowing = userState.user.following
                                  .contains(widget.ngo.id);
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<UserCubit>()
                                          .toggleFollow(widget.ngo.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFollowing
                                          ? Colors.grey.shade200
                                          : AppColors.kPrimaryColor,
                                      foregroundColor: isFollowing
                                          ? Colors.grey.shade700
                                          : Colors.white,
                                      elevation: isFollowing ? 0 : 4,
                                      shadowColor: AppColors.kPrimaryColor
                                          .withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: Text(
                                        isFollowing
                                            ? AppLocalizations.of(context)
                                                .unfollow
                                            : AppLocalizations.of(context)
                                                .follow,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.chat_bubble_outline,
                                        size: 18),
                                    label: Text(
                                        AppLocalizations.of(context).contact,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.kTextColor,
                                      side: BorderSide(
                                          color: Colors.grey.shade200),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 16),

                        // İstatistikler (Hızlı Bakış)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildStatItem(context, followersCount.toString(),
                                AppLocalizations.of(context).followers),
                            // Etkinlik Sayısını Canlı Çek
                            StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('events')
                                    .where('organizerId',
                                        isEqualTo: widget.ngo.id)
                                    .snapshots(),
                                builder: (context, snap) {
                                  String count = "0";
                                  if (snap.hasData) {
                                    count = snap.data!.docs.length.toString();
                                  }
                                  return buildStatItem(context, count,
                                      AppLocalizations.of(context).statEvent);
                                }),
                            buildStatItem(context, "—",
                                AppLocalizations.of(context).statScore),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.kPrimaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.kPrimaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: [
                        Tab(text: AppLocalizations.of(context).tabDescription),
                        Tab(text: AppLocalizations.of(context).events),
                        Tab(text: AppLocalizations.of(context).tabPosts),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle(context, Icons.info_outline,
                          AppLocalizations.of(context).aboutUs),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: TextStyle(
                                  color: AppColors.kTextColor.withOpacity(0.7),
                                  height: 1.6,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (mission != null || vision != null)
                        Row(
                          children: [
                            if (mission != null)
                              Expanded(
                                  child: buildInfoCard(
                                      context,
                                      AppLocalizations.of(context).ourMission,
                                      mission,
                                      Icons.flag_outlined,
                                      Colors.blue.shade600,
                                      Colors.blue.shade50)),
                            if (mission != null && vision != null)
                              const SizedBox(width: 16),
                            if (vision != null)
                              Expanded(
                                  child: buildInfoCard(
                                      context,
                                      AppLocalizations.of(context).ourVision,
                                      vision,
                                      Icons.visibility_outlined,
                                      Colors.orange.shade600,
                                      Colors.orange.shade50)),
                          ],
                        ),
                      const SizedBox(height: 24),
                      buildSectionTitle(context, Icons.contact_support_outlined,
                          AppLocalizations.of(context).contactInfo),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            buildContactTile(context,
                                Icons.location_on_outlined, "Adres", location),
                            if (phone != null)
                              buildContactTile(context, Icons.call_outlined,
                                  "Telefon", phone),
                            if (email != null)
                              buildContactTile(context, Icons.mail_outline,
                                  "E-posta", email),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildSocialButton(
                              context, "f", const Color(0xFF1877F2)),
                          const SizedBox(width: 12),
                          buildSocialButton(
                              context, "in", const Color(0xFF0077b5)),
                          const SizedBox(width: 12),
                          buildSocialButton(context, "X", Colors.black),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                _buildEventsList(),
                _buildPostsList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    final now = DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('events')
          .where('organizerId', isEqualTo: widget.ngo.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingCenter();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context).noEventsShort));
        }

        final allEvents =
            snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

        // Aktif etkinlikler önce (en yakın tarih önceliklisi), geçmiş eventler sonda
        final active = allEvents
            .where((e) => (e.endDate ?? e.date).isAfter(now))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        final expired = allEvents
            .where((e) => !(e.endDate ?? e.date).isAfter(now))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // en yeni geçmiş önce

        final events = [...active, ...expired];

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: events.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
          itemBuilder: (ctx, index) {
            return EventCard(event: events[index]);
          },
        );
      },
    );
  }

  Widget _buildPostsList() {
    return BlocProvider(
      create: (_) => PostCubit(PostRepository())..loadPosts(),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .where('publisherId', isEqualTo: widget.ngo.id)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingCenter();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context).noPostsShared));
          }

          final posts = snapshot.data!.docs
              .map((doc) => Post.fromFirestore(doc))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              return _NgoPostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

/// Her post için kendi [PostCubit]'ini oluşturan sarıcı widget.
/// Bu sayede STK detay sayfasında beğeni butonu doğru çalışır.
class _NgoPostCard extends StatefulWidget {
  final Post post;
  const _NgoPostCard({required this.post});

  @override
  State<_NgoPostCard> createState() => _NgoPostCardState();
}

class _NgoPostCardState extends State<_NgoPostCard> {
  late PostCubit _cubit;

  @override
  void initState() {
    super.initState();
    // Her kart için sadece bu postu içeren tek-post’luk bir cubit başlat
    _cubit = PostCubit(PostRepository());
    _initPost();
  }

  Future<void> _initPost() async {
    await _cubit.loadSinglePost(widget.post);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // State'ten PostLoaded'daki postumuzu al; yoksa orijinalini kullan
          Post displayPost = widget.post;
          if (state is PostLoaded && state.posts.isNotEmpty) {
            displayPost = state.posts.first;
          }
          return PostCard(post: displayPost);
        },
      ),
    );
  }
}
