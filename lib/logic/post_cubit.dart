import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import '../repo/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository repository;
  final String? publisherType;

  PostCubit(this.repository, {this.publisherType}) : super(PostInitial());

  Future<List<Post>> _hydrateLikeStatus(List<Post> posts) async {
    final results = <Post>[];
    for (final post in posts) {
      final liked = await repository.isPostLiked(post.id);
      results.add(post.copyWith(isLiked: liked));
    }
    return results;
  }

  Future<void> loadPosts({bool rethrowError = false}) async {
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
      final result = await repository.fetchPosts(
          lastDocument: lastDoc, publisherType: publisherType);

      final hydratedNewPosts = await _hydrateLikeStatus(result.posts);
      final totalPosts = [...oldPosts, ...hydratedNewPosts];

      final hasMoreData =
          result.posts.isNotEmpty && result.posts.length >= PostRepository.limit;

      emit(PostLoaded(
          posts: totalPosts,
          hasMore: hasMoreData,
          lastDocument: result.lastDocument));
    } catch (e) {
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: oldPosts,
        hasMore: currentState is PostLoaded ? currentState.hasMore : false,
        lastDocument: lastDoc,
      ));
      if (rethrowError) rethrow;
    }
  }

  Future<void> addPostWithImage(
      String title, String desc, File? imageFile, String uid) async {
    final currentState = state;
    final List<Post> currentPosts = currentState is PostLoaded
        ? currentState.posts
        : (currentState is PostLoading ? currentState.oldPosts : []);

    try {
      emit(PostLoading(currentPosts, isFirstFetch: false));

      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await repository.uploadImage(imageFile);
        if (imageUrl.isEmpty) {
          throw Exception("Resim yüklenemedi, URL boş döndü.");
        }
      }

      await repository.addPost(title, desc, imageUrl, uid);
      // Post eklendikten sonra mutlaka yenilemeyi bekle ve hata varsa fırlat.
      // Bu sayede modal "başarılı" diyerek kapanmaz, hata modalda kalır.
      await refresh(rethrowError: true);
    } catch (e) {
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: currentPosts,
        hasMore: currentState is PostLoaded ? currentState.hasMore : false,
        lastDocument:
            currentState is PostLoaded ? currentState.lastDocument : null,
      ));
      rethrow;
    }
  }

  Future<void> refresh({bool rethrowError = false}) async {
    emit(PostInitial());
    await loadPosts(rethrowError: rethrowError);
  }

  /// STK detay sayfası gibi tek post'u bağımsız olarak yönetmek için.
  Future<void> loadSinglePost(Post post) async {
    final liked = await repository.isPostLiked(post.id);
    final hydrated = post.copyWith(isLiked: liked);
    emit(PostLoaded(posts: [hydrated], hasMore: false));
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
      final currentState = state;
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: currentState is PostLoaded ? currentState.posts : [],
        hasMore: currentState is PostLoaded ? currentState.hasMore : false,
        lastDocument:
            currentState is PostLoaded ? currentState.lastDocument : null,
      ));
    }
  }

  /// Kullanıcının kendi gönderilerini yükler
  Future<void> loadMyPosts(String userId) async {
    emit(const PostLoading([], isFirstFetch: true));
    try {
      final posts = await repository.fetchMyPosts(userId);
      final hydratedPosts = await _hydrateLikeStatus(posts);
      emit(PostLoaded(posts: hydratedPosts, hasMore: false));
    } catch (e) {
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: const [],
        hasMore: false,
      ));
    }
  }

  /// Kendi gönderisini günceller
  Future<void> updatePost(
      String postId, String title, String description) async {
    try {
      await repository.updatePost(postId, title, description);

      final currentState = state;
      if (currentState is PostLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == postId) {
            return Post(
              id: post.id,
              title: title,
              description: description,
              imageUrl: post.imageUrl,
              createdAt: post.createdAt,
              likeCount: post.likeCount,
              commentCount: post.commentCount,
              publisherId: post.publisherId,
              publisherType: post.publisherType,
              isLiked: post.isLiked,
            );
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
      final currentState = state;
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: currentState is PostLoaded ? currentState.posts : [],
        hasMore: currentState is PostLoaded ? currentState.hasMore : false,
        lastDocument:
            currentState is PostLoaded ? currentState.lastDocument : null,
      ));
    }
  }

  /// Kendi gönderisini siler (optimistik güncelleme)
  Future<void> deletePost(String postId, String imageUrl) async {
    final currentState = state;
    if (currentState is! PostLoaded) return;

    // Optimistik: listeden çıkar
    final updatedPosts =
        currentState.posts.where((p) => p.id != postId).toList();
    emit(PostLoaded(
      posts: updatedPosts,
      hasMore: currentState.hasMore,
      lastDocument: currentState.lastDocument,
    ));

    try {
      await repository.deletePost(postId, imageUrl);
    } catch (e) {
      // Rollback already happened above if state was PostLoaded
      final currentState = state;
      emit(PostError(
        message: FirebaseErrorTranslator.translate(e),
        posts: currentState is PostLoaded ? currentState.posts : [],
        hasMore: currentState is PostLoaded ? currentState.hasMore : false,
        lastDocument:
            currentState is PostLoaded ? currentState.lastDocument : null,
      ));
    }
  }
}
