import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Task status enum
enum TaskStatus { newRequest, active, inReview, done }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.newRequest:
        return 'NEW REQUEST';
      case TaskStatus.active:
        return 'ACTIVE';
      case TaskStatus.inReview:
        return 'IN REVIEW';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String get tabLabel {
    switch (this) {
      case TaskStatus.newRequest:
        return 'New';
      case TaskStatus.active:
        return 'Active';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskStatus.newRequest:
        return AppColors.secondary;
      case TaskStatus.active:
        return AppColors.primary;
      case TaskStatus.inReview:
        return AppColors.warning;
      case TaskStatus.done:
        return AppColors.success;
    }
  }

  Color get textColor {
    return AppColors.white;
  }
}

/// Task processing status - tracks the workflow stages
enum TaskProcessingStatus { accepted, processing, inReview, done }

extension TaskProcessingStatusExtension on TaskProcessingStatus {
  String get label {
    switch (this) {
      case TaskProcessingStatus.accepted:
        return 'Accepted';
      case TaskProcessingStatus.processing:
        return 'Processing';
      case TaskProcessingStatus.inReview:
        return 'In Review';
      case TaskProcessingStatus.done:
        return 'Done';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskProcessingStatus.accepted:
        return Icons.check;
      case TaskProcessingStatus.processing:
        return Icons.sync;
      case TaskProcessingStatus.inReview:
        return Icons.description_outlined;
      case TaskProcessingStatus.done:
        return Icons.check_circle;
    }
  }

  /// Check if this status is completed based on current status
  bool isCompleted(TaskProcessingStatus currentStatus) {
    return index < currentStatus.index;
  }

  /// Check if this is the current active status
  bool isActive(TaskProcessingStatus currentStatus) {
    return this == currentStatus;
  }
}

/// Task acceptance status
enum TaskAcceptanceStatus { pendingAccepting, accepted, rejected }

extension TaskAcceptanceStatusExtension on TaskAcceptanceStatus {
  String get label {
    switch (this) {
      case TaskAcceptanceStatus.pendingAccepting:
        return 'PENDING ACCEPTING';
      case TaskAcceptanceStatus.accepted:
        return 'ACCEPTED';
      case TaskAcceptanceStatus.rejected:
        return 'REJECTED';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskAcceptanceStatus.pendingAccepting:
        return AppColors.white;
      case TaskAcceptanceStatus.accepted:
        return AppColors.success;
      case TaskAcceptanceStatus.rejected:
        return AppColors.error;
    }
  }

  Color get textColor {
    switch (this) {
      case TaskAcceptanceStatus.pendingAccepting:
        return AppColors.primary;
      case TaskAcceptanceStatus.accepted:
        return AppColors.white;
      case TaskAcceptanceStatus.rejected:
        return AppColors.white;
    }
  }

  Color get borderColor {
    switch (this) {
      case TaskAcceptanceStatus.pendingAccepting:
        return AppColors.primary;
      case TaskAcceptanceStatus.accepted:
        return AppColors.success;
      case TaskAcceptanceStatus.rejected:
        return AppColors.error;
    }
  }
}

/// Property type for task
enum TaskPropertyType { flat, land, plot, building }

extension TaskPropertyTypeExtension on TaskPropertyType {
  String get label {
    switch (this) {
      case TaskPropertyType.flat:
        return 'Flat';
      case TaskPropertyType.land:
        return 'Land';
      case TaskPropertyType.plot:
        return 'Plot';
      case TaskPropertyType.building:
        return 'Building';
    }
  }

  Color get color {
    switch (this) {
      case TaskPropertyType.flat:
        return AppColors.primary;
      case TaskPropertyType.land:
        return AppColors.success;
      case TaskPropertyType.plot:
        return AppColors.warning;
      case TaskPropertyType.building:
        return AppColors.secondary;
    }
  }
}

/// Appointment status
enum AppointmentStatus { notScheduled, upcoming, visited, cancelled }

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.notScheduled:
        return 'Not Scheduled';
      case AppointmentStatus.upcoming:
        return 'UPCOMING VISIT';
      case AppointmentStatus.visited:
        return 'VISITED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppointmentStatus.notScheduled:
        return AppColors.grey200;
      case AppointmentStatus.upcoming:
        return AppColors.primary;
      case AppointmentStatus.visited:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get textColor {
    switch (this) {
      case AppointmentStatus.notScheduled:
        return AppColors.grey600;
      case AppointmentStatus.upcoming:
        return AppColors.white;
      case AppointmentStatus.visited:
        return AppColors.white;
      case AppointmentStatus.cancelled:
        return AppColors.white;
    }
  }
}

