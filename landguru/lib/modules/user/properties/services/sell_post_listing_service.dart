import 'package:get/get.dart';

import 'package:landguru/core/models/property_listing.dart';
import 'package:landguru/core/services/api_client.dart';

class SellPostListingService extends GetxService {
  SellPostListingService(this._apiClient);

  final ApiClient _apiClient;

  Future<SellPostListingResponse> getSellPosts({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/all',
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
              .map(PropertyListing.fromSellPostJson)
              .toList()
        : <PropertyListing>[];

    final totalRaw = meta['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? 0;

    return SellPostListingResponse(posts: posts, total: total);
  }
}

class SellPostListingResponse {
  SellPostListingResponse({required this.posts, required this.total});

  final List<PropertyListing> posts;
  final int total;
}
