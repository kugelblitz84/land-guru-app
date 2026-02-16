import 'package:get/get.dart';

import '../../../../../../../core/enums/property_type.dart';
import '../../../../../../../core/services/api_client.dart';
import '../models/offered_post_models.dart';

class MyOfferedPostsService extends GetxService {
  MyOfferedPostsService(this._apiClient);

  final ApiClient _apiClient;

  Future<OfferedPost> getMyOfferedPostDetails({required String offerId}) async {
    final response = await _apiClient.get(
      '/buy-posts/offers/my-offers/$offerId',
    );
    final payload = response.data;

    if (payload is Map) {
      final data = payload['data'];
      if (data is Map) {
        return _mapOfferedPost(Map<String, dynamic>.from(data));
      }
      return _mapOfferedPost(Map<String, dynamic>.from(payload));
    }

    throw Exception('Invalid response');
  }

  Future<MyOfferedPostsResponse> getMyOfferedPosts({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/offers/my-offers',
      queryParameters: {'page': page, 'limit': limit},
    );

    final payload = response.data;
    if (payload is Map) {
      final list = payload['data'];
      if (list is List) {
        final items = list
            .whereType<Map>()
            .map((item) => _mapOfferedPost(Map<String, dynamic>.from(item)))
            .toList(growable: false);

        final rawMeta = payload['meta'] is Map ? payload['meta'] as Map : null;
        final totalRaw = rawMeta?['total'] ?? payload['total'];
        final total = totalRaw is num
            ? totalRaw.toInt()
            : int.tryParse(totalRaw?.toString() ?? '') ?? items.length;

        return MyOfferedPostsResponse(posts: items, total: total);
      }
    }

    throw Exception('Invalid response');
  }

  OfferedPost _mapOfferedPost(Map<String, dynamic> json) {
    final buyPost = _asMap(json['buyPost']) ?? const <String, dynamic>{};
    final yourOffer =
        _asMap(json['yourOffer']) ?? _asMap(json['offerPost']) ?? json;
    final buyer = _asMap(buyPost['postedBy']) ?? const <String, dynamic>{};

    final offeredAtText = _toText(json['offeredAt']);
    final offeredAt = DateTime.tryParse(offeredAtText ?? '') ?? DateTime.now();

    final image =
        _toText(yourOffer['photo']) ??
        _toText(yourOffer['image']) ??
        _toText(yourOffer['imageUrl']) ??
        _toText(yourOffer['thumbnail']) ??
        _toText(json['thumbnail']);

    final yourOfferPropertyId = _toText(yourOffer['propertyId']) ?? '';

    return OfferedPost(
      id: _toText(json['offerId']) ?? '',
      postId: _buildPostId(yourOfferPropertyId),
      propertyTitle:
          _toText(yourOffer['title']) ??
          _toText(buyPost['title']) ??
          'Offered Property',
      propertyPrice: _formatPrice(
        yourOffer['askingPrice'] ?? yourOffer['price'],
      ),
      propertyType: _mapPropertyType(
        _toText(yourOffer['propertyType']) ??
            _toText(buyPost['propertyType']) ??
            'Flat',
      ),
      propertyImageUrl: image,
      status: _mapStatus(_toText(json['status']) ?? ''),
      timestamp: _formatPostedTime(offeredAtText),
      timestampPrefix: 'Offered:',
      description: _toText(yourOffer['description']),
      sellableLandAmount: _formatLand(
        yourOffer['sellableAmount'],
        yourOffer['sellableUnit'],
      ),
      plotSize: _formatLand(yourOffer['plotSize'], yourOffer['plotUnit']),
      shareUnit: _formatLand(yourOffer['shareAmount'], yourOffer['shareUnit']),
      distanceFromRoad: _formatDistance(
        yourOffer['roadDistanceMin'],
        yourOffer['roadDistanceMax'],
      ),
      location: _toText(buyPost['location']) ?? 'Location not specified',
      propertyPhotos: _toTextList(yourOffer['photos']),
      buyerId: _toText(buyer['id']) ?? '',
      buyerName:
          _toText(buyer['name']) ??
          _toText(buyPost['postedByName']) ??
          'Unknown Buyer',
      buyerVerified: _toBool(buyer['isVerified']) ?? false,
      buyerImageUrl: _toText(buyer['avatar']),
      originalBuyPostId: _buildBuyPostId(_toText(buyPost['id']) ?? ''),
      originalBuyPostTitle: _toText(buyPost['title']) ?? 'Original Buy Post',
      offeredAt: offeredAt,
      canMakeSellPostAt: offeredAt.add(const Duration(days: 3)),
    );
  }

