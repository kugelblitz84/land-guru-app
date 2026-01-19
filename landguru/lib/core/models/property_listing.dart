import 'package:flutter/material.dart';
import '../enums/property_type.dart';
import '../enums/post_type.dart';

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
      'postedTime': postedTime,
      'propertyPhotos': propertyPhotos,
    };
  }
}
