import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/post_model.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  final List<Post> oldPosts;
  final bool isFirstFetch;

  const PostLoading(this.oldPosts, {this.isFirstFetch = false});
}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasMore;                   
  final DocumentSnapshot? lastDocument;

  const PostLoaded(
      {required this.posts, this.hasMore = true, this.lastDocument});

  @override
  List<Object?> get props => [posts, hasMore, lastDocument];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
}
