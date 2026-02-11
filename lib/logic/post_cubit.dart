import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import '../repo/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository repository;

  PostCubit(this.repository) : super(PostInitial());

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

      final totalPosts = [...oldPosts, ...newPosts];

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
    try {
      await repository.toggleLikePost(postId);
      // Not: Tam bir state güncellemesi için ilgili postu bulup likeCount'u yerel de güncelleyebiliriz
      // ya da basitçe refresh() çağırabiliriz. Kullanıcı deneyimi için yerel güncelleme daha iyi.
      // Şimdilik basitleştirip refresh() çağıralım veya sadece repository işini bitirsin.
      // Firestore dinleyicisi olmadığı için manuel yenileme gerekebilir.
      await refresh();
    } catch (e) {
      emit(PostError("Beğeni işlemi başarısız: $e"));
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await repository.addComment(postId, content);
      await refresh();
    } catch (e) {
      emit(PostError("Yorum eklenemedi: $e"));
    }
  }
}
