import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/logic/post_cubit.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

import 'package:gonullunet_app/widgets/gamification/level_badge.dart';
import '../../models/post_model.dart';
import 'comment_modal.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.publisherId)
          .get(),
      builder: (context, snapshot) {
        String displayName = '...';
        String? avatarUrl;
        int xp = 0;
        bool isVolunteer = true;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userType = data['userType'];
          isVolunteer = userType == 'volunteer';
          if (userType == 'ngo') {
            displayName = data['stkName'] ?? 'STK';
          } else {
            displayName = "${data['name']} ${data['surname'] ?? ''}".trim();
          }
          avatarUrl = data['imageUrl'];
          xp = data['xp'] ?? 0;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                      context, displayName, avatarUrl, isVolunteer, xp),
                  if (post.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        post.description,
                        style: GoogleFonts.poppins(
                          color: AppColors.kTextColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (post.imageUrl.isNotEmpty) _buildPostImage(context),
                  _buildStats(context),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  _buildActionButtons(context),
                ],
              ),
              if (isVolunteer && snapshot.hasData)
                Positioned(
                  top: 16,
                  right: 16,
                  child: LevelBadge(
                    xp: xp,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    fontSize: 10,
                    iconSize: 12,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String displayName,
      String? avatarUrl, bool isVolunteer, int xp) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              image: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(avatarUrl),
                      fit: BoxFit.cover)
                  : null,
            ),
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.kTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  post.timeAgo,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade50,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: AppLoadingIndicator(size: 32)),
          errorWidget: (context, url, error) => Center(
              child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${post.likeCount} Beğeni",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            "${post.commentCount} Yorum",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          // Beğen Butonu
          _buildSingleActionButton(
            context: context,
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: "Beğen",
            color: post.isLiked ? Colors.red : Colors.grey.shade600,
            onTap: () {
              context.read<PostCubit>().toggleLike(post.id);
            },
          ),
          // Yorum Butonu
          _buildSingleActionButton(
            context: context,
            icon: Icons.chat_bubble_outline,
            label: "Yorum",
            color: Colors.grey.shade600,
            onTap: () {
              _showCommentModal(context);
            },
          )
        ],
      ),
    );
  }

  void _showCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentModal(postId: post.id),
    );
  }

  Widget _buildSingleActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
