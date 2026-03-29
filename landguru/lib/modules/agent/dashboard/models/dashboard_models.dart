/// Models for Agent Dashboard.

class DashboardLoadPayload {
  const DashboardLoadPayload({
    this.tasksTab = 'NEW',
    this.tasksPage = 1,
    this.tasksLimit = 5,
  });

  final String tasksTab;
  final int tasksPage;
  final int tasksLimit;

  DashboardLoadPayload copyWith({
    String? tasksTab,
    int? tasksPage,
    int? tasksLimit,
  }) {
    return DashboardLoadPayload(
      tasksTab: tasksTab ?? this.tasksTab,
      tasksPage: tasksPage ?? this.tasksPage,
      tasksLimit: tasksLimit ?? this.tasksLimit,
    );
  }

  factory DashboardLoadPayload.fromJson(Map<String, dynamic> json) {
    return DashboardLoadPayload(
      tasksTab: _readString(json, ['tasksTab', 'tab']) ?? 'NEW',
      tasksPage: _readInt(json, ['tasksPage', 'page']) ?? 1,
      tasksLimit: _readInt(json, ['tasksLimit', 'limit']) ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tasksTab': tasksTab,
      'tasksPage': tasksPage,
      'tasksLimit': tasksLimit,
    };
  }

  Map<String, dynamic> toTasksQuery() {
    return <String, dynamic>{
      'tab': tasksTab,
      'page': tasksPage,
      'limit': tasksLimit,
    };
  }
}

class AgentDashboardData {
  const AgentDashboardData({
    required this.assignedLocation,
    required this.stats,
    required this.requiresScheduling,
    required this.todaySchedule,
  });

  final String assignedLocation;
  final DashboardStats stats;
  final List<SchedulingTask> requiresScheduling;
  final List<ScheduleItem> todaySchedule;

  factory AgentDashboardData.empty() {
    return AgentDashboardData(
      assignedLocation: '',
      stats: DashboardStats.empty(),
      requiresScheduling: const <SchedulingTask>[],
      todaySchedule: const <ScheduleItem>[],
    );
  }

  AgentDashboardData copyWith({
    String? assignedLocation,
    DashboardStats? stats,
    List<SchedulingTask>? requiresScheduling,
    List<ScheduleItem>? todaySchedule,
  }) {
    return AgentDashboardData(
      assignedLocation: assignedLocation ?? this.assignedLocation,
      stats: stats ?? this.stats,
      requiresScheduling: requiresScheduling ?? this.requiresScheduling,
      todaySchedule: todaySchedule ?? this.todaySchedule,
    );
  }

