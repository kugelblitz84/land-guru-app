import 'package:flutter/material.dart';
import '../../../../core/enums/property_type.dart';
import '../../../../core/theme/app_colors.dart';

/// String constants for primary appointment tabs.
class AppointmentTabs {
  static const String upcoming = 'upcoming';
  static const String past = 'past';
}

/// String constants for upcoming filters.
class UpcomingFilters {
  static const String myRequests = 'my_requests';
  static const String upcomingVisit = 'upcoming_visit';
  static const String agentVisit = 'agent_visit';
}

/// String constants for upcoming API filters.
class UpcomingApiFilters {
  static const String myRequests = 'my_requests';
  static const String upcomingVisits = 'upcoming_visits';
  static const String agentVisits = 'agent_visits';

  static String queryValue(String filter) {
    switch (filter) {
      case myRequests:
        return 'MY_REQUESTS';
      case upcomingVisits:
        return 'UPCOMING_VISITS';
      case agentVisits:
        return 'AGENT_VISITS';
      default:
        return 'MY_REQUESTS';
    }
  }
}

/// String constants for past filters.
class PastFilters {
  static const String myVisit = 'my_visit';
  static const String agentVisit = 'agent_visit';
}

/// String constants for past API filters.
class PastApiFilters {
  static const String myVisits = 'my_visits';
  static const String agentVisits = 'agent_visits';

  static String queryValue(String filter) {
    switch (filter) {
      case myVisits:
        return 'MY_VISITS';
      case agentVisits:
        return 'AGENT_VISITS';
      default:
        return 'MY_VISITS';
    }
  }
}

/// String constants and UI helpers for appointment statuses.
class AppointmentStatuses {
  static const String pendingAdminReview = 'pending_admin_review';
  static const String visitToday = 'visit_today';
  static const String upcomingVisit = 'upcoming_visit';
  static const String visited = 'visited';
  static const String cancelled = 'cancelled';

