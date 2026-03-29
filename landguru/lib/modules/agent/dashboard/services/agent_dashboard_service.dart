import 'dart:convert';

import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import '../models/dashboard_models.dart';

class AgentDashboardService extends GetxService {
  AgentDashboardService._(this._apiClient);

  final ApiClient _apiClient;

  factory AgentDashboardService(ApiClient apiClient) {
    return AgentDashboardService._(apiClient);
  }

  Future<AgentDashboardData> fetchDashboardData({
    required DashboardLoadPayload payload,
  }) async {
    final results = await Future.wait<dynamic>([
      fetchAssignedLocation(),
      fetchDashboardStats(),
      fetchRequiresScheduling(payload: payload),
      fetchTodaySchedule(),
    ]);

    return AgentDashboardData(
      assignedLocation: results[0] as String,
      stats: results[1] as DashboardStats,
      requiresScheduling: results[2] as List<SchedulingTask>,
      todaySchedule: results[3] as List<ScheduleItem>,
    );
  }

  Future<String> fetchAssignedLocation() async {
    final response = await _apiClient.get('/agents/assigned-location');
    final root = _extractRootMap(response.data);
    final dataMap = _extractMap(root['data']);

    return _readString(dataMap, ['assignedLocation', 'location']) ?? '';
  }

  Future<DashboardStats> fetchDashboardStats() async {
    final response = await _apiClient.get('/agents/stats');
    final root = _extractRootMap(response.data);

    final dataMap = _extractMap(root['data']);
    final statsMap = _extractMap(dataMap['stats']);

    final parsed = DashboardStats.fromJson(
      statsMap.isNotEmpty ? statsMap : dataMap,
    );

    final fallbackMonth = parsed.currentMonth.trim().isEmpty
        ? _monthLabel(DateTime.now())
        : parsed.currentMonth;

    return parsed.copyWith(currentMonth: fallbackMonth);
  }

  Future<List<SchedulingTask>> fetchRequiresScheduling({
    required DashboardLoadPayload payload,
  }) async {
    final response = await _apiClient.get(
      '/agents/agent-task',
      queryParameters: payload.toTasksQuery(),
    );

    final root = _extractRootMap(response.data);
    final list = _extractList(root, [
      'data',
      'tasks',
      'items',
      'list',
      'assignments',
    ]);

    return list
        .whereType<Map>()
        .map((item) => SchedulingTask.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<ScheduleItem>> fetchTodaySchedule() async {
    final response = await _apiClient.get('/agents/dashboard/today-schedule');
    final root = _extractRootMap(response.data);

    final list = _extractList(root, ['data', 'schedule', 'items']);

    return list
        .whereType<Map>()
        .map((item) => ScheduleItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> _extractRootMap(dynamic payload) {
    final decoded = _decodeIfString(payload);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{};
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(Map<String, dynamic> root, List<String> keys) {
    for (final key in keys) {
      final value = root[key];
      if (value is List) {
        return value;
      }
      if (value is Map) {
        final nested = _extractMap(value);
        final nestedData = nested['data'];
        if (nestedData is List) {
          return nestedData;
        }
      }
    }

    final data = root['data'];
    if (data is List) {
      return data;
    }

    return const <dynamic>[];
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

  String _monthLabel(DateTime dateTime) {
    const months = <String>[
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
    return months[dateTime.month - 1];
  }
}
