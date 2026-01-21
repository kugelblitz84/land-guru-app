import 'package:flutter/material.dart';

/// Model for property details - used by property_details, home, for_sale features
class PropertyDetails {
  final String id;
  final String postId;
  final String title;
  final String price;
  final String propertyType;
  final String postType;
  final bool isVerified;
  final bool isLocked;
  final String description;
  final String location;
  final String sellableLandAmount;
  final String plotSize;
  final String? shareUnit; // Optional - only for properties with share units
  final String distanceFromRoad;
  final String? landShapeImageUrl;
  final List<String> propertyPhotos;
  final String postedBy;
  final String postedTime;
  final bool hasRequestedAppointment;

  PropertyDetails({
    required this.id,
    required this.postId,
    required this.title,
    required this.price,
    required this.propertyType,
    required this.postType,
    this.isVerified = false,
    this.isLocked = true,
    required this.description,
    required this.location,
    required this.sellableLandAmount,
    required this.plotSize,
    this.shareUnit,
    required this.distanceFromRoad,
    this.landShapeImageUrl,
    this.propertyPhotos = const [],
    required this.postedBy,
    required this.postedTime,
    this.hasRequestedAppointment = false,
  });

  Color get propertyTypeColor {
    switch (propertyType.toLowerCase()) {
      case 'plain land':
        return const Color(0xFF2E7D32);
      case 'water land':
        return const Color(0xFF0288D1);
      case 'flat':
        return const Color(0xFF3B6CF5);
      default:
        return const Color(0xFF3B6CF5);
    }
  }

  /// Convert to Map for navigation arguments
  Map<String, dynamic> toMap({bool? overrideLocked}) {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'price': price,
      'propertyType': propertyType,
      'postType': postType,
      'isVerified': isVerified,
      'isLocked': overrideLocked ?? isLocked,
      'description': description,
      'location': location,
      'sellableLandAmount': sellableLandAmount,
      'plotSize': plotSize,
      'shareUnit': shareUnit,
      'distanceFromRoad': distanceFromRoad,
      'postedBy': postedBy,
      'postedTime': postedTime,
      'propertyPhotos': propertyPhotos,
    };
  }
}