/// Service type enum
enum ServiceType {
  ownershipHistoryValidation,
  pentagraphMapVerification,
  physicalEstimateBorderDemarcation,
  deedWritingService,
  documentOrganization,
  namjariDcrUpdate,
  inheritanceDisputeAnalysis,
  governmentAcquisitionRisk,
  courtCaseVerification,
}

extension ServiceTypeExtension on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.ownershipHistoryValidation:
        return 'Ownership history validation';
      case ServiceType.pentagraphMapVerification:
        return 'Pentagraph Map Verification';
      case ServiceType.physicalEstimateBorderDemarcation:
        return 'Physical estimate and border demarcation';
      case ServiceType.deedWritingService:
        return 'Deed Writing Service';
      case ServiceType.documentOrganization:
        return 'Document Organization';
      case ServiceType.namjariDcrUpdate:
        return 'Namjari/DCR Update/ Pouro City Corp Record Update';
      case ServiceType.inheritanceDisputeAnalysis:
        return 'Inheritance Dispute Analysis';
      case ServiceType.governmentAcquisitionRisk:
        return 'Government Acquisition Risk';
      case ServiceType.courtCaseVerification:
        return 'Court Case Verification';
    }
  }

  String get shortLabel {
    switch (this) {
      case ServiceType.ownershipHistoryValidation:
        return 'Ownership Validation';
      case ServiceType.pentagraphMapVerification:
        return 'Pentagraph Map';
      case ServiceType.physicalEstimateBorderDemarcation:
        return 'Physical Estimate';
      case ServiceType.deedWritingService:
        return 'Deed Writing';
      case ServiceType.documentOrganization:
        return 'Document Organization';
      case ServiceType.namjariDcrUpdate:
        return 'Namjari/DCR';
      case ServiceType.inheritanceDisputeAnalysis:
        return 'Inheritance Dispute';
      case ServiceType.governmentAcquisitionRisk:
        return 'Govt. Acquisition';
      case ServiceType.courtCaseVerification:
        return 'Court Case';
    }
  }
}

/// Model for agent task
class AgentTask {
  final String id;
  final String serviceId;
  final ServiceType serviceType;
  final TaskStatus status;
  final TaskAcceptanceStatus acceptanceStatus;
  final TaskProcessingStatus processingStatus;
  final String clientName;
  final String? clientImageUrl;
  final bool isClientVerified;
  final String location;
  final DateTime? acceptBefore;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? postId;
  final String? lastUpdate;
  final DateTime? lastUpdateAt;

  // Property details
  final TaskPropertyType propertyType;
  final double? sellableLandAmount;
  final String? sellableLandUnit;
  final double? plotSize;
  final String? plotSizeUnit;
  final String? distanceFromRoad;
  final List<String> propertyPhotos;
  final List<TaskDocument> rawDocuments;

  // Service fee
  final double serviceFee;

  // Appointment
  final TaskAppointment? appointment;

  // Work log (for active/in-review/done tasks)
  final List<WorkLogEntry> workLog;

  const AgentTask({
    required this.id,
    required this.serviceId,
    required this.serviceType,
    required this.status,
    this.acceptanceStatus = TaskAcceptanceStatus.pendingAccepting,
    this.processingStatus = TaskProcessingStatus.accepted,
    required this.clientName,
    this.clientImageUrl,
    this.isClientVerified = true,
    required this.location,
    this.acceptBefore,
    required this.assignedAt,
    this.completedAt,
    this.postId,
    this.lastUpdate,
    this.lastUpdateAt,
    this.propertyType = TaskPropertyType.flat,
    this.sellableLandAmount,
    this.sellableLandUnit,
    this.plotSize,
    this.plotSizeUnit,
    this.distanceFromRoad,
    this.propertyPhotos = const [],
    this.rawDocuments = const [],
    this.serviceFee = 0.0,
    this.appointment,
    this.workLog = const [],
  });

