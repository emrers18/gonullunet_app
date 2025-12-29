import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/posts/post_card.dart';
import 'package:gonullunet_app/widgets/posts/add_post_modal.dart';

import '../logic/post_cubit.dart';
import '../logic/post_state.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildUserHeader()),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Bildirimler özelliği yakında!")),
                        );
                      },
                    ),
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
              color: AppColors.primaryColor,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: posts.length + (state is PostLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index < posts.length) {
                    return PostCard(post: posts[index]);
                  } else {
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
        }

        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkPrimaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.lightPrimaryColor,
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
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
                  const Text(
                    'Merhaba, 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
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
      },
    );
  }
}
