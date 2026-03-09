import 'buy_post_models.dart';

class MyBuyPostsResponse {
  const MyBuyPostsResponse({required this.posts, required this.total});

  final List<BuyPost> posts;
  final int total;
}