  factory AgentDashboardData.fromJson(Map<String, dynamic> json) {
    return AgentDashboardData(
      assignedLocation: _readString(json, ['assignedLocation']) ?? '',
      stats: DashboardStats.fromJson(
        _readMap(json, ['stats']) ?? const <String, dynamic>{},
      ),
      requiresScheduling:
          _readList(json, ['requiresScheduling'])
              ?.whereType<Map>()
              .map(
                (entry) =>
                    SchedulingTask.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList(growable: false) ??
          const <SchedulingTask>[],
      todaySchedule:
          _readList(json, ['todaySchedule'])
              ?.whereType<Map>()
              .map(
                (entry) =>
                    ScheduleItem.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList(growable: false) ??
          const <ScheduleItem>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'assignedLocation': assignedLocation,
      'stats': stats.toJson(),
      'requiresScheduling': requiresScheduling.map((e) => e.toJson()).toList(),
      'todaySchedule': todaySchedule.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model for a task that requires scheduling.
class SchedulingTask {
  const SchedulingTask({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.location,
    required this.acceptBefore,
    required this.assignedAt,
    this.isNewRequest = true,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final String location;
  final DateTime acceptBefore;
  final DateTime assignedAt;
  final bool isNewRequest;

  SchedulingTask copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? location,
    DateTime? acceptBefore,
    DateTime? assignedAt,
    bool? isNewRequest,
  }) {
    return SchedulingTask(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      location: location ?? this.location,
      acceptBefore: acceptBefore ?? this.acceptBefore,
      assignedAt: assignedAt ?? this.assignedAt,
      isNewRequest: isNewRequest ?? this.isNewRequest,
    );
  }

  factory SchedulingTask.fromJson(Map<String, dynamic> json) {
    final assignedAt =
        _readDateTime(json, ['assignedAt', 'createdAt', 'created_at']) ??
        _tryParseRelativeTime(_readString(json, ['assignedAt', 'createdAt'])) ??
        DateTime.now();

    final acceptBefore =
        _readDateTime(json, [
          'acceptBefore',
          'acceptDeadline',
          'accept_before',
        ]) ??
        DateTime.now().add(const Duration(hours: 2));

    return SchedulingTask(
      id: _readString(json, ['id', 'assignmentId', 'assignment_id']) ?? '',
      serviceId: _readString(json, ['serviceId', 'displayId']) ?? '',
      serviceName:
          _readString(json, ['serviceName', 'title']) ??
          _readString(
            _readMap(json, ['service']) ?? const <String, dynamic>{},
            ['name'],
          ) ??
          '',
      location: _readString(json, ['location']) ?? '',
      acceptBefore: acceptBefore,
      assignedAt: assignedAt,
      isNewRequest: _readBool(json, ['isNewRequest']) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'location': location,
      'acceptBefore': acceptBefore.toIso8601String(),
      'assignedAt': assignedAt.toIso8601String(),
      'isNewRequest': isNewRequest,
    };
  }

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

/// Model for a schedule item (today's schedule).
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.serviceId,
    required this.time,
    required this.type,
    required this.clientName,
    required this.location,
    this.itemType = ScheduleItemTypes.clientMeeting,
  });

  final String id;
  final String serviceId;
  final String time; // "10:00 AM"
  final String type; // "Client Meeting", "Site Visit"
  final String clientName;
  final String location;
  final String itemType;

  ScheduleItem copyWith({
    String? id,
    String? serviceId,
    String? time,
    String? type,
    String? clientName,
    String? location,
    String? itemType,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      time: time ?? this.time,
      type: type ?? this.type,
      clientName: clientName ?? this.clientName,
      location: location ?? this.location,
      itemType: itemType ?? this.itemType,
    );
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final title = _readString(json, ['type', 'title']) ?? 'Schedule';
    return ScheduleItem(
      id: _readString(json, ['id', 'assignmentId', 'assignment_id']) ?? '',
      serviceId: _readString(json, ['serviceId']) ?? '',
      time: _readString(json, ['time']) ?? '',
      type: title,
      clientName: _readString(json, ['clientName']) ?? 'Unknown',
      location: _readString(json, ['location']) ?? '',
      itemType: _detectItemType(title),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'serviceId': serviceId,
      'time': time,
      'type': type,
      'clientName': clientName,
      'location': location,
      'itemType': itemType,
    };
  }
}

/// String constants and helpers for schedule item types.
class ScheduleItemTypes {
  static const String clientMeeting = 'client_meeting';
  static const String siteVisit = 'site_visit';
  static const String verification = 'verification';
  static const String other = 'other';

  static String label(String type) {
    switch (type) {
      case clientMeeting:
        return 'Client Meeting';
      case siteVisit:
        return 'Site Visit';
      case verification:
        return 'Verification';
      case other:
      default:
        return 'Other';
    }
  }
}

/// Stats data for dashboard.
class DashboardStats {
  const DashboardStats({
    required this.newRequests,
    required this.activeJobs,
    required this.doneThisMonth,
    required this.currentMonth,
  });

  final int newRequests;
  final int activeJobs;
  final int doneThisMonth;
  final String currentMonth;

  factory DashboardStats.empty() {
    return const DashboardStats(
      newRequests: 0,
      activeJobs: 0,
      doneThisMonth: 0,
      currentMonth: 'Jan',
    );
  }

  DashboardStats copyWith({
    int? newRequests,
    int? activeJobs,
    int? doneThisMonth,
    String? currentMonth,
  }) {
    return DashboardStats(
      newRequests: newRequests ?? this.newRequests,
      activeJobs: activeJobs ?? this.activeJobs,
      doneThisMonth: doneThisMonth ?? this.doneThisMonth,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      newRequests:
          _readInt(json, ['newRequests', 'newRequest', 'pendingRequests']) ?? 0,
      activeJobs: _readInt(json, ['activeJobs', 'inProgress', 'active']) ?? 0,
      doneThisMonth:
          _readInt(json, ['doneThisMonth', 'completedThisMonth', 'done']) ?? 0,
      currentMonth: _readString(json, ['currentMonth', 'month']) ?? 'Jan',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'newRequests': newRequests,
      'activeJobs': activeJobs,
      'doneThisMonth': doneThisMonth,
      'currentMonth': currentMonth,
    };
  }
}

String _detectItemType(String title) {
  final normalized = title.toLowerCase();
  if (normalized.contains('meeting')) {
    return ScheduleItemTypes.clientMeeting;
  }
  if (normalized.contains('visit')) {
    return ScheduleItemTypes.siteVisit;
  }
  if (normalized.contains('verification')) {
    return ScheduleItemTypes.verification;
  }
  return ScheduleItemTypes.other;
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
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

int? _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value != null) {
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

bool? _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
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
  }
  return null;
}

DateTime? _readDateTime(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

DateTime? _tryParseRelativeTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final normalized = value.trim().toLowerCase();
  if (!normalized.endsWith('ago')) {
    return null;
  }

  final numberMatch = RegExp(r'\d+').firstMatch(normalized);
  final amount = int.tryParse(numberMatch?.group(0) ?? '');
  if (amount == null) {
    return null;
  }

  if (normalized.contains('m')) {
    return DateTime.now().subtract(Duration(minutes: amount));
  }
  if (normalized.contains('h')) {
    return DateTime.now().subtract(Duration(hours: amount));
  }
  if (normalized.contains('d')) {
    return DateTime.now().subtract(Duration(days: amount));
  }

  return null;
}

Map<String, dynamic>? _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return null;
}

List<dynamic>? _readList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value;
    }
  }
  return null;
}
