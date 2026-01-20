import 'package:flutter/material.dart';
import '../../../../../../core/enums/property_type.dart';
import '../../../../../../core/theme/app_colors.dart';

/// Status enum for Offered Posts (offers made by user on Wanted/Needs posts)
enum OfferedPostStatus {
  pendingBuyerReview, // Waiting for buyer to review the offer
  buyerAccepted, // Buyer has accepted the offer
  buyerRejected, // Buyer has rejected the offer
  completed, // Post completed and appointment scheduled
}

extension OfferedPostStatusExtension on OfferedPostStatus {
  String get label {
    switch (this) {
      case OfferedPostStatus.pendingBuyerReview:
        return 'Pending Buyer Review';
      case OfferedPostStatus.buyerAccepted:
        return 'Buyer Accepted';
      case OfferedPostStatus.buyerRejected:
        return 'Buyer Rejected';
      case OfferedPostStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OfferedPostStatus.pendingBuyerReview:
        return AppColors.warning;
      case OfferedPostStatus.buyerAccepted:
        return AppColors.success;
      case OfferedPostStatus.buyerRejected:
        return AppColors.error;
      case OfferedPostStatus.completed:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OfferedPostStatus.pendingBuyerReview:
        return AppColors.warningLight;
      case OfferedPostStatus.buyerAccepted:
        return AppColors.successLight;
      case OfferedPostStatus.buyerRejected:
        return AppColors.error.withAlpha(30);
      case OfferedPostStatus.completed:
        return AppColors.primary.withAlpha(30);
    }
  }

  Color get textColor {
    switch (this) {
      case OfferedPostStatus.pendingBuyerReview:
        return AppColors.warning;
      case OfferedPostStatus.buyerAccepted:
        return AppColors.success;
      case OfferedPostStatus.buyerRejected:
        return AppColors.error;
      case OfferedPostStatus.completed:
        return AppColors.primary;
    }
  }
}

/// Model for Offered Post (offer made by user on a Wanted/Needs post)
class OfferedPost {
  final String id;
  final String postId;
  final String propertyTitle;
  final String propertyPrice;
  final PropertyType propertyType;
  final String? propertyImageUrl;
  final OfferedPostStatus status;
  final String timestamp;
  final String timestampPrefix;

  // Property details
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? location;
  final List<String>? propertyPhotos;

  // Buyer info (the person who posted the Wanted/Needs)
  final String buyerId;
  final String buyerName;
  final bool buyerVerified;
  final String? buyerImageUrl;

  // Original buy post reference
  final String originalBuyPostId;
  final String originalBuyPostTitle;

  // Time tracking for button activation
  final DateTime offeredAt;
  final DateTime? canMakeSellPostAt; // 3 days after offer

  const OfferedPost({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.propertyPrice,
    required this.propertyType,
    this.propertyImageUrl,
    required this.status,
    required this.timestamp,
    required this.timestampPrefix,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.location,
    this.propertyPhotos,
    required this.buyerId,
    required this.buyerName,
    this.buyerVerified = false,
    this.buyerImageUrl,
    required this.originalBuyPostId,
    required this.originalBuyPostTitle,
    required this.offeredAt,
    this.canMakeSellPostAt,
  });

  String get propertyTypeLabel => propertyType.label;
  Color get propertyTypeColor => propertyType.color;
  String get statusLabel => status.label;
  Color get statusColor => status.color;
  Color get statusTextColor => status.textColor;
  Color get statusBackgroundColor => status.backgroundColor;

  /// Check if user can make this a sell post (3 days passed or for demo always true)
  bool get canMakeSellPost {
    // For demo purposes, always return true
    return true;
    // In production:
    // if (canMakeSellPostAt == null) return false;
    // return DateTime.now().isAfter(canMakeSellPostAt!);
  }

  /// Get the date when user can make a sell post
  String get canMakeSellPostDateText {
    if (canMakeSellPostAt == null) return '';
    final date = canMakeSellPostAt!;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Determines the card border color based on status
  Color? get cardBorderColor {
    if (status == OfferedPostStatus.buyerAccepted) {
      return AppColors.success;
    }
    return null;
  }

  /// Whether to show "Complete This Post" button
  bool get showCompleteButton => status == OfferedPostStatus.buyerAccepted;

  /// Whether to show "Make this a sell post instead" button
  bool get showMakeSellPostButton =>
      status == OfferedPostStatus.pendingBuyerReview;
}
