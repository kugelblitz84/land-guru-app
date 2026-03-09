import 'package:flutter/material.dart';

/// Notification type constants.
class NotificationTypes {
  static const String offerPost = 'offer_post';
  static const String quote = 'quote';
  static const String serviceUpdate = 'service_update';
  static const String appointment = 'appointment';
  static const String profileVerified = 'profile_verified';
  static const String newPost = 'new_post';
  static const String general = 'general';
}

/// Notification filter constants.
class NotificationFilters {
  static const String all = 'all';
  static const String actionRequired = 'action_required';
  static const String appointments = 'appointments';
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String type;
  final bool isRead;
  final bool isActionRequired;
  final String? relatedId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
    this.isActionRequired = false,
    this.relatedId,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    String? type,
    bool? isRead,
    bool? isActionRequired,
    String? relatedId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isActionRequired: isActionRequired ?? this.isActionRequired,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationTypes.offerPost:
      case NotificationTypes.quote:
        return Icons.warning_amber_rounded;
      case NotificationTypes.serviceUpdate:
        return Icons.description_outlined;
      case NotificationTypes.appointment:
        return Icons.calendar_today_outlined;
      case NotificationTypes.profileVerified:
        return Icons.info_outline;
      case NotificationTypes.newPost:
        return Icons.local_offer_outlined;
      case NotificationTypes.general:
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get iconBackgroundColor {
    switch (type) {
      case NotificationTypes.offerPost:
      case NotificationTypes.quote:
        return const Color(0xFFFFEBEE);
      case NotificationTypes.serviceUpdate:
        return const Color(0xFFF5F5F5);
      case NotificationTypes.appointment:
        return const Color(0xFFE8F5E9);
      case NotificationTypes.profileVerified:
        return const Color(0xFFF5F5F5);
      case NotificationTypes.newPost:
        return const Color(0xFFE3F2FD);
      case NotificationTypes.general:
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationTypes.offerPost:
      case NotificationTypes.quote:
        return const Color(0xFFF44336);
      case NotificationTypes.serviceUpdate:
        return const Color(0xFF757575);
      case NotificationTypes.appointment:
        return const Color(0xFF4CAF50);
      case NotificationTypes.profileVerified:
        return const Color(0xFF757575);
      case NotificationTypes.newPost:
        return const Color(0xFF3B6CF5);
      case NotificationTypes.general:
      default:
        return const Color(0xFF757575);
    }
  }
}
