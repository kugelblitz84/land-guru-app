import 'package:flutter/material.dart';

import '../../../../core/enums/property_type.dart';
import '../../../../core/theme/app_colors.dart';

/// String constants for agent appointments primary tabs.
class AgentAppointmentTabs {
  static const String upcoming = 'upcoming';
  static const String past = 'past';
}

/// String constants and style helpers for agent appointment status.
class AgentAppointmentStatuses {
  static const String visitToday = 'visit_today';
  static const String upcomingVisit = 'upcoming_visit';
  static const String visited = 'visited';

  static String label(String status) {
    switch (status) {
      case visitToday:
        return 'Visit Today';
      case upcomingVisit:
        return 'Upcoming Visit';
      case visited:
        return 'Visited';
      default:
        return 'Unknown';
    }
  }

  static Color backgroundColor(String status) {
    switch (status) {
      case visitToday:
        return AppColors.success;
      case upcomingVisit:
        return AppColors.primary;
      case visited:
        return AppColors.grey400;
      default:
        return AppColors.grey400;
    }
  }

  static Color textColor(String status) {
    return AppColors.white;
  }
}

/// View model for agent appointment card rows.
class AgentAppointment {
  final String id;
  final String postId;
  final String propertyTitle;
  final PropertyType propertyType;
  final String location;
  final String status;
  final DateTime appointmentDate;
  final String serviceType;

  AgentAppointment({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.propertyType,
    required this.location,
    required this.status,
    required this.appointmentDate,
    required this.serviceType,
  });

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

  String get formattedMonth {
    const months = [
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

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }
}

class AgentAppointmentsMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AgentAppointmentsMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AgentAppointmentsMeta.fromJson(Map<String, dynamic> json) {
    return AgentAppointmentsMeta(
      total: _readInt(json, 'total') ?? 0,
      page: _readInt(json, 'page') ?? 1,
      limit: _readInt(json, 'limit') ?? 10,
      totalPages: _readInt(json, 'totalPages') ?? 1,
    );
  }
}

class AgentAppointmentApiModel {
  final String id;
  final String postId;
  final String propertyTitle;
  final String propertyType;
  final String location;
  final String status;
  final DateTime? appointmentDate;
  final String serviceType;

  const AgentAppointmentApiModel({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.propertyType,
    required this.location,
    required this.status,
    required this.appointmentDate,
    required this.serviceType,
  });

  factory AgentAppointmentApiModel.fromJson(Map<String, dynamic> json) {
    // NOTE: Postman does not include concrete response samples for
    // /agents/appointments and /agents/appointments/{assignmentId}.
    // We map only documented keys from appointment schedule examples and keep
    // unknown fields empty instead of guessing aliases.
    final property = _readMap(json, 'property');
    final serviceType = _readMap(json, 'serviceType');

    return AgentAppointmentApiModel(
      id: _readString(json, 'id') ?? '',
      postId: _readString(property, 'id') ?? '',
      propertyTitle:
        _readString(property, 'title') ??
        _readString(json, 'propertyTitle') ??
          'Untitled Property',
      propertyType:
        _readString(property, 'propertyType') ??
        _readString(json, 'propertyType') ??
          'flat',
      location:
        _readString(property, 'location') ??
        _readString(json, 'location') ??
          '',
      status: _readString(json, 'status') ?? '',
      appointmentDate: _readDateTime(json, 'timeAndDate'),
      serviceType:
        _readString(serviceType, 'name') ??
        _readString(json, 'serviceName') ??
          'N/A',
    );
  }
}

class AgentAppointmentsListResponse {
  final List<AgentAppointmentApiModel> data;
  final AgentAppointmentsMeta meta;

  const AgentAppointmentsListResponse({required this.data, required this.meta});

  factory AgentAppointmentsListResponse.fromJson(Map<String, dynamic> json) {
    final rootData = json['data'];
    final list = rootData is List ? rootData : null;

    final rawItems = list is List ? list : <dynamic>[];
    final items = rawItems
        .whereType<Map>()
        .map(
          (entry) => AgentAppointmentApiModel.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();

    final rawMeta = json['meta'];
    final metaMap = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : <String, dynamic>{};

    return AgentAppointmentsListResponse(
      data: items,
      meta: AgentAppointmentsMeta.fromJson(metaMap),
    );
  }
}

class AgentAppointmentDetails {
  final String id;
  final String postId;
  final String propertyTitle;
  final String serviceType;
  final String location;
  final String status;
  final DateTime? appointmentDate;

  const AgentAppointmentDetails({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.serviceType,
    required this.location,
    required this.status,
    required this.appointmentDate,
  });

  factory AgentAppointmentDetails.fromJson(Map<String, dynamic> json) {
    final property = _readMap(json, 'property');
    final serviceType = _readMap(json, 'serviceType');

    return AgentAppointmentDetails(
      id: _readString(json, 'id') ?? '',
      postId: _readString(property, 'id') ?? '',
      propertyTitle:
          _readString(property, 'title') ??
          _readString(json, 'propertyTitle') ??
          'Untitled Property',
      serviceType:
          _readString(serviceType, 'name') ??
          _readString(json, 'serviceName') ??
          'N/A',
      location:
          _readString(property, 'location') ??
          _readString(json, 'location') ??
          '',
      status: _readString(json, 'status') ?? '',
      appointmentDate: _readDateTime(json, 'timeAndDate'),
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String? _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null) {
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

int? _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

DateTime? _readDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}
