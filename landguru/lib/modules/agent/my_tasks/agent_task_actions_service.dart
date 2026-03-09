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
        _readList(root, ['data', 'workLog', 'workLogs', 'logs']) ??
        _readList(root, ['items', 'list']);

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
    final client = _readMap(json, ['client', 'customer', 'user']);
    final property = _readMap(json, ['property', 'post', 'sellPost']);
    final appointmentMap = _readMap(json, ['appointment', 'meeting']);

    return AgentTask(
      id:
          _readString(json, [
            'id',
            'assignmentId',
            'assignment_id',
            'taskId',
          ]) ??
          '',
      serviceId:
          _readString(json, ['serviceId', 'service_id', 'postId', 'post_id']) ??
          '#${_readString(json, ['id', 'assignmentId']) ?? ''}',
      serviceType: _parseServiceType(
        _readString(json, ['serviceType', 'serviceName']) ??
            _readString(_readMap(json, ['service']), ['name', 'serviceName']) ??
            '',
      ),
      status: _parseTaskStatus(_readString(json, ['status', 'tab']) ?? ''),
      acceptanceStatus: _parseAcceptanceStatus(
        _readString(json, ['acceptanceStatus', 'acceptStatus']) ?? '',
      ),
      processingStatus: _parseProcessingStatus(
        _readString(json, ['processingStatus', 'workflowStatus']) ?? '',
      ),
      clientName:
          _readString(client, ['name', 'fullName']) ??
          _readString(json, ['clientName', 'customerName']) ??
          'Unknown',
      clientImageUrl:
          _readString(client, ['photoUrl', 'avatar', 'profileImage']) ??
          _readString(json, ['clientImageUrl']),
      isClientVerified:
          _readBool(client, ['isVerified']) ??
          _readBool(json, ['isClientVerified']) ??
          true,
      location:
          _readString(json, ['location', 'address']) ??
          _readString(property, ['location', 'address']) ??
          '',
      acceptBefore: _readDateTime(json, ['acceptBefore', 'accept_before']),
      assignedAt:
          _readDateTime(json, ['assignedAt', 'assigned_at', 'createdAt']) ??
          DateTime.now(),
      completedAt: _readDateTime(json, ['completedAt', 'completed_at']),
      postId: _readString(json, ['postId', 'post_id']),
      lastUpdate: _readString(json, ['lastUpdate', 'latestUpdate']),
      lastUpdateAt: _readDateTime(json, ['lastUpdateAt', 'latestUpdateAt']),
      propertyType: _parsePropertyType(
        _readString(property, ['propertyType', 'type']) ??
            _readString(json, ['propertyType']) ??
            '',
      ),
      sellableLandAmount: _readDouble(property, [
        'sellableLandAmount',
        'sellableLand',
        'landAmount',
      ]),
      sellableLandUnit:
          _readString(property, ['sellableLandUnit', 'landUnit']) ??
          _readString(json, ['sellableLandUnit']),
      plotSize:
          _readDouble(property, ['plotSize', 'plot_size']) ??
          _readDouble(json, ['plotSize']),
      plotSizeUnit:
          _readString(property, ['plotSizeUnit', 'plotUnit']) ??
          _readString(json, ['plotSizeUnit']),
      distanceFromRoad:
          _readString(property, ['distanceFromRoad']) ??
          _readString(json, ['distanceFromRoad']),
      propertyPhotos: _readStringList(property, [
        'propertyPhotos',
        'photos',
        'images',
        'photoUrls',
      ]),
      rawDocuments: _parseDocuments(
        _readList(property, ['rawDocuments', 'documents', 'files']) ??
            _readList(json, ['rawDocuments', 'documents', 'files']) ??
            const <dynamic>[],
      ),
      serviceFee:
          _readDouble(json, ['serviceFee', 'fee', 'service_fee']) ?? 0.0,
      appointment: appointmentMap == null
          ? null
          : _parseAppointment(appointmentMap),
      workLog: _parseWorkLogsFromMap(json),
    );
  }

  List<WorkLogEntry> _parseWorkLogsFromMap(Map<String, dynamic> json) {
    return _parseWorkLogs(
      _readList(json, ['workLog', 'workLogs', 'logs']) ?? const <dynamic>[],
    );
  }

  TaskAppointment _parseAppointment(Map<String, dynamic> json) {
    return TaskAppointment(
      id:
          _readString(json, ['id', 'appointmentId', 'appointment_id']) ??
          'apt_unknown',
      type:
          _readString(json, ['type', 'title', 'appointmentType']) ??
          'Site Visit',
      dateTime:
          _readDateTime(json, ['dateTime', 'datetime', 'scheduledAt']) ??
          _buildDateTimeFromDateAndTime(json) ??
          DateTime.now(),
      status: _parseAppointmentStatus(_readString(json, ['status']) ?? ''),
    );
  }

  List<WorkLogEntry> _parseWorkLogs(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          final fileUrls = _readStringList(map, [
            'fileUrls',
            'files',
            'attachments',
          ]);

          TaskDocument? attachment;
          if (fileUrls.isNotEmpty) {
            final fileUrl = fileUrls.first;
            attachment = TaskDocument(
              id: _readString(map, ['id']) ?? fileUrl,
              name: _fileNameFromUrl(fileUrl),
              size: _readString(map, ['fileSize', 'size']) ?? '-',
              url: fileUrl,
              uploadedAt:
                  _readDateTime(map, ['createdAt', 'uploadedAt']) ??
                  DateTime.now(),
            );
          }

          return WorkLogEntry(
            id: _readString(map, ['id', 'logId']) ?? 'wl_unknown',
            description:
                _readString(map, ['remark', 'description', 'message']) ?? '',
            timestamp:
                _readDateTime(map, ['createdAt', 'timestamp']) ??
                DateTime.now(),
            attachment: attachment,
            type: _parseWorkLogType(_readString(map, ['type', 'action']) ?? ''),
          );
        })
        .toList(growable: false);
  }

  List<TaskDocument> _parseDocuments(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          final url = _readString(map, ['url', 'fileUrl']);
          return TaskDocument(
            id: _readString(map, ['id', 'fileId']) ?? (url ?? 'doc_unknown'),
            name:
                _readString(map, ['name', 'fileName']) ??
                (url != null ? _fileNameFromUrl(url) : 'Document'),
            size: _readString(map, ['size', 'fileSize']) ?? '-',
            url: url,
            uploadedAt: _readDateTime(map, ['uploadedAt', 'createdAt']),
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
    final dateText = _readString(json, ['date']);
    final timeText = _readString(json, ['time']);
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

  Map<String, dynamic>? _readMap(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

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

  List<dynamic>? _readList(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    for (final key in keys) {
      final value = map[key];
      if (value is List) {
        return value;
      }
    }

    return null;
  }

  String? _readString(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  double? _readDouble(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    for (final key in keys) {
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
    }

    return null;
  }

  bool? _readBool(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    for (final key in keys) {
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
    }

    return null;
  }

  DateTime? _readDateTime(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    for (final key in keys) {
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
    }

    return null;
  }

  List<String> _readStringList(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return const <String>[];

    for (final key in keys) {
      final value = map[key];
      if (value is List) {
        return value
            .map((entry) {
              if (entry is String) {
                return entry;
              }
              if (entry is Map) {
                final entryMap = Map<String, dynamic>.from(entry);
                return _readString(entryMap, ['url', 'fileUrl', 'photoUrl']) ??
                    '';
              }
              return '';
            })
            .where((entry) => entry.trim().isNotEmpty)
            .toList(growable: false);
      }
    }

    return const <String>[];
  }
}
