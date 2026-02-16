import 'package:get/get.dart';

import '../../../../../core/services/api_client.dart';
import '../models/my_post.dart';
import '../models/my_post_status.dart';

class MySellPostsService extends GetxService {
  MySellPostsService(this._apiClient);

  final ApiClient _apiClient;

  Future<MySellPostsResponse> getMySellPosts({
    required int page,
    required int limit,
    required String tab,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/my-posts',
      queryParameters: {'page': page, 'limit': limit, 'tab': tab},
    );

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    final data = payload['data'];
    final meta = payload['meta'] is Map ? payload['meta'] as Map : const {};

    final posts = data is List
        ? data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .map(MyPost.fromSellPostJson)
              .toList()
        : <MyPost>[];

    final totalRaw = meta['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? posts.length;

    return MySellPostsResponse(posts: posts, total: total);
  }
}

class MySellPostsResponse {
  MySellPostsResponse({required this.posts, required this.total});

  final List<MyPost> posts;
  final int total;
}

enum MySellPostsTab {
  all('ALL'),
  pending('PENDING'),
  quoted('QUOTED'),
  active('ACTIVE'),
  draft('DRAFT');

  const MySellPostsTab(this.apiValue);

  final String apiValue;

  static MySellPostsTab fromFilter(String filter) {
    switch (filter.toLowerCase()) {
      case 'pending':
        return MySellPostsTab.pending;
      case 'quoted':
        return MySellPostsTab.quoted;
      case 'active':
        return MySellPostsTab.active;
      case 'draft':
        return MySellPostsTab.draft;
      case 'all':
      default:
        return MySellPostsTab.all;
    }
  }
}

extension MyPostSellStatusMapper on MyPostStatus {
  static MyPostStatus fromApiStatus(String? rawStatus) {
    final normalized = (rawStatus ?? '').trim().toUpperCase();
    switch (normalized) {
      case 'PENDING':
      case 'PENDING_ADMIN':
        return MyPostStatus.pending;
      case 'QUOTED':
        return MyPostStatus.quoted;
      case 'ACTIVE':
        return MyPostStatus.active;
      case 'DRAFT':
      default:
        return MyPostStatus.draft;
    }
  }
}
