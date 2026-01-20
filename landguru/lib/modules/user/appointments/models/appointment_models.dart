import 'package:flutter/material.dart';
import '../../../../core/enums/property_type.dart';
import '../../../../core/theme/app_colors.dart';

/// Primary tab enum for Upcoming/Past
enum AppointmentTab { upcoming, past }

/// Secondary filter for Upcoming tab
enum UpcomingFilter { myRequests, upcomingVisit, agentVisit }

/// Secondary filter for Past tab
enum PastFilter { myVisit, agentVisit }

/// Status enum for appointments
enum AppointmentStatus {
  pendingAdminReview,
  visitToday,
  upcomingVisit,
  visited,
  cancelled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pendingAdminReview:
        return 'Pending Admin Review';
      case AppointmentStatus.visitToday:
        return 'Visit Today';
      case AppointmentStatus.upcomingVisit:
        return 'Upcoming Visit';
      case AppointmentStatus.visited:
        return 'Visited';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppointmentStatus.pendingAdminReview:
        return AppColors.grey200;
      case AppointmentStatus.visitToday:
        return AppColors.success;
      case AppointmentStatus.upcomingVisit:
        return AppColors.primary;
      case AppointmentStatus.visited:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get textColor {
    switch (this) {
      case AppointmentStatus.pendingAdminReview:
        return AppColors.grey600;
      case AppointmentStatus.visitToday:
      case AppointmentStatus.upcomingVisit:
      case AppointmentStatus.visited:
      case AppointmentStatus.cancelled:
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
  final AppointmentStatus status;
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
}
