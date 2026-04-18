import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/posts/post_card.dart';
import 'package:gonullunet_app/widgets/posts/add_post_modal.dart';

import '../logic/post_cubit.dart';
import '../logic/post_state.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';
import '../repo/notification_repository.dart';
import '../services/notification_service.dart';
import 'notifications_page.dart';
import 'ai/chat_history_page.dart';
import 'events_page.dart';
import 'ngos_page.dart';
import 'active_chats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late NotificationRepository _notificationRepo;

  @override
  void initState() {
    super.initState();
    _notificationRepo = NotificationRepository();

    NotificationService().initialize();
    context.read<UserCubit>().loadUser();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        context.read<PostCubit>().loadPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddPostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddPostModal(),
    ).then((_) {
      if (mounted) {
        context.read<PostCubit>().refresh();
      }
    });
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildUserHeader()),
                  StreamBuilder<int>(
                    stream: _notificationRepo.getUnreadCountStream(),
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.hasData) count = snapshot.data!;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded,
                                  color: AppColors.primaryText),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 18, minHeight: 18),
                                child: Text(
                                  count > 9 ? '9+' : count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostLoading && state.isFirstFetch) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (state is PostLoaded ||
              (state is PostLoading && !state.isFirstFetch)) {
            final posts = (state is PostLoading)
                ? state.oldPosts
                : (state as PostLoaded).posts;

            return RefreshIndicator(
              onRefresh: () => context.read<PostCubit>().refresh(),
              color: AppColors.kPrimaryColor,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ── Quick Navigation Section ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _QuickNavSection(onNavigate: _navigate),
                    ),
                  ),

                  // ── Feed header ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text(
                        'SON GÖNDERİLER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // ── Empty feed ──
                  if (posts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.feed_outlined,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz hiç gönderi yok.\nİlk paylaşımı sen yap!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < posts.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PostCard(post: posts[index]),
                              );
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                    color: AppColors.primaryColor),
                              ),
                            );
                          },
                          childCount:
                              posts.length + (state is PostLoading ? 1 : 0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (state is PostError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostModal,
        heroTag: 'add_post_fab',
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserHeader() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String displayName = 'Gönüllü';
        String? imageUrl;

        if (state is UserLoaded) {
          displayName = state.user.displayName;
          imageUrl = state.user.imageUrl;
        } else if (_currentUserId != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                if (data['userType'] == 'ngo') {
                  displayName = data['stkName'] ?? 'STK';
                } else {
                  displayName =
                      "${data['name'] ?? ''} ${data['surname'] ?? ''}".trim();
                  if (displayName.isEmpty) displayName = 'Gönüllü';
                }
                imageUrl = data['imageUrl'];
              }
              return _buildHeaderContent(displayName, imageUrl);
            },
          );
        }

        return _buildHeaderContent(displayName, imageUrl);
      },
    );
  }

  Widget _buildHeaderContent(String displayName, String? imageUrl) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.darkPrimaryColor.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightPrimaryColor,
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImageProvider(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppColors.darkPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Merhaba, 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
//  Quick Navigation Section – Instagram Story Style
// ─────────────────────────────────────────────────
class _QuickNavSection extends StatelessWidget {
  final void Function(Widget page) onNavigate;

  const _QuickNavSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StoryBubble(
            icon: Icons.explore_rounded,
            label: 'Keşfet',
            gradientColors: const [Color(0xFF6C63FF), Color(0xFF957DFF)],
            onTap: () => onNavigate(const EventsPage()),
          ),
          _StoryBubble(
            icon: Icons.corporate_fare_rounded,
            label: 'Kurumlar',
            gradientColors: const [Color(0xFF00897B), Color(0xFF4DB6AC)],
            onTap: () => onNavigate(const NgosPage()),
          ),
          _StoryBubble(
            icon: Icons.chat_bubble_rounded,
            label: 'Mesajlar',
            gradientColors: const [Color(0xFFFF6B35), Color(0xFFFFAB76)],
            onTap: () => onNavigate(const ActiveChatsPage()),
          ),
          _StoryBubble(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Asistan',
            gradientColors: const [Color(0xFFFF5722), Color(0xFF03A9F4)],
            onTap: () => onNavigate(const ChatHistoryPage()),
          ),
        ],
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StoryBubble({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
