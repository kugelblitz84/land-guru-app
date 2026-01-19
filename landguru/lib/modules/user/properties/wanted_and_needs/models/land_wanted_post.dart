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
