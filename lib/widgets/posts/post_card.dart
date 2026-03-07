import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/logic/post_cubit.dart';

import 'package:gonullunet_app/widgets/posts/comment_modal.dart';
import '../../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                post.description,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          if (post.imageUrl.isNotEmpty) _buildPostImage(),
          _buildStats(),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade50),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.publisherId)
          .get(),
      builder: (context, snapshot) {
        String displayName = '...';
        String? avatarUrl;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userType = data['userType'];
          if (userType == 'ngo') {
            displayName = data['stkName'] ?? 'STK';
          } else {
            displayName = "${data['name']} ${data['surname'] ?? ''}".trim();
          }
          avatarUrl = data['imageUrl'];
        }

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
                  color: Colors.grey.shade200,
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
                        color: Colors.grey.shade900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      post.timeAgo,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade400),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostImage() {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: AppColors.kPrimaryColor.withOpacity(0.5),
            ),
          ),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${post.likeCount} Beğeni",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Row(
            children: [
              Text(
                "${post.commentCount} Yorum",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 12),
              // Eğer paylaşım sayısı modelde yoksa statik veya gizli kalabilir
              Text(
                "Paylaşım",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              // Beğen Butonu
              _buildSingleActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: "Beğen",
                color: post.isLiked ? Colors.red : Colors.grey.shade600,
                onTap: () {
                  context.read<PostCubit>().toggleLike(post.id);
                },
              ),
              // Yorum Butonu
              _buildSingleActionButton(
                icon: Icons.chat_bubble_outline,
                label: "Yorum",
                color: Colors.grey.shade600,
                onTap: () {
                  _showCommentModal(context);
                },
              ),
              _buildSingleActionButton(
                icon: Icons.share_outlined,
                label: "Paylaş",
                color: Colors.grey.shade600,
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentModal(BuildContext context) {
    // CommentModal henüz oluşturulmadı, birazdan ekleyeceğiz.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentModal(postId: post.id),
    );
  }

  Widget _buildSingleActionButton({
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
