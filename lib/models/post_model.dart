class Post {
  final String imageUrl;
  final String title;
  final String description;
  final String timeAgo;
  final int likeCount;
  final int commentCount;

  Post({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.likeCount,
    required this.commentCount,
  });
}