  /// Create a copy of this task with updated fields
  AgentTask copyWith({
    String? id,
    String? serviceId,
    ServiceType? serviceType,
    TaskStatus? status,
    TaskAcceptanceStatus? acceptanceStatus,
    TaskProcessingStatus? processingStatus,
    String? clientName,
    String? clientImageUrl,
    bool? isClientVerified,
    String? location,
    DateTime? acceptBefore,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? postId,
    String? lastUpdate,
    DateTime? lastUpdateAt,
    TaskPropertyType? propertyType,
    double? sellableLandAmount,
    String? sellableLandUnit,
    double? plotSize,
    String? plotSizeUnit,
    String? distanceFromRoad,
    List<String>? propertyPhotos,
    List<TaskDocument>? rawDocuments,
    double? serviceFee,
    TaskAppointment? appointment,
    List<WorkLogEntry>? workLog,
  }) {
    return AgentTask(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
      processingStatus: processingStatus ?? this.processingStatus,
      clientName: clientName ?? this.clientName,
      clientImageUrl: clientImageUrl ?? this.clientImageUrl,
      isClientVerified: isClientVerified ?? this.isClientVerified,
      location: location ?? this.location,
      acceptBefore: acceptBefore ?? this.acceptBefore,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      postId: postId ?? this.postId,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      propertyType: propertyType ?? this.propertyType,
      sellableLandAmount: sellableLandAmount ?? this.sellableLandAmount,
      sellableLandUnit: sellableLandUnit ?? this.sellableLandUnit,
      plotSize: plotSize ?? this.plotSize,
      plotSizeUnit: plotSizeUnit ?? this.plotSizeUnit,
      distanceFromRoad: distanceFromRoad ?? this.distanceFromRoad,
      propertyPhotos: propertyPhotos ?? this.propertyPhotos,
      rawDocuments: rawDocuments ?? this.rawDocuments,
      serviceFee: serviceFee ?? this.serviceFee,
      appointment: appointment ?? this.appointment,
      workLog: workLog ?? this.workLog,
    );
  }

  /// Get service name
  String get serviceName => serviceType.label;

  /// Get time ago string for assigned time
  String get assignedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(assignedAt);

    if (difference.inMinutes < 60) {
      return 'Assigned: ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Assigned: ${difference.inHours}h ago';
    } else {
      return 'Assigned: ${difference.inDays}d ago';
    }
  }

  /// Format accept before date
  String get acceptBeforeFormatted {
    if (acceptBefore == null) return '';
    final date = acceptBefore!;
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$day $month $year, $hour12:$minute$period';
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  /// Get formatted last update text
  String get lastUpdateFormatted {
    if (lastUpdate == null) return '';
    if (lastUpdateAt == null) return lastUpdate!;

    final now = DateTime.now();
    final difference = now.difference(lastUpdateAt!);

    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours}h ago';
    } else {
      timeAgo = '${difference.inDays}d ago';
    }

    return '$lastUpdate ($timeAgo)';
  }
}

/// Filter options for service type
class ServiceTypeFilter {
  static const String all = 'All';

  static List<String> get options {
    return [all, ...ServiceType.values.map((e) => e.shortLabel)];
  }
}

/// Model for task document
class TaskDocument {
  final String id;
  final String name;
  final String size;
  final String? url;
  final DateTime? uploadedAt;

  const TaskDocument({
    required this.id,
    required this.name,
    required this.size,
    this.url,
    this.uploadedAt,
  });
}

/// Model for task appointment
class TaskAppointment {
  final String id;
  final String type; // Site Visit, Document Collection, etc.
  final DateTime dateTime;
  final AppointmentStatus status;

  const TaskAppointment({
    required this.id,
    required this.type,
    required this.dateTime,
    this.status = AppointmentStatus.upcoming,
  });

  /// Format date as "12 January 2026, 10:00 AM"
  String get formattedDateTime {
    final day = dateTime.day;
    final month = _getMonthName(dateTime.month);
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'AM' : 'PM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$day $month $year, $hour12:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

/// Model for work log entry
class WorkLogEntry {
  final String id;
  final String description;
  final DateTime timestamp;
  final TaskDocument? attachment;
  final WorkLogEntryType type;

  const WorkLogEntry({
    required this.id,
    required this.description,
    required this.timestamp,
    this.attachment,
    this.type = WorkLogEntryType.remark,
  });

  /// Get formatted time (e.g., "Today, 10:00 AM" or "Yesterday, 9:00 AM")
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$hour12:$minute $period';

    if (entryDate == today) {
      return 'Today, $timeStr';
    } else if (entryDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final day = timestamp.day;
      final month = _getMonthShortName(timestamp.month);
      return '$day $month, $timeStr';
    }
  }

  String _getMonthShortName(int month) {
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
    return months[month - 1];
  }
}

/// Work log entry types
enum WorkLogEntryType {
  remark,
  documentUpload,
  appointmentScheduled,
  taskAccepted,
  submitted,
}

extension WorkLogEntryTypeExtension on WorkLogEntryType {
  String get label {
    switch (this) {
      case WorkLogEntryType.remark:
        return 'Remark';
      case WorkLogEntryType.documentUpload:
        return 'Document Upload';
      case WorkLogEntryType.appointmentScheduled:
        return 'Appointment Scheduled';
      case WorkLogEntryType.taskAccepted:
        return 'Task Accepted';
      case WorkLogEntryType.submitted:
        return 'Submitted for Review';
    }
  }
}
