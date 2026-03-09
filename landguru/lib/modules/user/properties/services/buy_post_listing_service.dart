import 'package:get/get.dart';

import 'package:landguru/core/services/api_client.dart';
import 'package:landguru/modules/user/properties/wanted_and_needs/models/land_wanted_post.dart';
import 'models/post_listing_response_models.dart';

class BuyPostListingService extends GetxService {
  BuyPostListingService(this._apiClient);

  final ApiClient _apiClient;

  Future<BuyPostListingResponse> getAllBuyPosts({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/all',
      queryParameters: {'page': page, 'limit': limit},
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
              .map(LandWantedPost.fromBuyPostJson)
              .toList()
        : <LandWantedPost>[];

    final totalRaw = meta['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? posts.length;

    return BuyPostListingResponse(posts: posts, total: total);
  }

  Future<BuyPostListingResponse> getMyOffers({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/offers/my-offers',
      queryParameters: {'page': page, 'limit': limit},
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
              .map(LandWantedPost.fromMyOfferJson)
              .toList(growable: false)
        : <LandWantedPost>[];

    final totalRaw = meta['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? posts.length;

    return BuyPostListingResponse(posts: posts, total: total);
  }
}
