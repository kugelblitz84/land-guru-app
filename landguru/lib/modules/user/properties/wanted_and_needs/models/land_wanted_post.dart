import 'package:flutter/material.dart';
import '../../../../../core/enums/property_type.dart';
import 'offer_status.dart';

/// Model for land wanted/needs post
class LandWantedPost {
  final String id;
  final String postId; // e.g., "#BUY-1042"
  final String title;
  final String postedBy;
  final String postedTime;
  final String preferredLocation;
  final String propertyType;
  final String requiredLandSize;
  final String requiredPlotSize;
  final String distanceFromRoad;
  final String budgetRange;
  final OfferStatus offerStatus;
  final bool hasOffered;
  final String? description;

  // Offered property details (for "Offered by you" tab)
  final String? offeredPropertyTitle;
  final String? offeredPropertyPrice;
  final PropertyType? offeredPropertyType;
  final String? offeredPropertyImageUrl;

  LandWantedPost({
    required this.id,
    required this.postId,
    required this.title,
    required this.postedBy,
    required this.postedTime,
    required this.preferredLocation,
    required this.propertyType,
    required this.requiredLandSize,
    required this.requiredPlotSize,
    required this.distanceFromRoad,
    required this.budgetRange,
    this.offerStatus = OfferStatus.none,
    this.hasOffered = false,
    this.description,
    this.offeredPropertyTitle,
    this.offeredPropertyPrice,
    this.offeredPropertyType,
    this.offeredPropertyImageUrl,
  });

  factory LandWantedPost.fromBuyPostJson(Map<String, dynamic> json) {
    final postMap = json['post'] is Map
        ? Map<String, dynamic>.from(json['post'] as Map)
        : json;
    final buyerMap = json['buyer'] is Map
        ? Map<String, dynamic>.from(json['buyer'] as Map)
        : <String, dynamic>{};

    final postId = _extractPostId(postMap, buyerMap);
    final id = _extractId(postMap, postId);

    final title = _extractTitle(postMap);
    final preferredLocation = _extractPreferredLocation(postMap);
    final postedBy = _extractBuyerName(postMap, buyerMap);
    final postedTime = _formatPostedTime(
      postMap['updatedAt']?.toString() ??
          postMap['createdAt']?.toString() ??
          json['updatedAt']?.toString() ??
          json['createdAt']?.toString(),
    );

    return LandWantedPost(
      id: id,
      postId: postId,
      title: title,
      postedBy: postedBy,
      postedTime: postedTime,
      preferredLocation: preferredLocation,
      propertyType: _mapPropertyTypeLabel(postMap['propertyType']?.toString()),
      requiredLandSize: _formatMinLand(
        postMap['landSizeMin'],
        postMap['landSizeUnit'],
      ),
      requiredPlotSize: _formatMinLand(
        postMap['plotSizeMin'],
        postMap['plotSizeUnit'],
      ),
      distanceFromRoad: _formatDistanceRange(
        postMap['roadDistanceMin'],
        postMap['roadDistanceMax'],
      ),
      budgetRange: _formatBudgetRange(
        postMap['budgetMin'],
        postMap['budgetMax'],
      ),
      description: postMap['description']?.toString(),
    );
  }

