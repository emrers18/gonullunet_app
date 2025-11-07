import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/posts/post_card.dart';
import 'package:gonullunet_app/widgets/posts/add_post_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddPostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddPostModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.kPrimaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Gösterilecek gönderi bulunamadı.'));
          }

          final postDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: postDocs.length,
            itemBuilder: (context, index) {
              final post = Post.fromFirestore(postDocs[index]);
              return PostCard(post: post);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostModal,
        backgroundColor: AppColors.kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
