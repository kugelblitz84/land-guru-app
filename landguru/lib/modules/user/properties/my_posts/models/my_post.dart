import 'package:flutter/material.dart';
import '../../../../../core/enums/property_type.dart';
import '../../../../../core/enums/post_type.dart';
import 'my_post_status.dart';

/// Model for My Post (user's own posts)
class MyPost {
  final String id;
  final String postId;
  final String title;
  final String price;
  final PropertyType propertyType;
  final PostType postType; // sellPost or buyPost
  final MyPostStatus status;
  final bool isVerified;
  final String? imageUrl;
  final String timestamp; // "2h ago"
  final String timestampPrefix; // "Submitted:", "Posted:", "Edited:"
  final int quotesCount; // Number of quotes received (for Quoted status)

  MyPost({
    required this.id,
    required this.postId,
    required this.title,
    required this.price,
    required this.propertyType,
    required this.postType,
    required this.status,
    this.isVerified = false,
    this.imageUrl,
    required this.timestamp,
    required this.timestampPrefix,
    this.quotesCount = 0,
  });

  String get propertyTypeLabel => propertyType.label;

  Color get propertyTypeColor => propertyType.color;

  String get statusLabel => status.label;

  Color get statusColor => status.color;

  Color get statusTextColor => status.textColor;

  Color get statusBackgroundColor => status.backgroundColor;

  factory MyPost.fromSellPostJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final imageUrl = json['image']?.toString();
    final createdAt = json['createdAt']?.toString();

    return MyPost(
      id: id,
      postId: _resolvePostId(json['postId']?.toString(), id),
      title: json['title']?.toString() ?? 'Untitled Property',
      price: _formatPrice(json['price']),
      propertyType: _mapPropertyType(json['propertyType']?.toString()),
      postType: PostType.sellPost,
      status: _mapStatus(json['status']?.toString()),
      isVerified: json['isVerified'] == true,
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl
          : null,
      timestamp: _formatTimeAgo(createdAt),
      timestampPrefix: _mapTimestampPrefix(json['status']?.toString()),
      quotesCount: _resolveQuotesCount(json),
    );
  }

  static String _resolvePostId(String? rawPostId, String id) {
    if (rawPostId != null && rawPostId.trim().isNotEmpty) return rawPostId;
    if (id.isEmpty) return '#POST';
    final short = id.length > 8 ? id.substring(0, 8).toUpperCase() : id;
    return '#POST-$short';
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

  static MyPostStatus _mapStatus(String? rawStatus) {
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

  static String _mapTimestampPrefix(String? rawStatus) {
    final status = _mapStatus(rawStatus);
    switch (status) {
      case MyPostStatus.pending:
        return 'Submitted:';
      case MyPostStatus.active:
        return 'Posted:';
      case MyPostStatus.draft:
        return 'Edited:';
      case MyPostStatus.quoted:
      default:
        return 'Submitted:';
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

  static String _formatTimeAgo(String? createdAtRaw) {
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

  static int _resolveQuotesCount(Map<String, dynamic> json) {
    final rawCount =
        json['quotesCount'] ?? json['quoteCount'] ?? json['offersCount'];
    if (rawCount is num) return rawCount.toInt();
    return int.tryParse(rawCount?.toString() ?? '') ?? 0;
  }
}
