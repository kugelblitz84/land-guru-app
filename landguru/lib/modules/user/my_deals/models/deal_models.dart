import 'package:flutter/material.dart';
import '../../../../core/enums/property_type.dart';
import '../../../../core/theme/app_colors.dart';

/// Tab enum for Sold/Bought
enum DealTab { sold, bought }

/// Deal status
enum DealStatus { sold, bought }

extension DealStatusExtension on DealStatus {
  String get label {
    switch (this) {
      case DealStatus.sold:
        return 'Sold';
      case DealStatus.bought:
        return 'Bought';
    }
  }

  Color get backgroundColor => AppColors.success;
  Color get textColor => AppColors.white;
}

/// Sort options for deals
enum DealSortBy { newest, oldest, priceHighToLow, priceLowToHigh }

extension DealSortByExtension on DealSortBy {
  String get label {
    switch (this) {
      case DealSortBy.newest:
        return 'Newest';
      case DealSortBy.oldest:
        return 'Oldest';
      case DealSortBy.priceHighToLow:
        return 'Price: High to Low';
      case DealSortBy.priceLowToHigh:
        return 'Price: Low to High';
    }
  }
}

/// Filter by property type
enum DealTypeFilter { all, flat, plainLand, waterLand }

extension DealTypeFilterExtension on DealTypeFilter {
  String get label {
    switch (this) {
      case DealTypeFilter.all:
        return 'All';
      case DealTypeFilter.flat:
        return 'Flat';
      case DealTypeFilter.plainLand:
        return 'Plain Land';
      case DealTypeFilter.waterLand:
        return 'Water Land';
    }
  }
}

/// Deal model for sold/bought properties
class Deal {
  final String id;
  final String postId;
  final String propertyTitle;
  final String? propertyImageUrl;
  final PropertyType propertyType;
  final String location;
  final String soldPrice;
  final DealStatus status;
  final DateTime dealDate;
  final String? description;

  // Property details
  final String? soldLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final List<String>? propertyPhotos;

  // Buyer/Seller info (depending on if sold or bought)
  final String? otherPartyId;
  final String? otherPartyName;
  final String? otherPartyAvatar;
  final bool otherPartyVerified;

  // Unlocked features
  final bool hasHideDueDiligence;
  final bool hasPropertyVideo;
  final bool hasOwnershipHistory;
  final String? propertyVideoUrl;

  // Legal documents
  final List<LegalDocument>? deedDocuments;
  final List<LegalDocument>? khatianDocuments;
  final List<LegalDocument>? porchagophMapDocuments;

  // Services taken
  final List<ServiceTaken>? servicesTaken;

  Deal({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    this.propertyImageUrl,
    required this.propertyType,
    required this.location,
    required this.soldPrice,
    required this.status,
    required this.dealDate,
    this.description,
    this.soldLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.propertyPhotos,
    this.otherPartyId,
    this.otherPartyName,
    this.otherPartyAvatar,
    this.otherPartyVerified = false,
    this.hasHideDueDiligence = false,
    this.hasPropertyVideo = false,
    this.hasOwnershipHistory = false,
    this.propertyVideoUrl,
    this.deedDocuments,
    this.khatianDocuments,
    this.porchagophMapDocuments,
    this.servicesTaken,
  });

  /// Get property type label
  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  /// Get property type color
  Color get propertyTypeColor {
    switch (propertyType) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32);
      case PropertyType.waterLand:
        return const Color(0xFF0288D1);
      case PropertyType.flat:
        return AppColors.primary;
    }
  }

  /// Get formatted deal time ago
  String get dealTimeAgo {
    final diff = DateTime.now().difference(dealDate);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Get "Sold To" or "Bought From" label
  String get otherPartyLabel =>
      status == DealStatus.sold ? 'Sold To' : 'Bought From';
}

/// Legal document model
class LegalDocument {
  final String id;
  final String name;
  final String? fileUrl;
  final String fileType; // pdf, docx, etc.

  LegalDocument({
    required this.id,
    required this.name,
    this.fileUrl,
    required this.fileType,
  });
}

/// Service taken model
class ServiceTaken {
  final String id;
  final String serviceName;
  final String? agentName;
  final String? agentAvatar;
  final String status; // Pending, Completed, etc.

  ServiceTaken({
    required this.id,
    required this.serviceName,
    this.agentName,
    this.agentAvatar,
    required this.status,
  });
}

/// Stats for deals
class DealStats {
  final int propertySold;
  final String totalEarned;
  final int propertyBought;
  final String totalSpent;

  DealStats({
    this.propertySold = 0,
    this.totalEarned = '0',
    this.propertyBought = 0,
    this.totalSpent = '0',
  });
}
