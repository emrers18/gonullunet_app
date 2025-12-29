import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import '../repo/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repository;

  PostCubit(this._repository) : super(PostInitial());

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
      final newPosts = await _repository.fetchPosts(lastDocument: lastDoc);
      final newLastDoc =
          await _repository.getLastDocumentFromQuery(lastDocument: lastDoc);

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
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await _repository.uploadImage(imageFile);
      }

      await _repository.addPost(title, desc, imageUrl, uid);
      await refresh();
    } catch (e) {
      emit(PostError("Post eklenemedi: $e"));
    }
  }

  Future<void> refresh() async {
    emit(PostInitial());
    await loadPosts();
  }
}
