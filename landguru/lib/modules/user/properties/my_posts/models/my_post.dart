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
}
