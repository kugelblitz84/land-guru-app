/// Models for Agent Dashboard

/// Model for a task that requires scheduling
class SchedulingTask {
  final String id;
  final String serviceId;
  final String serviceName;
  final String location;
  final DateTime acceptBefore;
  final DateTime assignedAt;
  final bool isNewRequest;

  SchedulingTask({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.location,
    required this.acceptBefore,
    required this.assignedAt,
    this.isNewRequest = true,
  });

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
    final day = acceptBefore.day;
    final month = _getMonthName(acceptBefore.month);
    final year = acceptBefore.year;
    final hour = acceptBefore.hour;
    final minute = acceptBefore.minute.toString().padLeft(2, '0');
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
}

/// Model for a schedule item (today's schedule)
class ScheduleItem {
  final String id;
  final String serviceId;
  final String time; // "10:00 AM"
  final String type; // "Client Meeting", "Site Visit"
  final String clientName;
  final String location;
  final ScheduleItemType itemType;

  ScheduleItem({
    required this.id,
    required this.serviceId,
    required this.time,
    required this.type,
    required this.clientName,
    required this.location,
    this.itemType = ScheduleItemType.clientMeeting,
  });
}

/// Types of schedule items
enum ScheduleItemType {
  clientMeeting,
  siteVisit,
  verification,
  other;

  String get label {
    switch (this) {
      case ScheduleItemType.clientMeeting:
        return 'Client Meeting';
      case ScheduleItemType.siteVisit:
        return 'Site Visit';
      case ScheduleItemType.verification:
        return 'Verification';
      case ScheduleItemType.other:
        return 'Other';
    }
  }
}

/// Stats data for dashboard
class DashboardStats {
  final int newRequests;
  final int activeJobs;
  final int doneThisMonth;
  final String currentMonth;

  DashboardStats({
    required this.newRequests,
    required this.activeJobs,
    required this.doneThisMonth,
    required this.currentMonth,
  });
}
