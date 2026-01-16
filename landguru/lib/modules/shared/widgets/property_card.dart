import 'package:flutter/material.dart';

/// Reusable property card widget for listings
class PropertyCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String location;
  final String price;
  final String? propertyType;
  final String? status;
  final bool isVerified;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const PropertyCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.propertyType,
    this.status,
    this.isVerified = false,
    this.onTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement property card UI
    // - Property image
    // - Type badges (Flat, Plain Land, etc.)
    // - Status badge (Verified, Pending, etc.)
    // - Title
    // - Location with icon
    // - Price
    // - View Details button
    return const Placeholder();
  }
}
