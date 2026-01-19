/// Post type enum - used across the app for categorizing posts
enum PostType {
  sellPost,
  buyPost;

  String get label {
    switch (this) {
      case PostType.sellPost:
        return 'Sell Post';
      case PostType.buyPost:
        return 'Buy Post';
    }
  }
}
