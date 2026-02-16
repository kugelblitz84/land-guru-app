import 'package:get/get.dart';

import '../../../../../../core/enums/post_type.dart';
import '../../../../../../core/enums/property_type.dart';
import '../../../../../../core/models/property_listing.dart';
import '../../../../../../core/services/api_client.dart';

class BuyPostOfferService extends GetxService {
  BuyPostOfferService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PropertyListing>> getMyActiveSellPosts({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/my-posts',
      queryParameters: {'page': page, 'limit': limit, 'tab': 'ACTIVE'},
    );

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    final data = payload['data'];
    if (data is! List) {
      return <PropertyListing>[];
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_mapMyPostToListing)
        .toList();
  }

  Future<void> makeOfferFromExisting({
    required String buyPostId,
    required String sellPostId,
  }) async {
    await _apiClient.post(
      '/buy-posts/$buyPostId/offer/existing',
      data: {'sellPostId': sellPostId},
    );
  }

  Future<Map<String, dynamic>> createDraftOfferStep1({
    required String buyPostId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post(
      '/buy-posts/$buyPostId/offer/new/draft',
      data: payload,
    );
    return _extractResponseMap(response.data);
  }

  Future<Map<String, dynamic>> updateDraftOfferStep2({
    required String offerId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/buy-posts/offer/new/draft/$offerId',
      data: payload,
    );
    return _extractResponseMap(response.data);
  }

  Future<void> submitFinalOffer({required String offerId}) async {
    await _apiClient.post('/buy-posts/offer/new/$offerId/submit');
  }

  Map<String, dynamic> _extractResponseMap(dynamic payload) {
    if (payload is Map && payload['data'] is Map<String, dynamic>) {
      return payload['data'] as Map<String, dynamic>;
    }
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    throw Exception('Invalid response');
  }

  PropertyListing _mapMyPostToListing(Map<String, dynamic> json) {
    final rawType = json['propertyType']?.toString().toLowerCase() ?? '';
    final propertyType = switch (rawType) {
      'plain land' || 'plainland' || 'land' => PropertyType.plainLand,
      'water land' || 'waterland' || 'water' => PropertyType.waterLand,
      _ => PropertyType.flat,
    };

    final address = json['address']?.toString();
    final fullAddress = json['fullAddress']?.toString();
    final location = (address != null && address.isNotEmpty)
        ? address
        : (fullAddress != null && fullAddress.isNotEmpty)
        ? fullAddress
        : 'Location not specified';

    final image = json['image']?.toString();
    final photos = (json['photos'] is List)
        ? (json['photos'] as List)
              .whereType<String>()
              .where((photo) => photo.trim().isNotEmpty)
              .toList()
        : <String>[];

    final priceValue = json['price'] ?? json['askingPrice'] ?? 0;
    final seller = json['seller'] is Map
        ? Map<String, dynamic>.from(json['seller'] as Map)
        : const <String, dynamic>{};

    return PropertyListing(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Property',
      location: location,
      price: _formatPrice(priceValue),
      propertyType: propertyType,
      postType: PostType.sellPost,
      isVerified: json['isVerified'] == true,
      isLocked: false,
      imageUrl: image,
      description: json['description']?.toString(),
      sellableLandAmount: _formatLandAmount(
        json['sellableAmount'],
        json['sellableUnit'],
      ),
      plotSize: _formatLandAmount(json['plotSize'], json['plotUnit']),
      distanceFromRoad: _formatDistanceRange(
        json['roadDistanceMin'],
        json['roadDistanceMax'],
      ),
      postedBy: _readString(seller, const ['name', 'fullName']),
      postedByAvatarUrl: _readString(seller, const [
        'avatar',
        'image',
        'photoUrl',
      ]),
      postedByVerified: seller['isVerified'] == true,
      postedTime: _formatTimeAgo(
        json['updatedAt']?.toString() ?? json['createdAt']?.toString(),
      ),
      propertyPhotos: photos.isNotEmpty
          ? photos
          : (image != null && image.isNotEmpty)
          ? [image]
          : null,
    );
  }

  String _formatPrice(dynamic value) {
    if (value == null) {
      return '0';
    }

    final parsed = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(',', ''));

    if (parsed == null) {
      return value.toString();
    }

    final text = parsed.toInt().toString();
    return text.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  String? _formatLandAmount(dynamic amount, dynamic unit) {
    if (amount == null || unit == null) {
      return null;
    }
    final amountText = amount.toString().trim();
    final unitText = unit.toString().trim();
    if (amountText.isEmpty || unitText.isEmpty) {
      return null;
    }
    return '$amountText $unitText';
  }

  String? _formatDistanceRange(dynamic min, dynamic max) {
    if (min == null && max == null) {
      return null;
    }
    final minText = min?.toString();
    final maxText = max?.toString();
    if (minText != null && maxText != null) {
      return '$minText-$maxText m';
    }
    if (minText != null) {
      return '$minText m';
    }
    return '$maxText m';
  }

  String _formatTimeAgo(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return 'Just now';
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return 'Just now';
    }

    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    return '${(months / 12).floor()}y ago';
  }

  String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