  static String label(String status) {
    switch (status) {
      case pendingAdminReview:
        return 'Pending Admin Review';
      case visitToday:
        return 'Visit Today';
      case upcomingVisit:
        return 'Upcoming Visit';
      case visited:
        return 'Visited';
      case cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static Color backgroundColor(String status) {
    switch (status) {
      case pendingAdminReview:
        return AppColors.grey200;
      case visitToday:
        return AppColors.success;
      case upcomingVisit:
        return AppColors.primary;
      case visited:
        return AppColors.success;
      case cancelled:
        return AppColors.error;
      default:
        return AppColors.grey200;
    }
  }

  static Color textColor(String status) {
    switch (status) {
      case pendingAdminReview:
        return AppColors.grey600;
      default:
        return AppColors.white;
    }
  }
}

/// Base appointment model
class Appointment {
  final String id;
  final String postId;
  final String propertyTitle;
  final String? propertyImageUrl;
  final PropertyType propertyType;
  final String location;
  final String status;
  final DateTime appointmentDate;
  final DateTime? requestedAt;

  // For My Requests
  final String? price;

  // For Upcoming/Past Visits
  final String? clientName;
  final String? clientId;

  // For Agent Visits
  final String? serviceType;
  final String? agentName;
  final String? agentId;

  Appointment({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    this.propertyImageUrl,
    required this.propertyType,
    required this.location,
    required this.status,
    required this.appointmentDate,
    this.requestedAt,
    this.price,
    this.clientName,
    this.clientId,
    this.serviceType,
    this.agentName,
    this.agentId,
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

  /// Format date as "Jan 25"
  String get formattedMonth {
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
    return months[appointmentDate.month - 1];
  }

  String get formattedDay => appointmentDate.day.toString();

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  /// Get formatted requested time ago
  String get requestedTimeAgo {
    if (requestedAt == null) return '';
    final diff = DateTime.now().difference(requestedAt!);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final sellPost = _asMap(json['sellPost']);
    final appointment = _asMap(json['appointment']);

    final rawPostId =
        _readString(sellPost, ['id']) ??
        _readString(json, ['postId', 'sellPostId', 'id']) ??
        '';
    final requestedAt =
        _parseDateTime(_readString(appointment, ['requestedAt'])) ??
        _parseDateTime(_readString(json, ['requestedAt']));
    final scheduledDate =
        _parseDateTime(_readString(appointment, ['scheduledDate'])) ??
        _parseDateTime(_readString(json, ['appointmentDate']));
    final status = _mapStatus(
      rawStatus:
          _readString(appointment, ['status']) ??
          _readString(json, ['status']) ??
          '',
      scheduledDate: scheduledDate,
    );

    return Appointment(
      id:
          _readString(appointment, ['id']) ??
          _readString(json, ['id', 'appointmentId']) ??
          '',
      postId: _formatPostId(rawPostId),
      propertyTitle:
          _readString(sellPost, ['title']) ??
          _readString(json, ['propertyTitle', 'title']) ??
          'Untitled Property',
      propertyImageUrl:
          _readString(sellPost, ['image']) ??
          _readString(json, ['propertyImageUrl', 'image']),
      propertyType: _mapPropertyType(
        _readString(sellPost, ['propertyType']) ??
            _readString(json, ['propertyType']) ??
            'Flat',
      ),
      location:
          _readString(sellPost, ['location']) ??
          _readString(json, ['location']) ??
          '',
      status: status,
      appointmentDate: scheduledDate ?? requestedAt ?? DateTime.now(),
      requestedAt: requestedAt,
      price:
          _formatPrice(_readDynamic(sellPost, ['askingPrice'])) ??
          _readString(json, ['price']),
      clientName:
          _readString(appointment, ['clientName']) ??
          _readString(json, ['clientName']),
      clientId:
          _readString(appointment, ['clientId']) ??
          _readString(json, ['clientId']),
      serviceType:
          _readString(appointment, ['serviceType']) ??
          _readString(json, ['serviceType']),
      agentName:
          _readString(appointment, ['agentName']) ??
          _readString(json, ['agentName']),
      agentId:
          _readString(appointment, ['agentId']) ??
          _readString(json, ['agentId']),
    );
  }

  static PropertyType _mapPropertyType(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    switch (normalized) {
      case 'plainland':
      case 'plain land':
      case 'land':
      case 'agroland':
        return PropertyType.plainLand;
      case 'waterland':
      case 'water land':
      case 'water':
        return PropertyType.waterLand;
      case 'flat':
      default:
        return PropertyType.flat;
    }
  }

  static String _mapStatus({
    required String rawStatus,
    required DateTime? scheduledDate,
  }) {
    final normalized = rawStatus.trim().toUpperCase();
    switch (normalized) {
      case 'PENDING':
      case 'PENDING_ADMIN_REVIEW':
        return AppointmentStatuses.pendingAdminReview;
      case 'VISITED':
      case 'COMPLETED':
        return AppointmentStatuses.visited;
      case 'CANCELLED':
        return AppointmentStatuses.cancelled;
    }

    if (scheduledDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      if (dateOnly == today) {
        return AppointmentStatuses.visitToday;
      }

      if (dateOnly.isAfter(today)) {
        return AppointmentStatuses.upcomingVisit;
      }
    }

    return AppointmentStatuses.pendingAdminReview;
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _readString(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) {
      return null;
    }
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static dynamic _readDynamic(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) {
      return null;
    }
    for (final key in keys) {
      if (map.containsKey(key)) {
        return map[key];
      }
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String? _formatPrice(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return _commaSeparateNumber(value.toInt());
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    final numeric = int.tryParse(text);
    if (numeric != null) {
      return _commaSeparateNumber(numeric);
    }

    return text;
  }

  static String _commaSeparateNumber(int value) {
    final isNegative = value < 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      final reverseIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }

  static String _formatPostId(String rawId) {
    if (rawId.isEmpty) {
      return '';
    }

    final compact = rawId.replaceAll('-', '').toUpperCase();
    final suffix = compact.length > 4
        ? compact.substring(compact.length - 4)
        : compact;
    return '#POST-$suffix';
  }
}

class AppointmentListMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AppointmentListMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AppointmentListMeta.fromJson(Map<String, dynamic> json) {
    return AppointmentListMeta(
      total: _readInt(json['total']) ?? 0,
      page: _readInt(json['page']) ?? 1,
      limit: _readInt(json['limit']) ?? 10,
      totalPages: _readInt(json['totalPages']) ?? 1,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}

class AppointmentListResponse {
  final List<Appointment> appointments;
  final AppointmentListMeta meta;

  const AppointmentListResponse({
    required this.appointments,
    required this.meta,
  });

  factory AppointmentListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List ? rawData : const <dynamic>[];

    final appointments = items
        .whereType<Map>()
        .map((item) => Appointment.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    final rawMeta = json['meta'];
    final metaMap = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : <String, dynamic>{};

    return AppointmentListResponse(
      appointments: appointments,
      meta: AppointmentListMeta.fromJson(metaMap),
    );
  }
}
