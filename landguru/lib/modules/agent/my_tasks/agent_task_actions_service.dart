import 'dart:convert';

import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import 'models/task_models.dart';

class AgentTaskActionsService extends GetxService {
  AgentTaskActionsService._(this._apiClient);

  final ApiClient _apiClient;

  factory AgentTaskActionsService(ApiClient apiClient) {
    return AgentTaskActionsService._(apiClient);
  }

  Future<AgentTasksListResponse> fetchTasks({
    required String tab,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/agents/agent-task',
      queryParameters: {'tab': tab, 'page': page, 'limit': limit},
    );

    final root = _extractResponseMap(response.data);
    final listPayload =
        root['data'] ??
        root['tasks'] ??
        root['items'] ??
        root['list'] ??
        root['assignments'];

    if (listPayload is! List) {
      return AgentTasksListResponse(
        tasks: const <AgentTask>[],
        total: 0,
        page: page,
        limit: limit,
      );
    }

    final tasks = listPayload
        .whereType<Map>()
        .map((entry) => _mapTask(Map<String, dynamic>.from(entry)))
        .toList(growable: false);

    final rawMeta = root['meta'] is Map ? root['meta'] as Map : null;
    final totalRaw = rawMeta?['total'] ?? root['total'];
    final total = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? tasks.length;

    final pageRaw = rawMeta?['page'] ?? root['page'];
    final currentPage = pageRaw is num
        ? pageRaw.toInt()
        : int.tryParse(pageRaw?.toString() ?? '') ?? page;

    final limitRaw = rawMeta?['limit'] ?? root['limit'];
    final currentLimit = limitRaw is num
        ? limitRaw.toInt()
        : int.tryParse(limitRaw?.toString() ?? '') ?? limit;

    return AgentTasksListResponse(
      tasks: tasks,
      total: total,
      page: currentPage,
      limit: currentLimit,
    );
  }

  Future<AgentTask> fetchTaskDetails({required String assignmentId}) async {
    final response = await _apiClient.get('/agents/agent-task/$assignmentId');
    final root = _extractResponseMap(response.data);

    final detailPayload =
        root['data'] ?? root['task'] ?? root['assignment'] ?? root;

    if (detailPayload is! Map) {
      throw Exception('Invalid task details response');
    }

    return _mapTask(Map<String, dynamic>.from(detailPayload));
  }

  Future<void> acceptTask({required String assignmentId}) async {
    await _apiClient.patch('/agents/agent-task/$assignmentId/accept');
  }

  Future<void> submitReview({
    required String assignmentId,
    int rating = 5,
    String comment = '',
  }) async {
    final payload = <String, dynamic>{'rating': rating};
    if (comment.trim().isNotEmpty) {
      payload['comment'] = comment.trim();
    }

    await _apiClient.post(
      '/agents/agent-task/$assignmentId/submit-review',
      data: payload,
    );
  }

  Future<void> addWorkLog({
    required String assignmentId,
    String? remark,
    List<String> fileUrls = const <String>[],
  }) async {
    final payload = <String, dynamic>{
      if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      if (fileUrls.isNotEmpty) 'fileUrls': fileUrls,
    };

    await _apiClient.post(
      '/agents/agent-task/$assignmentId/work-log',
      data: payload,
    );
  }

  Future<List<WorkLogEntry>> fetchWorkLog({
    required String assignmentId,
  }) async {
    final response = await _apiClient.get(
      '/agents/agent-task/$assignmentId/work-log',
    );
    final root = _extractResponseMap(response.data);

    final listPayload =
      _readListAny(root, 'data', 'workLog', 'workLogs', 'logs') ??
      _readListAny(root, 'items', 'list');

    if (listPayload == null) {
      return const <WorkLogEntry>[];
    }

    return _parseWorkLogs(listPayload);
  }

  Future<void> createAppointment({
    required String assignmentId,
    required String date,
    required String time,
    required String location,
  }) async {
    await _apiClient.post(
      '/agents/agent-task/$assignmentId/appointment',
      data: {'date': date, 'time': time, 'location': location},
    );
  }

  Future<void> rescheduleAppointment({
    required String assignmentId,
    required String newDate,
    required String newTime,
    required String reason,
  }) async {
    await _apiClient.post(
      '/agents/agent-task/$assignmentId/appointment/reschedule',
      data: {'newDate': newDate, 'newTime': newTime, 'reason': reason},
    );
  }

