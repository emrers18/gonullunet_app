import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                  // SOL TARAF: Kullanıcı Bilgisi (Cubit ile yönetilir)
                  Expanded(child: _buildUserHeader()),

                  // SAĞ TARAF: Bildirim İkonu ve Rozet (Badge)
                  StreamBuilder<int>(
                    stream: _notificationRepo.getUnreadCountStream(),
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.hasData) {
                        count = snapshot.data!;
                      }

                      return Stack(
                        clipBehavior:
                            Clip.none, // Rozetin dışarı taşmasına izin ver
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded,
                                  color:
                                      AppColors.primaryText), // Koyu Mavi/Gri
                              onPressed: () {
                                // Bildirimler Sayfasına Yönlendir
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

                          // Eğer okunmamış bildirim varsa kırmızı rozet göster
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
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  count > 9
                                      ? '9+'
                                      : count
                                          .toString(), // 9'dan büyükse 9+ yaz
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
          // 1. Yükleniyor (İlk Açılış)
          if (state is PostLoading && state.isFirstFetch) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }

          // 2. Yüklendi (Veriler Var veya Liste Boş)
          if (state is PostLoaded ||
              (state is PostLoading && !state.isFirstFetch)) {
            final posts = (state is PostLoading)
                ? state.oldPosts
                : (state as PostLoaded).posts;

            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feed_outlined,
                        size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "Henüz hiç gönderi yok.\nİlk paylaşımı sen yap!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PostCubit>().refresh(),
              color: AppColors.kPrimaryColor,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                    16, 8, 16, 80), // FAB için alttan boşluk
                itemCount: posts.length + (state is PostLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index < posts.length) {
                    return PostCard(post: posts[index]);
                  } else {
                    // En alttaki sayfalama (pagination) yükleyicisi
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: AppColors.primaryColor)));
                  }
                },
              ),
            );
          }

          // 3. Hata Durumu
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
        backgroundColor: AppColors.primaryColor, // Ana Mavi Renk
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Daha yuvarlak köşeler
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

        // Veri UserCubit'ten geldiyse kullan
        if (state is UserLoaded) {
          displayName = state.user.displayName;
          imageUrl = state.user.imageUrl;
        }
        // Cubit henüz yüklenmediyse ve elimizde ID varsa geçici olarak Stream dene (Fallback)
        else if (_currentUserId != null) {
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
            backgroundColor: AppColors.lightPrimaryColor, // Açık Mavi Zemin
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImageProvider(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppColors.darkPrimaryColor, // Koyu Mavi Harf
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
              const Text(
                'Merhaba, 👋',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText, // Gri Metin
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.primaryText, // Koyu Metin
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
