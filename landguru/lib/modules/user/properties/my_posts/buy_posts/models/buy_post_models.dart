import 'package:flutter/material.dart';
import '../../../../../../core/enums/property_type.dart';
import '../../../../../../core/theme/app_colors.dart';

/// Status enum for Buy Posts
enum BuyPostStatus { pending, active, draft, completed }

extension BuyPostStatusExtension on BuyPostStatus {
  String get label {
    switch (this) {
      case BuyPostStatus.pending:
        return 'Pending';
      case BuyPostStatus.active:
        return 'Active';
      case BuyPostStatus.draft:
        return 'Draft';
      case BuyPostStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case BuyPostStatus.pending:
        return AppColors.warning;
      case BuyPostStatus.active:
        return AppColors.success;
      case BuyPostStatus.draft:
        return AppColors.grey500;
      case BuyPostStatus.completed:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BuyPostStatus.pending:
        return AppColors.warningLight;
      case BuyPostStatus.active:
        return AppColors.successLight;
      case BuyPostStatus.draft:
        return AppColors.grey200;
      case BuyPostStatus.completed:
        return AppColors.primary.withAlpha(30);
    }
  }

  Color get textColor {
    switch (this) {
      case BuyPostStatus.pending:
        return AppColors.warning;
      case BuyPostStatus.active:
        return AppColors.success;
      case BuyPostStatus.draft:
        return AppColors.grey600;
      case BuyPostStatus.completed:
        return AppColors.primary;
    }
  }
}

/// Status for offers received on buy posts
enum OfferReceivedStatus {
  pending, // Offer sent by seller, waiting for buyer action
  accepted, // Buyer accepted the offer
  rejected, // Buyer rejected the offer
  pendingAdminReview, // Buyer accepted, pending admin review
  appointmentScheduled, // Admin approved, appointment scheduled
}

extension OfferReceivedStatusExtension on OfferReceivedStatus {
  String get label {
    switch (this) {
      case OfferReceivedStatus.pending:
        return 'Pending';
      case OfferReceivedStatus.accepted:
        return 'Accepted';
      case OfferReceivedStatus.rejected:
        return 'Rejected';
      case OfferReceivedStatus.pendingAdminReview:
        return 'Pending Admin Review';
      case OfferReceivedStatus.appointmentScheduled:
        return 'Appointment Scheduled';
    }
  }

  Color get color {
    switch (this) {
      case OfferReceivedStatus.pending:
        return AppColors.warning;
      case OfferReceivedStatus.accepted:
        return AppColors.success;
      case OfferReceivedStatus.rejected:
        return AppColors.error;
      case OfferReceivedStatus.pendingAdminReview:
        return AppColors.grey600;
      case OfferReceivedStatus.appointmentScheduled:
        return AppColors.primary;
    }
  }
}

/// Model for Buy Post (user's buy request)
class BuyPost {
  final String id;
  final String postId;
  final String title;
  final String preferredLocation;
  final PropertyType propertyType;
  final String requiredLandSize;
  final String requiredPlotSize;
  final String distanceFromRoad;
  final String budgetRange;
  final String? description;
  final BuyPostStatus status;
  final String timestamp;
  final String timestampPrefix;
  final List<OfferReceived> offersReceived;
  final OfferReceived? acceptedOffer;

  const BuyPost({
    required this.id,
    required this.postId,
    required this.title,
    required this.preferredLocation,
    required this.propertyType,
    required this.requiredLandSize,
    required this.requiredPlotSize,
    required this.distanceFromRoad,
    required this.budgetRange,
    this.description,
    required this.status,
    required this.timestamp,
    required this.timestampPrefix,
    this.offersReceived = const [],
    this.acceptedOffer,
  });

  int get offersCount => offersReceived.length;

  bool get hasOffers => offersReceived.isNotEmpty;

  /// Determines the card border color based on status and offers
  Color? get cardBorderColor {
    if (status == BuyPostStatus.active && hasOffers) {
      // Red border: Active + >0 offers received
      return AppColors.error;
    } else if (acceptedOffer != null) {
      if (acceptedOffer!.status == OfferReceivedStatus.pendingAdminReview ||
          acceptedOffer!.status == OfferReceivedStatus.appointmentScheduled) {
        // Green border: Accepted offer + pending admin review or appointment
        return AppColors.success;
      }
    }
    // No special border for other statuses
    return null;
  }

  /// Whether to show View Appointment button
  bool get showViewAppointment =>
      acceptedOffer?.status == OfferReceivedStatus.appointmentScheduled;

  /// Whether to show Pending Admin Review badge
  bool get showPendingAdminReview =>
      acceptedOffer?.status == OfferReceivedStatus.pendingAdminReview;

  String get propertyTypeLabel => propertyType.label;
  Color get propertyTypeColor => propertyType.color;
  String get statusLabel => status.label;
  Color get statusColor => status.color;
  Color get statusTextColor => status.textColor;
  Color get statusBackgroundColor => status.backgroundColor;
}

/// Model for Offer Received on a Buy Post
class OfferReceived {
  final String id;
  final String propertyTitle;
  final String propertyPrice;
  final PropertyType propertyType;
  final String? propertyImageUrl;
  final String offeredTime;
  final OfferReceivedStatus status;
  final String sellerId;
  final String sellerName;
  final bool sellerVerified;
  final String? sellerImageUrl;

  // Property details (for offer details page)
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? location;
  final List<String>? propertyPhotos;
  final String? postId;

  const OfferReceived({
    required this.id,
    required this.propertyTitle,
    required this.propertyPrice,
    required this.propertyType,
    this.propertyImageUrl,
    required this.offeredTime,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    this.sellerVerified = false,
    this.sellerImageUrl,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.location,
    this.propertyPhotos,
    this.postId,
  });

  String get propertyTypeLabel => propertyType.label;
  Color get propertyTypeColor => propertyType.color;
  String get statusLabel => status.label;
  Color get statusColor => status.color;
}
