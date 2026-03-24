import 'package:get/get.dart';

import '../../../../../../../core/enums/property_type.dart';
import '../../../../../../../core/services/api_client.dart';
import '../models/buy_post_models.dart';
import '../models/my_buy_posts_response.dart';

class MyBuyPostsService extends GetxService {
  MyBuyPostsService(this._apiClient);

  final ApiClient _apiClient;

  Future<MyBuyPostsResponse> getMyBuyPosts({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/my-posts',
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
              .map(_mapBuyPost)
              .toList()
        : <BuyPost>[];

    final totalRaw = meta['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? posts.length;

    return MyBuyPostsResponse(posts: posts, total: total);
  }

  Future<BuyPost> getBuyPostDetails(String postId) async {
    final response = await _apiClient.get('/buy-posts/my-posts/$postId');
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }
    return _mapBuyPost(payload);
  }

  Future<OfferReceived> getOfferDetails({required String offerId}) async {
    final response = await _apiClient.get('/buy-posts/offer/details/$offerId');
    final payload = response.data;

    final offerPayload = _extractOfferPayload(payload, offerId);
    return _mapOffer(offerPayload);
  }

  BuyPost _mapBuyPost(Map<String, dynamic> json) {
    final offers = _readOfferList(json['offers']);
    final offersCount = _toInt(json['offersReceived']) ?? offers.length;
    final acceptedOffer = _readAcceptedOffer(json, offers);
    final postId = _buildPostId(_toText(json['id']) ?? '');

    final status = _mapStatus(_toText(json['status']) ?? '');

    final location = _toText(json['location']) ?? 'Location not specified';

    final budgetFromApi = _toText(json['budget']);
    final budgetRange = budgetFromApi != null && budgetFromApi.isNotEmpty
        ? budgetFromApi
        : _formatBudgetFromMinMax(json['budgetMin'], json['budgetMax']);

    final landSize = _formatMinLand(json['sizeMin'], json['sizeUnit']);
    final plotSize = _formatMinLand(json['sizeMin'], json['sizeUnit']);

    final postedAt = _toText(json['postedAt']) ?? _toText(json['createdAt']);

    return BuyPost(
      id: _toText(json['id']) ?? '',
      postId: postId,
      lastCompletedStep: _toInt(json['lastCompletedStep']),
      title: _toText(json['title']) ?? 'Untitled Buy Post',
      preferredLocation: location,
      propertyType: _mapPropertyType(_toText(json['propertyType']) ?? 'Flat'),
      requiredLandSize: landSize,
      requiredPlotSize: plotSize,
      distanceFromRoad:
          _toText(json['distanceFromRoad']) ??
          _formatDistanceRange(
            json['roadDistanceMin'],
            json['roadDistanceMax'],
          ),
      budgetRange: budgetRange,
      description: _toText(json['description']),
      status: status,
      timestamp: _formatPostedTime(postedAt),
      timestampPrefix: _timestampPrefix(status),
      offersReceived: offers,
      offersReceivedCount: offersCount,
      acceptedOffer: acceptedOffer,
    );
  }

  Future<void> acceptOffer({required String offerId}) async {
    final path = '/buy-posts/offers/$offerId/accept';
    await _apiClient.patch(path, queryParameters: {'offerId': offerId});
  }

  List<OfferReceived> _readOfferList(dynamic offersRaw) {
    if (offersRaw is! List) {
      return const <OfferReceived>[];
    }

    return offersRaw
        .whereType<Map>()
        .map((item) => _mapOffer(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  OfferReceived? _readAcceptedOffer(
    Map<String, dynamic> json,
    List<OfferReceived> parsedOffers,
  ) {
    final acceptedRaw = _asMap(json['acceptedOffer']);
    if (acceptedRaw != null) {
      return _mapOffer(acceptedRaw);
    }

    for (final offer in parsedOffers) {
      if (offer.status == OfferReceivedStatus.accepted ||
          offer.status == OfferReceivedStatus.pendingAdminReview ||
          offer.status == OfferReceivedStatus.appointmentScheduled) {
        return offer;
      }
    }

    return null;
  }

  OfferReceived _mapOffer(Map<String, dynamic> json) {
    final property =
        _asMap(json['property']) ??
        _asMap(json['offerPost']) ??
        _asMap(json['yourOffer']) ??
        json;
    final seller =
        _asMap(json['seller']) ??
        _asMap(json['offeredTo']) ??
        _asMap(json['buyer']) ??
        const <String, dynamic>{};

    final imageUrl =
        _toText(property['image']) ??
        _toText(property['imageUrl']) ??
        _toText(property['coverImage']) ??
        _toText(property['photo']) ??
        _toText(property['thumbnail']);

    final offerId =
        _toText(json['offerId']) ??
        _toText(json['id']) ??
        _toText(property['id']) ??
        '';
    final photos = _toTextList(property['photos']);
    final fallbackPhotos = _toTextList(json['images']);

    return OfferReceived(
      id: offerId,
      propertyTitle: _toText(property['title']) ?? 'Property Offer',
      propertyPrice: _formatPrice(property['askingPrice'] ?? property['price']),
      propertyType: _mapPropertyType(
        _toText(property['propertyType']) ?? 'Flat',
      ),
      propertyImageUrl: imageUrl,
      offeredTime: _formatPostedTime(
        _toText(json['offeredAt']) ??
            _toText(json['createdAt']) ??
            _toText(seller['offeredAt']),
      ),
      status: _mapOfferStatus(_toText(json['status']) ?? ''),
      sellerId: _toText(seller['id']) ?? '',
      sellerName:
          _toText(seller['name']) ??
          _toText(seller['fullName']) ??
          'Unknown Seller',
      sellerVerified: _toBool(seller['isVerified']) ?? false,
      description: _toText(property['description']),
      sellableLandAmount: _formatLand(
        property['sellableAmount'],
        property['sellableUnit'],
      ),
      plotSize: _formatLand(property['plotSize'], property['plotUnit']),
      shareUnit: _formatLand(property['shareAmount'], property['shareUnit']),
      distanceFromRoadMin:
          _toText(property['roadDistanceMin']) ??
          _toText(property['distanceFromRoadMin']),
      distanceFromRoadMax:
          _toText(property['roadDistanceMax']) ??
          _toText(property['distanceFromRoadMax']),
      location: _toText(property['location']) ?? 'Location not specified',
      propertyPhotos: photos.isNotEmpty ? photos : fallbackPhotos,
      postId: _buildPostId(_toText(property['id']) ?? ''),
    );
  }

  Map<String, dynamic> _extractOfferPayload(dynamic payload, String offerId) {
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    final payloadMap = Map<String, dynamic>.from(payload);
    final data = payloadMap['data'];
    final candidate = data is Map
        ? Map<String, dynamic>.from(data)
        : payloadMap;

    candidate.putIfAbsent('offerId', () => offerId);

    if (candidate['property'] is! Map &&
        candidate['offerPost'] is! Map &&
        candidate['yourOffer'] is! Map &&
        candidate['title'] == null) {
      final nestedOffer = _asMap(candidate['offer']);
      if (nestedOffer != null) {
        nestedOffer.putIfAbsent('offerId', () => offerId);
        return nestedOffer;
      }
    }

    return candidate;
  }

  String _formatDistanceRange(dynamic min, dynamic max) {
    final minText = _toText(min);
    final maxText = _toText(max);
    final hasMin = minText != null && minText.isNotEmpty;
    final hasMax = maxText != null && maxText.isNotEmpty;

    if (hasMin && hasMax) return '${minText}m-${maxText}m';
    if (hasMin) return '${minText}m';
    if (hasMax) return '${maxText}m';
    return 'Not specified';
  }

  BuyPostStatus _mapStatus(String rawStatus) {
    final normalized = rawStatus.trim().toUpperCase();
    switch (normalized) {
      case 'ACTIVE':
        return BuyPostStatus.active;
      case 'DRAFT':
        return BuyPostStatus.draft;
      case 'COMPLETED':
      case 'DONE':
        return BuyPostStatus.completed;
      case 'PENDING':
      case 'PENDING_ADMIN':
      default:
        return BuyPostStatus.pending;
    }
  }

  OfferReceivedStatus _mapOfferStatus(String rawStatus) {
    final normalized = rawStatus.trim().toUpperCase();
    switch (normalized) {
      case 'ACCEPTED':
      case 'BUYER_ACCEPTED':
        return OfferReceivedStatus.accepted;
      case 'REJECTED':
      case 'BUYER_REJECTED':
        return OfferReceivedStatus.rejected;
      case 'PENDING_ADMIN_REVIEW':
      case 'PENDING_ADMIN':
        return OfferReceivedStatus.pendingAdminReview;
      case 'APPOINTMENT_SCHEDULED':
        return OfferReceivedStatus.appointmentScheduled;
      case 'PENDING':
      default:
        return OfferReceivedStatus.pending;
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

  String _formatMinLand(dynamic amount, dynamic unit) {
    final amountText = amount?.toString().trim();
    final unitText = unit?.toString().trim();

    if (amountText == null || amountText.isEmpty) {
      return 'Not specified';
    }

    if (unitText == null || unitText.isEmpty) {
      return 'Min $amountText';
    }

    return 'Min $amountText $unitText';
  }

  String _formatLand(dynamic amount, dynamic unit) {
    final amountText = amount?.toString().trim();
    final unitText = unit?.toString().trim();
    if (amountText == null || amountText.isEmpty) {
      return '';
    }
    if (unitText == null || unitText.isEmpty) {
      return amountText;
    }
    return '$amountText $unitText';
  }

  String _formatBudgetFromMinMax(dynamic minValue, dynamic maxValue) {
    final min = _toNum(minValue);
    final max = _toNum(maxValue);

    if (min != null && max != null) {
      return '৳ ${_formatPrice(min)} - ৳ ${_formatPrice(max)}';
    }
    if (max != null) {
      return 'Up to ৳ ${_formatPrice(max)}';
    }
    if (min != null) {
      return 'From ৳ ${_formatPrice(min)}';
    }

    return 'Budget not specified';
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

  String _timestampPrefix(BuyPostStatus status) {
    switch (status) {
      case BuyPostStatus.pending:
        return 'Submitted:';
      case BuyPostStatus.draft:
        return 'Edited:';
      case BuyPostStatus.active:
      case BuyPostStatus.completed:
        return 'Posted:';
    }
  }

  String _buildPostId(dynamic id) {
    final raw = id?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return '#BUY';
    }
    final short = raw.length > 8 ? raw.substring(0, 8) : raw;
    return '#BUY-${short.toUpperCase()}';
  }

  int? _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
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