  static String _extractId(Map<String, dynamic> postMap, String postId) {
    final rawId = postMap['id']?.toString().trim();
    if (rawId != null && rawId.isNotEmpty) {
      return rawId;
    }
    if (postId.isNotEmpty) {
      return postId;
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  static String _extractPostId(
    Map<String, dynamic> postMap,
    Map<String, dynamic> buyerMap,
  ) {
    final explicitPostId = postMap['postId']?.toString().trim();
    if (explicitPostId != null && explicitPostId.isNotEmpty) {
      return explicitPostId;
    }

    final idRaw = postMap['id']?.toString().trim();
    if (idRaw != null && idRaw.isNotEmpty) {
      final compact = idRaw.length > 8 ? idRaw.substring(0, 8) : idRaw;
      return '#BUY-${compact.toUpperCase()}';
    }

    final buyerId = buyerMap['id']?.toString().trim();
    if (buyerId != null && buyerId.isNotEmpty) {
      final compact = buyerId.length > 6 ? buyerId.substring(0, 6) : buyerId;
      return '#BUY-${compact.toUpperCase()}';
    }

    return '#BUY';
  }

  static String _extractTitle(Map<String, dynamic> postMap) {
    final raw = postMap['title']?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    return 'Untitled Buy Post';
  }

  static String _extractBuyerName(
    Map<String, dynamic> postMap,
    Map<String, dynamic> buyerMap,
  ) {
    final candidates = [
      buyerMap['name'],
      buyerMap['fullName'],
      postMap['buyerName'],
      postMap['name'],
    ];

    for (final candidate in candidates) {
      final parsed = candidate?.toString().trim();
      if (parsed != null && parsed.isNotEmpty) {
        return parsed;
      }
    }

    return 'Unknown Buyer';
  }

  static String _extractPreferredLocation(Map<String, dynamic> postMap) {
    final address = postMap['address'];
    if (address is String && address.trim().isNotEmpty) {
      return address.trim();
    }

    if (address is Map) {
      final parsed = _joinAddressParts(Map<String, dynamic>.from(address));
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    final fullAddressObject = postMap['fullAddressObject'];
    if (fullAddressObject is Map) {
      final parsed = _joinAddressParts(
        Map<String, dynamic>.from(fullAddressObject),
      );
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return 'Location not specified';
  }

  static String _joinAddressParts(Map<String, dynamic> data) {
    final parts =
        [
              data['wardNo']?.toString(),
              data['unionOrCityCorp']?.toString(),
              data['upazila']?.toString(),
              data['district']?.toString(),
              data['division']?.toString(),
              data['postalCode']?.toString(),
            ]
            .map((item) => item?.trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();

    return parts.join(', ');
  }

  static String _mapPropertyTypeLabel(String? rawType) {
    if (rawType == null || rawType.trim().isEmpty) {
      return PropertyType.flat.label;
    }

    final normalized = rawType.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    switch (normalized) {
      case 'plainland':
      case 'land':
      case 'agroland':
        return PropertyType.plainLand.label;
      case 'waterland':
      case 'water':
        return PropertyType.waterLand.label;
      case 'flat':
      default:
        return PropertyType.flat.label;
    }
  }

  static String _formatMinLand(dynamic amount, dynamic unit) {
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

  static String _formatDistanceRange(dynamic min, dynamic max) {
    final minText = min?.toString().trim();
    final maxText = max?.toString().trim();

    final hasMin = minText != null && minText.isNotEmpty;
    final hasMax = maxText != null && maxText.isNotEmpty;

    if (hasMin && hasMax) return '${minText}m-${maxText}m';
    if (hasMin) return '${minText}m';
    if (hasMax) return '${maxText}m';
    return 'Not specified';
  }

  static String _formatBudgetRange(dynamic min, dynamic max) {
    final parsedMin = _tryParseNum(min);
    final parsedMax = _tryParseNum(max);

    if (parsedMin != null && parsedMax != null) {
      return '৳ ${_formatNumber(parsedMin)} - ৳ ${_formatNumber(parsedMax)}';
    }
    if (parsedMax != null) {
      return 'Up to ৳ ${_formatNumber(parsedMax)}';
    }
    if (parsedMin != null) {
      return 'From ৳ ${_formatNumber(parsedMin)}';
    }

    return 'Budget not specified';
  }

  static num? _tryParseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString().replaceAll(',', '').trim());
  }

  static String _formatNumber(num value) {
    final isInteger = value == value.roundToDouble();
    final base = isInteger
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    final parts = base.split('.');

    final intPart = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    if (parts.length == 1 || parts.last == '00') {
      return intPart;
    }

    return '$intPart.${parts.last}';
  }

  static String _formatPostedTime(String? createdAtRaw) {
    if (createdAtRaw == null || createdAtRaw.isEmpty) return 'Just now';
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return 'Just now';

    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';

    final years = (months / 12).floor();
    return '${years}y ago';
  }

  /// Primary status badge label
  String get offerStatusLabel => offerStatus.label;

  /// Primary status badge color
  Color get offerStatusColor => offerStatus.color;

  /// Whether to show "View Appointment" button
  bool get showViewAppointment =>
      offerStatus == OfferStatus.buyerAcceptedAppointment;

  /// Whether to show "Pending Admin Review" button
  bool get showPendingAdminReview =>
      offerStatus == OfferStatus.buyerAcceptedPendingAdmin;

  /// Get offered property type label
  String get offeredPropertyTypeLabel {
    return offeredPropertyType?.label ?? '';
  }

  /// Get offered property type color
  Color get offeredPropertyTypeColor {
    return offeredPropertyType?.color ?? const Color(0xFF3B6CF5);
  }
}