  OfferedPostStatus _mapStatus(String rawStatus) {
    final normalized = rawStatus.trim().toUpperCase();
    switch (normalized) {
      case 'BUYER_ACCEPTED':
      case 'ACCEPTED':
      case 'PENDING_ADMIN_REVIEW':
      case 'PENDING_ADMIN':
      case 'APPOINTMENT_SCHEDULED':
        return OfferedPostStatus.buyerAccepted;
      case 'BUYER_REJECTED':
      case 'REJECTED':
        return OfferedPostStatus.buyerRejected;
      case 'COMPLETED':
      case 'DONE':
        return OfferedPostStatus.completed;
      case 'PENDING':
      default:
        return OfferedPostStatus.pendingBuyerReview;
    }
  }

  PropertyType _mapPropertyType(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    switch (normalized) {
      case 'plain land':
      case 'plainland':
      case 'land':
      case 'agroland':
        return PropertyType.plainLand;
      case 'water land':
      case 'waterland':
      case 'water':
        return PropertyType.waterLand;
      case 'flat':
      default:
        return PropertyType.flat;
    }
  }

  String _formatLand(dynamic amount, dynamic unit) {
    final amountText = amount?.toString().trim();
    if (amountText == null || amountText.isEmpty) {
      return '';
    }

    final unitText = unit?.toString().trim();
    if (unitText == null || unitText.isEmpty) {
      return amountText;
    }

    return '$amountText $unitText';
  }

  String _formatDistance(dynamic min, dynamic max) {
    final minText = _toText(min);
    final maxText = _toText(max);
    final hasMin = minText != null && minText.isNotEmpty;
    final hasMax = maxText != null && maxText.isNotEmpty;

    if (hasMin && hasMax) return '${minText}m-${maxText}m';
    if (hasMin) return '${minText}m';
    if (hasMax) return '${maxText}m';
    return 'Not specified';
  }

  String _formatPrice(dynamic value) {
    final parsed = _toNum(value);
    if (parsed == null) {
      return value?.toString() ?? '0';
    }

    final base = parsed == parsed.roundToDouble()
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(2);

    final parts = base.split('.');
    final intPart = _addThousandsSeparator(parts.first);

    if (parts.length == 1 || parts.last == '00') {
      return intPart;
    }

    return '$intPart.${parts.last}';
  }

  String _formatPostedTime(String? rawDate) {
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

  String _buildPostId(dynamic id) {
    final raw = id?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return '#POST';
    }
    final short = raw.length > 8 ? raw.substring(0, 8) : raw;
    return '#POST-${short.toUpperCase()}';
  }

  String _buildBuyPostId(dynamic id) {
    final raw = id?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return '#BUY';
    }
    final short = raw.length > 8 ? raw.substring(0, 8) : raw;
    return '#BUY-${short.toUpperCase()}';
  }

  num? _toNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString().replaceAll(',', '').trim() ?? '');
  }

  String _addThousandsSeparator(String digits) {
    final chars = digits.split('');
    final buffer = StringBuffer();
    for (var index = 0; index < chars.length; index++) {
      final remaining = chars.length - index;
      buffer.write(chars[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  String? _toText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<String> _toTextList(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

class MyOfferedPostsResponse {
  const MyOfferedPostsResponse({required this.posts, required this.total});

  final List<OfferedPost> posts;
  final int total;
}
