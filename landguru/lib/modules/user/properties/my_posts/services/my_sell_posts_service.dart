import 'package:get/get.dart';

import '../../../../../core/services/api_client.dart';
import '../models/my_post.dart';
import '../models/my_sell_posts_api_models.dart';

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
