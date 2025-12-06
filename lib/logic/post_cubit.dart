import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/repo/post_repository.dart';
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

      // Pagination için son dökümanı bul
      final newLastDoc =
          await _repository.getLastDocumentFromQuery(lastDocument: lastDoc);

      final totalPosts = [...oldPosts, ...newPosts];

      // Eğer gelen veri limiti doldurmadıysa (örn: 10 istedik 3 geldi), sonuna geldik demektir.
      final hasMoreData = newPosts.isNotEmpty && newPosts.length >= 10;

      emit(PostLoaded(
          posts: totalPosts, hasMore: hasMoreData, lastDocument: newLastDoc));
    } catch (e) {
      emit(PostError("Postlar yüklenirken hata oluştu: $e"));
    }
  }

  // post ekleme
  Future<void> addPost(
      String title, String desc, String url, String uid) async {
    try {
      await _repository.addPost(title, desc, url, uid);
      emit(PostInitial());
      loadPosts();
    } catch (e) {
      emit(PostError("Post eklenemedi: $e"));
    }
  }

  // liste yenileme
  Future<void> refresh() async {
    emit(PostInitial());
    await loadPosts();
  }
}
