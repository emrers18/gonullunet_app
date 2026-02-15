import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import '../repo/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository repository;

  PostCubit(this.repository) : super(PostInitial());

  Future<List<Post>> _hydrateLikeStatus(List<Post> posts) async {
    final results = <Post>[];
    for (final post in posts) {
      final liked = await repository.isPostLiked(post.id);
      results.add(post.copyWith(isLiked: liked));
    }
    return results;
  }

  Future<void> loadPosts() async {
    if (state is PostLoading) return;

    final currentState = state;
    var oldPosts = <Post>[];
    DocumentSnapshot? lastDoc;

    if (currentState is PostLoaded) {
      oldPosts = currentState.posts;
      lastDoc = currentState.lastDocument;

      if (!currentState.hasMore) return;
    }

    emit(PostLoading(oldPosts, isFirstFetch: oldPosts.isEmpty));

    try {
      final newPosts = await repository.fetchPosts(lastDocument: lastDoc);
      final newLastDoc =
          await repository.getLastDocumentFromQuery(lastDocument: lastDoc);

      final hydratedNewPosts = await _hydrateLikeStatus(newPosts);
      final totalPosts = [...oldPosts, ...hydratedNewPosts];

      final hasMoreData =
          newPosts.isNotEmpty && newPosts.length >= PostRepository.limit;

      emit(PostLoaded(
          posts: totalPosts, hasMore: hasMoreData, lastDocument: newLastDoc));
    } catch (e) {
      emit(PostError("Postlar yüklenirken hata oluştu: $e"));
    }
  }

  Future<void> addPostWithImage(
      String title, String desc, File? imageFile, String uid) async {
    try {
      emit(PostLoading(state is PostLoaded ? (state as PostLoaded).posts : [],
          isFirstFetch: false));

      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await repository.uploadImage(imageFile);
        if (imageUrl.isEmpty) {
          throw Exception("Resim yüklenemedi, URL boş döndü.");
        }
      }

      await repository.addPost(title, desc, imageUrl, uid);
      await refresh();
    } catch (e) {
      emit(PostError("Gönderi paylaşılırken bir hata oluştu: $e"));
    }
  }

  Future<void> refresh() async {
    emit(PostInitial());
    await loadPosts();
  }

  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! PostLoaded) return;

    // Optimistic local update
    final updatedPosts = currentState.posts.map((post) {
      if (post.id == postId) {
        final nowLiked = !post.isLiked;
        return post.copyWith(
          isLiked: nowLiked,
          likeCount: post.likeCount + (nowLiked ? 1 : -1),
        );
      }
      return post;
    }).toList();

    emit(PostLoaded(
      posts: updatedPosts,
      hasMore: currentState.hasMore,
      lastDocument: currentState.lastDocument,
    ));

    // Fire-and-forget Firestore write
    try {
      await repository.toggleLikePost(postId);
    } catch (e) {
      // Rollback on error
      final rolledBack = updatedPosts.map((post) {
        if (post.id == postId) {
          final wasLiked = !post.isLiked;
          return post.copyWith(
            isLiked: wasLiked,
            likeCount: post.likeCount + (wasLiked ? 1 : -1),
          );
        }
        return post;
      }).toList();

      emit(PostLoaded(
        posts: rolledBack,
        hasMore: currentState.hasMore,
        lastDocument: currentState.lastDocument,
      ));
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await repository.addComment(postId, content);

      // Local update for comment count
      final currentState = state;
      if (currentState is PostLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(commentCount: post.commentCount + 1);
          }
          return post;
        }).toList();
        emit(PostLoaded(
          posts: updatedPosts,
          hasMore: currentState.hasMore,
          lastDocument: currentState.lastDocument,
        ));
      }
    } catch (e) {
      emit(PostError("Yorum eklenemedi: $e"));
    }
  }
}