  Map<String, dynamic> _extractResponseMap(dynamic payload) {
    final decoded = _decodeIfString(payload);

    if (decoded is Map<String, dynamic>) {
      final nestedData = decoded['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
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

  AgentTask _mapTask(Map<String, dynamic> json) {
    final client = _readMapAny(json, 'client', 'customer', 'user');
    final property = _readMapAny(json, 'property', 'post', 'sellPost');
    final appointmentMap = _readMapAny(json, 'appointment', 'meeting');

    return AgentTask(
      id:
          _readStringAny(json, 'id', 'assignmentId', 'assignment_id', 'taskId') ??
          '',
      serviceId:
          _readStringAny(json, 'serviceId', 'service_id', 'postId', 'post_id') ??
          '#${_readStringAny(json, 'id', 'assignmentId') ?? ''}',
      serviceType: _parseServiceType(
        _readStringAny(json, 'serviceType', 'serviceName') ??
            _readStringAny(_readMapAny(json, 'service'), 'name', 'serviceName') ??
            '',
      ),
      status: _parseTaskStatus(_readStringAny(json, 'status', 'tab') ?? ''),
      acceptanceStatus: _parseAcceptanceStatus(
        _readStringAny(json, 'acceptanceStatus', 'acceptStatus') ?? '',
      ),
      processingStatus: _parseProcessingStatus(
        _readStringAny(json, 'processingStatus', 'workflowStatus') ?? '',
      ),
      clientName:
          _readStringAny(client, 'name', 'fullName') ??
          _readStringAny(json, 'clientName', 'customerName') ??
          'Unknown',
      clientImageUrl:
          _readStringAny(client, 'photoUrl', 'avatar', 'profileImage') ??
          _readStringAny(json, 'clientImageUrl'),
      isClientVerified:
          _readBoolAny(client, 'isVerified') ??
          _readBoolAny(json, 'isClientVerified') ??
          true,
      location:
          _readStringAny(json, 'location', 'address') ??
          _readStringAny(property, 'location', 'address') ??
          '',
      acceptBefore: _readDateTimeAny(json, 'acceptBefore', 'accept_before'),
      assignedAt:
          _readDateTimeAny(json, 'assignedAt', 'assigned_at', 'createdAt') ??
          DateTime.now(),
      completedAt: _readDateTimeAny(json, 'completedAt', 'completed_at'),
      postId: _readStringAny(json, 'postId', 'post_id'),
      lastUpdate: _readStringAny(json, 'lastUpdate', 'latestUpdate'),
      lastUpdateAt: _readDateTimeAny(json, 'lastUpdateAt', 'latestUpdateAt'),
      propertyType: _parsePropertyType(
        _readStringAny(property, 'propertyType', 'type') ??
            _readStringAny(json, 'propertyType') ??
            '',
      ),
      sellableLandAmount: _readDoubleAny(property,
        'sellableLandAmount',
        'sellableLand',
        'landAmount',
      ),
      sellableLandUnit:
          _readStringAny(property, 'sellableLandUnit', 'landUnit') ??
          _readStringAny(json, 'sellableLandUnit'),
      plotSize:
          _readDoubleAny(property, 'plotSize', 'plot_size') ??
          _readDoubleAny(json, 'plotSize'),
      plotSizeUnit:
          _readStringAny(property, 'plotSizeUnit', 'plotUnit') ??
          _readStringAny(json, 'plotSizeUnit'),
      distanceFromRoad:
          _readStringAny(property, 'distanceFromRoad') ??
          _readStringAny(json, 'distanceFromRoad'),
      propertyPhotos: _readStringListAny(property,
        'propertyPhotos',
        'photos',
        'images',
        'photoUrls',
      ),
      rawDocuments: _parseDocuments(
        _readListAny(property, 'rawDocuments', 'documents', 'files') ??
            _readListAny(json, 'rawDocuments', 'documents', 'files') ??
            const <dynamic>[],
      ),
      serviceFee:
          _readDoubleAny(json, 'serviceFee', 'fee', 'service_fee') ?? 0.0,
      appointment: appointmentMap == null
          ? null
          : _parseAppointment(appointmentMap),
      workLog: _parseWorkLogsFromMap(json),
    );
  }

  List<WorkLogEntry> _parseWorkLogsFromMap(Map<String, dynamic> json) {
    return _parseWorkLogs(
      _readListAny(json, 'workLog', 'workLogs', 'logs') ?? const <dynamic>[],
    );
  }

  TaskAppointment _parseAppointment(Map<String, dynamic> json) {
    return TaskAppointment(
      id:
          _readStringAny(json, 'id', 'appointmentId', 'appointment_id') ??
          'apt_unknown',
      type:
          _readStringAny(json, 'type', 'title', 'appointmentType') ??
          'Site Visit',
      dateTime:
          _readDateTimeAny(json, 'dateTime', 'datetime', 'scheduledAt') ??
          _buildDateTimeFromDateAndTime(json) ??
          DateTime.now(),
        status: _parseAppointmentStatus(_readStringAny(json, 'status') ?? ''),
    );
  }

  List<WorkLogEntry> _parseWorkLogs(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          final fileUrls = _readStringListAny(map,
            'fileUrls',
            'files',
            'attachments',
          );

          TaskDocument? attachment;
          if (fileUrls.isNotEmpty) {
            final fileUrl = fileUrls.first;
            attachment = TaskDocument(
              id: _readStringAny(map, 'id') ?? fileUrl,
              name: _fileNameFromUrl(fileUrl),
              size: _readStringAny(map, 'fileSize', 'size') ?? '-',
              url: fileUrl,
              uploadedAt:
                  _readDateTimeAny(map, 'createdAt', 'uploadedAt') ??
                  DateTime.now(),
            );
          }

          return WorkLogEntry(
            id: _readStringAny(map, 'id', 'logId') ?? 'wl_unknown',
            description:
                _readStringAny(map, 'remark', 'description', 'message') ?? '',
            timestamp:
                _readDateTimeAny(map, 'createdAt', 'timestamp') ??
                DateTime.now(),
            attachment: attachment,
            type: _parseWorkLogType(_readStringAny(map, 'type', 'action') ?? ''),
          );
        })
        .toList(growable: false);
  }

  List<TaskDocument> _parseDocuments(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          final url = _readStringAny(map, 'url', 'fileUrl');
          return TaskDocument(
            id: _readStringAny(map, 'id', 'fileId') ?? (url ?? 'doc_unknown'),
            name:
                _readStringAny(map, 'name', 'fileName') ??
                (url != null ? _fileNameFromUrl(url) : 'Document'),
            size: _readStringAny(map, 'size', 'fileSize') ?? '-',
            url: url,
            uploadedAt: _readDateTimeAny(map, 'uploadedAt', 'createdAt'),
          );
        })
        .toList(growable: false);
  }

  String _fileNameFromUrl(String url) {
    final clean = url.trim();
    if (clean.isEmpty) return 'Document';
    final uri = Uri.tryParse(clean);
    final path = uri?.path ?? clean;
    if (path.isEmpty || !path.contains('/')) return clean;
    return path.split('/').last;
  }

  DateTime? _buildDateTimeFromDateAndTime(Map<String, dynamic> json) {
    final dateText = _readStringAny(json, 'date');
    final timeText = _readStringAny(json, 'time');
    if (dateText == null || timeText == null) {
      return null;
    }

    final candidate = '$dateText $timeText';
    return DateTime.tryParse(candidate.replaceFirst(' ', 'T'));
  }

  TaskStatus _parseTaskStatus(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('review')) return TaskStatus.inReview;
    if (normalized.contains('done') || normalized.contains('complete')) {
      return TaskStatus.done;
    }
    if (normalized.contains('active') || normalized.contains('progress')) {
      return TaskStatus.active;
    }
    return TaskStatus.newRequest;
  }

  TaskAcceptanceStatus _parseAcceptanceStatus(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('reject')) return TaskAcceptanceStatus.rejected;
    if (normalized.contains('accept')) return TaskAcceptanceStatus.accepted;
    return TaskAcceptanceStatus.pendingAccepting;
  }

  TaskProcessingStatus _parseProcessingStatus(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('review')) return TaskProcessingStatus.inReview;
    if (normalized.contains('done') || normalized.contains('complete')) {
      return TaskProcessingStatus.done;
    }
    if (normalized.contains('process') || normalized.contains('active')) {
      return TaskProcessingStatus.processing;
    }
    return TaskProcessingStatus.accepted;
  }

  AppointmentStatus _parseAppointmentStatus(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('visit')) return AppointmentStatus.visited;
    if (normalized.contains('cancel')) return AppointmentStatus.cancelled;
    if (normalized.contains('upcoming') || normalized.contains('scheduled')) {
      return AppointmentStatus.upcoming;
    }
    return AppointmentStatus.notScheduled;
  }

  WorkLogEntryType _parseWorkLogType(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('submit')) return WorkLogEntryType.submitted;
    if (normalized.contains('accept')) return WorkLogEntryType.taskAccepted;
    if (normalized.contains('appoint')) {
      return WorkLogEntryType.appointmentScheduled;
    }
    if (normalized.contains('document') || normalized.contains('upload')) {
      return WorkLogEntryType.documentUpload;
    }
    return WorkLogEntryType.remark;
  }

  ServiceType _parseServiceType(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('ownership')) {
      return ServiceType.ownershipHistoryValidation;
    }
    if (normalized.contains('pentagraph') || normalized.contains('map')) {
      return ServiceType.pentagraphMapVerification;
    }
    if (normalized.contains('border') || normalized.contains('demarcation')) {
      return ServiceType.physicalEstimateBorderDemarcation;
    }
    if (normalized.contains('deed')) return ServiceType.deedWritingService;
    if (normalized.contains('organization')) {
      return ServiceType.documentOrganization;
    }
    if (normalized.contains('namjari') || normalized.contains('dcr')) {
      return ServiceType.namjariDcrUpdate;
    }
    if (normalized.contains('inheritance')) {
      return ServiceType.inheritanceDisputeAnalysis;
    }
    if (normalized.contains('acquisition')) {
      return ServiceType.governmentAcquisitionRisk;
    }
    if (normalized.contains('court')) return ServiceType.courtCaseVerification;
    return ServiceType.ownershipHistoryValidation;
  }

  TaskPropertyType _parsePropertyType(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('land')) return TaskPropertyType.land;
    if (normalized.contains('plot')) return TaskPropertyType.plot;
    if (normalized.contains('building')) return TaskPropertyType.building;
    return TaskPropertyType.flat;
  }

  Map<String, dynamic>? _readMap(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  List<dynamic>? _readList(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is List) {
      return value;
    }

    return null;
  }

  String? _readString(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  double? _readDouble(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  bool? _readBool(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    if (value is num) {
      if (value == 1) return true;
      if (value == 0) return false;
    }

    return null;
  }

  DateTime? _readDateTime(Map<String, dynamic>? map, String key) {
    if (map == null) return null;

    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    if (value is int) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(value);
      return dateTime;
    }

    return null;
  }

  List<String> _readStringList(Map<String, dynamic>? map, String key) {
    if (map == null) return const <String>[];

    final value = map[key];
    if (value is! List) {
      return const <String>[];
    }

    return value
        .map((entry) {
          if (entry is String) {
            return entry;
          }
          if (entry is Map) {
            final entryMap = Map<String, dynamic>.from(entry);
            return _readStringAny(entryMap, 'url', 'fileUrl', 'photoUrl') ?? '';
          }
          return '';
        })
        .where((entry) => entry.trim().isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic>? _readMapAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readMap(map, key1) ??
        (key2 == null ? null : _readMap(map, key2)) ??
        (key3 == null ? null : _readMap(map, key3)) ??
        (key4 == null ? null : _readMap(map, key4));
  }

  List<dynamic>? _readListAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readList(map, key1) ??
        (key2 == null ? null : _readList(map, key2)) ??
        (key3 == null ? null : _readList(map, key3)) ??
        (key4 == null ? null : _readList(map, key4));
  }

  String? _readStringAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readString(map, key1) ??
        (key2 == null ? null : _readString(map, key2)) ??
        (key3 == null ? null : _readString(map, key3)) ??
        (key4 == null ? null : _readString(map, key4));
  }

  double? _readDoubleAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readDouble(map, key1) ??
        (key2 == null ? null : _readDouble(map, key2)) ??
        (key3 == null ? null : _readDouble(map, key3)) ??
        (key4 == null ? null : _readDouble(map, key4));
  }

  bool? _readBoolAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readBool(map, key1) ??
        (key2 == null ? null : _readBool(map, key2)) ??
        (key3 == null ? null : _readBool(map, key3)) ??
        (key4 == null ? null : _readBool(map, key4));
  }

  DateTime? _readDateTimeAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    return _readDateTime(map, key1) ??
        (key2 == null ? null : _readDateTime(map, key2)) ??
        (key3 == null ? null : _readDateTime(map, key3)) ??
        (key4 == null ? null : _readDateTime(map, key4));
  }

  List<String> _readStringListAny(
    Map<String, dynamic>? map,
    String key1, [
    String? key2,
    String? key3,
    String? key4,
  ]) {
    final first = _readStringList(map, key1);
    if (first.isNotEmpty) return first;
    if (key2 != null) {
      final second = _readStringList(map, key2);
      if (second.isNotEmpty) return second;
    }
    if (key3 != null) {
      final third = _readStringList(map, key3);
      if (third.isNotEmpty) return third;
    }
    if (key4 != null) {
      final fourth = _readStringList(map, key4);
      if (fourth.isNotEmpty) return fourth;
    }
    return const <String>[];
  }
}
