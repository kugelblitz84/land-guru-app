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
  final String rawType;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
    this.isActionRequired = false,
    this.relatedId,
    this.rawType = NotificationTypes.general,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawType = _readString(json, 'type').toUpperCase();
    final createdAt = _readDateTime(json, 'createdAt');
    final title = _readString(json, 'title');
    final description = _readString(json, 'message');

    return NotificationItem(
      id: _readString(json, 'id'),
      title: title.isEmpty ? 'Notification' : title,
      description: description.isEmpty ? title : description,
      timeAgo: _formatTimeAgo(createdAt),
      type: _mapRawTypeToUiType(rawType),
      isRead: _readBool(json, 'isRead'),
      isActionRequired: _isActionRequired(rawType),
      relatedId: _readString(json, 'referenceId'),
      rawType: rawType,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    String? type,
    bool? isRead,
    bool? isActionRequired,
    String? relatedId,
    String? rawType,
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
      rawType: rawType ?? this.rawType,
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

  static String _mapRawTypeToUiType(String rawType) {
    if (rawType.contains('APPOINTMENT') || rawType.contains('VISIT')) {
      return NotificationTypes.appointment;
    }
    if (rawType.contains('QUOTE')) {
      return NotificationTypes.quote;
    }
    if (rawType.contains('ASSIGNED') || rawType.contains('TASK')) {
      return NotificationTypes.offerPost;
    }
    if (rawType.contains('PROFILE') || rawType.contains('VERIFIED')) {
      return NotificationTypes.profileVerified;
    }
    if (rawType.contains('POST') || rawType.contains('OFFER')) {
      return NotificationTypes.newPost;
    }
    return NotificationTypes.general;
  }

  static bool _isActionRequired(String rawType) {
    const actionTypes = <String>{
      'POST_QUOTED',
      'POST_REJECTED',
      'NEW_ASSIGNMENT',
      'TASK_ASSIGNED',
      'ACTION_REQUIRED',
      'PAYMENT_REQUIRED',
    };

    if (actionTypes.contains(rawType)) {
      return true;
    }

    return rawType.contains('ASSIGNED') || rawType.contains('ACTION');
  }

  static String _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static bool _readBool(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }

    return false;
  }

  static DateTime _readDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is DateTime) {
      return value;
    }

    if (value != null) {
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) {
        return parsed.toLocal();
      }
    }

    return DateTime.now();
  }

  static String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class NotificationHistoryQuery {
  const NotificationHistoryQuery({this.page = 1, this.limit = 20});

  final int page;
  final int limit;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{'page': page, 'limit': limit};
  }
}

class NotificationHistoryModel {
  const NotificationHistoryModel({
    required this.notifications,
    required this.meta,
  });

  final List<NotificationItem> notifications;
  final NotificationMeta meta;
}

class NotificationMeta {
  const NotificationMeta({
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: _asInt(json['total']),
      unreadCount: _asInt(json['unreadCount']),
      page: _asInt(json['page']),
      limit: _asInt(json['limit']),
      totalPages: _asInt(json['totalPages']),
    );
  }

  final int total;
  final int unreadCount;
  final int page;
  final int limit;
  final int totalPages;

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class RegisterFcmTokenPayload {
  const RegisterFcmTokenPayload({
    required this.fcmToken,
    required this.deviceType,
  });

  final String fcmToken;
  final String deviceType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'fcmToken': fcmToken, 'deviceType': deviceType};
  }
}
