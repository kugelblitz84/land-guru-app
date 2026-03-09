import 'offered_post_models.dart';

class MyOfferedPostsResponse {
  const MyOfferedPostsResponse({required this.posts, required this.total});

  final List<OfferedPost> posts;
  final int total;
}
