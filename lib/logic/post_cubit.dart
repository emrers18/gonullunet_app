import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/services/cache_service.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import '../repo/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository repository;
  final String? publisherType;

  PostCubit(this.repository, {this.publisherType}) : super(PostInitial());

  // Cache anahtarini publisherType'a gore sec
  String get _cacheKey {
    if (publisherType == 'ngo') return CacheKeys.postsNgo;
    if (publisherType == 'volunteer') return CacheKeys.postsVolunteer;
    return 'posts_all';
  }

  Future<List<Post>> _hydrateLikeStatus(List<Post> posts) async {
    final results = <Post>[];
    for (final post in posts) {
      final liked = await repository.isPostLiked(post.id);
      results.add(post.copyWith(isLiked: liked));
    }
    return results;
  }

  /// Ilk sayfa: once cache'den yukle (aninda), sonra Firebase'den getir.
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

    // Ilk fetch ise once cache'i goster (anlik acilis)
    if (oldPosts.isEmpty) {
      final cached = _loadFromCache();
      if (cached.isNotEmpty) {
        emit(PostLoaded(
          posts: cached,
          hasMore: true, // Firebase'den daha fazlasi gelebilir
          fromCache: true,
        ));
        oldPosts = cached;
      }
    }

    emit(PostLoading(oldPosts, isFirstFetch: oldPosts.isEmpty));

    try {
      final result = await repository.fetchPosts(
          lastDocument: lastDoc, publisherType: publisherType);

      final hydratedNewPosts = await _hydrateLikeStatus(result.posts);
      final totalPosts = [...oldPosts.where((p) => !p.fromCache), ...hydratedNewPosts];

      final hasMoreData =
          result.posts.isNotEmpty && result.posts.length >= PostRepository.limit;

      emit(PostLoaded(
          posts: totalPosts,
          hasMore: hasMoreData,
          lastDocument: result.lastDocument));

      // Ilk sayfayi cache'e yaz (sadece ilk batch)
      if (lastDoc == null && hydratedNewPosts.isNotEmpty) {
        _saveToCache(hydratedNewPosts);
      }
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
          throw Exception("Resim yuklenemedi, URL bos dondu.");
        }
      }

      await repository.addPost(title, desc, imageUrl, uid);
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

    try {
      await repository.toggleLikePost(postId);
    } catch (e) {
      // Rollback
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

  Future<void> deletePost(String postId, String imageUrl) async {
    final currentState = state;
    if (currentState is! PostLoaded) return;

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

  // -------------------------------------------------------------------------
  // Cache yardimci metodlari
  // -------------------------------------------------------------------------

  List<Post> _loadFromCache() {
    try {
      final raw = CacheService.readList(_cacheKey);
      return raw.map((j) => Post.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  void _saveToCache(List<Post> posts) {
    try {
      CacheService.writeList(_cacheKey, posts.map((p) => p.toJson()).toList());
    } catch (_) {}
  }
}
