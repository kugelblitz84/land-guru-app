import 'package:flutter/material.dart';
import '../../../../../../core/enums/property_type.dart';
import '../../../../../../core/enums/post_type.dart';

/// Model for property listing - used across For Sale, Wanted, and Offer features
class PropertyListing {
  final String id;
  final String postId; // e.g., "#POST-1042"
  final String title;
  final String location;
  final String price;
  final PropertyType propertyType;
  final PostType postType;
  final bool isVerified;
  final bool isLocked;
  final String? imageUrl;

  // Additional details for property details page
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? postedBy;
  final String? postedByAvatarUrl;
  final bool postedByVerified;
  final String? postedTime;
  final List<String>? propertyPhotos;

  PropertyListing({
    required this.id,
    this.postId = '',
    required this.title,
    required this.location,
    required this.price,
    required this.propertyType,
    required this.postType,
    this.isVerified = false,
    this.isLocked = true,
    this.imageUrl,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.postedBy,
    this.postedByAvatarUrl,
    this.postedByVerified = false,
    this.postedTime,
    this.propertyPhotos,
  });

  String get propertyTypeLabel => propertyType.label;

  String get postTypeLabel => postType.label;

  Color get propertyTypeColor => propertyType.color;

  /// Convert to Map for passing as route arguments
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'location': location,
      'price': price,
      'propertyType': propertyType.name,
      'postType': postType.name,
      'isVerified': isVerified,
      'isLocked': isLocked,
      'imageUrl': imageUrl,
      'description': description,
      'sellableLandAmount': sellableLandAmount,
      'plotSize': plotSize,
      'distanceFromRoad': distanceFromRoad,
      'postedBy': postedBy,
      'postedByAvatarUrl': postedByAvatarUrl,
      'postedByVerified': postedByVerified,
      'postedTime': postedTime,
      'propertyPhotos': propertyPhotos,
    };
  }

  /// Parse property listing from sell-post API response item
  factory PropertyListing.fromSellPostJson(Map<String, dynamic> json) {
    final imageUrl = json['image']?.toString();
    final photos = (json['photos'] is List)
        ? List<String>.from(
            (json['photos'] as List).whereType<String>().where(
              (photo) => photo.trim().isNotEmpty,
            ),
          )
        : <String>[];
    final sellerMap = json['seller'] is Map
        ? Map<String, dynamic>.from(json['seller'] as Map)
        : const <String, dynamic>{};
    final postedBy = _readFirstString(sellerMap, const ['name', 'fullName']);
    final postedByAvatarUrl = _readFirstString(sellerMap, const [
      'avatar',
      'image',
      'photoUrl',
    ]);
    final postedByVerified = sellerMap['isVerified'] == true;

    return PropertyListing(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Property',
      location:
          json['address']?.toString() ??
          json['location']?.toString() ??
          'Location not specified',
      price: _formatPrice(json['price']),
      propertyType: _mapPropertyType(json['propertyType']?.toString()),
      postType: PostType.sellPost,
      isVerified: json['isVerified'] == true,
      isLocked: true,
      imageUrl: imageUrl,
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
      postedBy: postedBy,
      postedByAvatarUrl: postedByAvatarUrl,
      postedByVerified: postedByVerified,
      postedTime: _formatPostedTime(
        json['updatedAt']?.toString() ?? json['createdAt']?.toString(),
      ),
      propertyPhotos: photos.isNotEmpty
          ? photos
          : (imageUrl != null && imageUrl.isNotEmpty)
          ? [imageUrl]
          : null,
    );
  }

  static PropertyType _mapPropertyType(String? rawType) {
    if (rawType == null || rawType.trim().isEmpty) {
      return PropertyType.flat;
    }

    final normalized = rawType.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    switch (normalized) {
      case 'plainland':
      case 'land':
        return PropertyType.plainLand;
      case 'waterland':
      case 'water':
        return PropertyType.waterLand;
      case 'flat':
      default:
        return PropertyType.flat;
    }
  }

  static String _formatPrice(dynamic value) {
    if (value == null) return '0';

    final parsedNumber = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(',', ''));

    if (parsedNumber == null) {
      return value.toString();
    }

    final isInteger = parsedNumber == parsedNumber.roundToDouble();
    final base = isInteger
        ? parsedNumber.toInt().toString()
        : parsedNumber.toStringAsFixed(2);

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

  static String? _formatLandAmount(dynamic amount, dynamic unit) {
    if (amount == null || unit == null) return null;
    final amountText = amount.toString().trim();
    final unitText = unit.toString().trim();
    if (amountText.isEmpty || unitText.isEmpty) return null;
    return '$amountText $unitText';
  }

  static String? _formatDistanceRange(dynamic min, dynamic max) {
    if (min == null && max == null) return null;
    final minText = min?.toString();
    final maxText = max?.toString();

    if (minText != null && maxText != null) {
      return '${minText}m-${maxText}m';
    }
    if (minText != null) return '${minText}m';
    if (maxText != null) return '${maxText}m';
    return null;
  }

  static String? _formatPostedTime(String? createdAtRaw) {
    if (createdAtRaw == null || createdAtRaw.isEmpty) return null;
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return null;

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

  static String? _readFirstString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
