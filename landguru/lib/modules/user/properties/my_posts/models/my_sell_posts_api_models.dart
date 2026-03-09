import 'my_post.dart';

class MySellPostsResponse {
  const MySellPostsResponse({required this.posts, required this.total});

  final List<MyPost> posts;
  final int total;
}

class MySellPostTabValues {
  // Supported API tab values for sell posts endpoint: ALL, PENDING, QUOTED, ACTIVE, DRAFT.
  static const String all = 'ALL';
  static const String pending = 'PENDING';
  static const String quoted = 'QUOTED';
  static const String active = 'ACTIVE';
  static const String draft = 'DRAFT';

  static String fromFilter(String filter) {
    switch (filter.trim().toLowerCase()) {
      case 'pending':
        return pending;
      case 'quoted':
        return quoted;
      case 'active':
        return active;
      case 'draft':
        return draft;
      case 'all':
      default:
        return all;
    }
  }
}
