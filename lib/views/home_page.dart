import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/widgets/posts/post_card.dart';
import 'package:gonullunet_app/widgets/posts/add_post_modal.dart';

import '../logic/post_cubit.dart';
import '../logic/post_state.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';
import '../repo/post_repository.dart';
import '../repo/notification_repository.dart';
import '../services/notification_service.dart';
import 'notifications_page.dart';
import 'ai/chat_history_page.dart';
import 'package:gonullunet_app/views/events_page.dart';
import 'package:gonullunet_app/views/ngos_page.dart';
import 'package:gonullunet_app/views/active_chats_page.dart';
import 'package:gonullunet_app/views/event_detail_page.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/repo/event_repository.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late NotificationRepository _notificationRepo;
  late PostCubit _ngoCubit;
  late PostCubit _volunteerCubit;

  @override
  void initState() {
    super.initState();
    _notificationRepo = NotificationRepository();

    final repo = context.read<PostRepository>();
    _ngoCubit = PostCubit(repo, publisherType: 'ngo')..loadPosts();
    _volunteerCubit = PostCubit(repo, publisherType: 'volunteer')..loadPosts();

    NotificationService().initialize();
    context.read<UserCubit>().loadUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ngoCubit.close();
    _volunteerCubit.close();
    super.dispose();
  }

  void _showAddPostModal() async {
    final postRepo = context.read<PostRepository>();
    final userCubit = context.read<UserCubit>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: postRepo),
        ],
        child: BlocProvider.value(
          value: userCubit,
          child: const AddPostModal(),
        ),
      ),
    );
    if (result == true) {
      _ngoCubit.refresh();
      _volunteerCubit.refresh();
    }
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HomeHeaderDelegate(
                  topPadding: MediaQuery.of(context).padding.top,
                  onNavigate: _navigate,
                  notificationRepo: _notificationRepo,
                  scrollController: _scrollController,
                  buildUserHeader: (isDark) => _buildUserHeader(isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: _EventPreviewSection(onNavigate: _navigate),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: AppColors.kPrimaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.kPrimaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: "Kurumlar"),
                      Tab(text: "Gönüllüler"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _PostListView(cubit: _ngoCubit),
              _PostListView(cubit: _volunteerCubit),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddPostModal,
          heroTag: 'add_post_fab',
          backgroundColor: AppColors.headerEnd,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUserHeader({bool isDark = false}) {
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
              return _buildHeaderContent(displayName, imageUrl, isDark: isDark);
            },
          );
        }

        return _buildHeaderContent(displayName, imageUrl, isDark: isDark);
      },
    );
  }

  Widget _buildHeaderContent(String displayName, String? imageUrl,
      {bool isDark = false, bool isCollapsed = false}) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.kPrimaryColor.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: isCollapsed ? 16 : 24,
            backgroundColor: AppColors.kPrimaryColor.withOpacity(0.1),
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImageProvider(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isCollapsed ? 14 : 18),
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
              if (!isCollapsed)
                Text(
                  'Merhaba, 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.kCardBackgroundColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                displayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isCollapsed ? 15 : 17,
                  color: AppColors.kCardBackgroundColor,
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.kBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _PostListView extends StatelessWidget {
  final PostCubit cubit;
  const _PostListView({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // İlk yükleme spinner'ı
          if (state is PostInitial ||
              (state is PostLoading && state.isFirstFetch)) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }

          // Hata göster
          if (state is PostError && state.posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<PostCubit>().refresh(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = state is PostLoaded
              ? state.posts
              : (state is PostLoading
                  ? state.oldPosts
                  : (state is PostError ? state.posts : <Post>[]));

          final hasMore = state is PostLoaded
              ? state.hasMore
              : (state is PostLoading || (state is PostError && state.hasMore));

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed_outlined,
                      size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hiç gönderi yok.\nİlk paylaşımı sen yap!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<PostCubit>().refresh(),
            color: AppColors.kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: posts.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < posts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PostCard(post: posts[index]),
                  );
                }

                // Infinite scroll trigger
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<PostCubit>().loadPosts();
                });

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final void Function(Widget page) onNavigate;
  final NotificationRepository notificationRepo;
  final ScrollController scrollController;
  final Widget Function(bool isDark) buildUserHeader;

  _HomeHeaderDelegate({
    required this.topPadding,
    required this.onNavigate,
    required this.notificationRepo,
    required this.scrollController,
    required this.buildUserHeader,
  });

  @override
  double get minExtent => 72 + topPadding;

  @override
  double get maxExtent => 160 + topPadding;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.5;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.headerStart, AppColors.headerEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32 * (1 - progress).clamp(0.5, 1.0)),
          bottomRight: Radius.circular(32 * (1 - progress).clamp(0.5, 1.0)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerStart.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: buildUserHeader(true)),
                  if (isCollapsed)
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                    )
                  else
                    StreamBuilder<int>(
                      stream: notificationRepo.getUnreadCountStream(),
                      builder: (context, snapshot) {
                        int count = 0;
                        if (snapshot.hasData) count = snapshot.data!;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white),
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
                                    color: Colors.redAccent,
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
            SizedBox(
              height: ((maxExtent - minExtent) * (1.0 - progress))
                  .clamp(0.0, double.infinity),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Opacity(
                  opacity: (1.0 - progress * 2.0).clamp(0.0, 1.0),
                  child: _QuickNavSection(onNavigate: onNavigate, isDark: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) => true;
}

class _QuickNavSection extends StatelessWidget {
  final void Function(Widget page) onNavigate;
  final bool isDark;

  const _QuickNavSection({required this.onNavigate, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavButton(
            icon: Icons.explore_rounded,
            label: 'Keşfet',
            gradientColors: const [Color(0xFF6C63FF), Color(0xFF957DFF)],
            onTap: () => onNavigate(const EventsPage()),
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.corporate_fare_rounded,
            label: 'Kurumlar',
            gradientColors: const [Color(0xFF00897B), Color(0xFF4DB6AC)],
            onTap: () => onNavigate(const NgosPage()),
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Mesajlar',
            gradientColors: const [Color(0xFFFF6B35), Color(0xFFFFAB76)],
            onTap: () => onNavigate(const ActiveChatsPage()),
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Asistan',
            gradientColors: const [Color(0xFF2196F3), Color(0xFF00BCD4)],
            onTap: () => onNavigate(const ChatHistoryPage()),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.isDark = false,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Events Preview Section
// ─────────────────────────────────────────────────
class _EventPreviewSection extends StatelessWidget {
  final void Function(Widget page) onNavigate;

  const _EventPreviewSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YAKLAŞAN ETKİNLİKLER',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => onNavigate(const EventsPage()),
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: FutureBuilder<List<Event>>(
            future: context
                .read<EventRepository>()
                .getUpcomingEventsLimit(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) =>
                      const _EventLoadingPlaceholder(),
                );
              }

              final events = snapshot.data ?? [];
              if (events.isEmpty) return const SizedBox.shrink();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: events.length + 1,
                itemBuilder: (context, index) {
                  if (index == events.length) {
                    return _SeeAllCard(
                        onTap: () => onNavigate(const EventsPage()));
                  }
                  return _EventPreviewCard(event: events[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventPreviewCard extends StatelessWidget {
  final Event event;
  const _EventPreviewCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.75;
    final String dateString = DateFormat('dd MMMM', 'tr_TR').format(event.date);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: event.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey.shade200),
                      )
                    : Container(
                        color: AppColors.kPrimaryColor.withOpacity(0.1)),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Info
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          dateString,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeAllCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeAllCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hepsini Gör',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventLoadingPlaceholder extends StatelessWidget {
  const _EventLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
