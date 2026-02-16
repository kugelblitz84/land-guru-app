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
      total: _readInt(json, ['total']) ?? 0,
      page: _readInt(json, ['page']) ?? 1,
      limit: _readInt(json, ['limit']) ?? 10,
      totalPages: _readInt(json, ['totalPages']) ?? 1,
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
    final appointment = _readMap(json, ['appointment']);
    final post = _readMap(json, ['post', 'property']);
    final service = _readMap(json, ['service']);

    return AgentAppointmentApiModel(
      id:
          _readString(appointment, ['id', 'appointmentId']) ??
          _readString(json, ['id', 'assignmentId', 'appointmentId']) ??
          '',
      postId:
          _readString(post, ['id', 'postId']) ??
          _readString(json, ['postId', 'post_id', 'taskId']) ??
          '',
      propertyTitle:
          _readString(post, ['title', 'propertyTitle']) ??
          _readString(json, ['propertyTitle', 'title', 'postTitle']) ??
          'Untitled Property',
      propertyType:
          _readString(post, ['propertyType', 'type']) ??
          _readString(json, ['propertyType', 'type', 'postType']) ??
          'flat',
      location:
          _readString(appointment, ['location', 'address']) ??
          _readString(post, ['location', 'address', 'fullAddress']) ??
          _readString(json, [
            'location',
            'address',
            'fullAddress',
            'assignedLocation',
          ]) ??
          '',
      status:
          _readString(appointment, ['status', 'appointmentStatus']) ??
          _readString(json, ['status', 'appointmentStatus']) ??
          '',
      appointmentDate:
          _readDateTime(json, [
            'appointmentDateTime',
            'appointmentDate',
            'date',
            'scheduleDate',
            'scheduledAt',
            'appointmentAt',
            'visitDate',
            'createdAt',
          ]) ??
          _readDateTime(appointment, [
            'appointmentDateTime',
            'appointmentDate',
            'date',
            'scheduleDate',
            'scheduledAt',
            'appointmentAt',
            'visitDate',
          ]),
      serviceType:
          _readString(service, ['serviceName', 'name', 'serviceType']) ??
          _readString(json, ['serviceType', 'serviceName', 'service']) ??
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
    final dataMap = rootData is Map<String, dynamic>
        ? rootData
        : (rootData is Map ? Map<String, dynamic>.from(rootData) : null);

    final list =
        (rootData is List ? rootData : null) ??
        json['items'] ??
        json['rows'] ??
        json['appointments'] ??
        json['assignments'] ??
        json['tasks'] ??
        dataMap?['items'] ??
        dataMap?['rows'] ??
        dataMap?['appointments'] ??
        dataMap?['assignments'] ??
        dataMap?['tasks'];

    final rawItems = list is List ? list : <dynamic>[];
    final items = rawItems
        .whereType<Map>()
        .map(
          (entry) => AgentAppointmentApiModel.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();

    final rawMeta = json['meta'] ?? dataMap?['meta'] ?? json['pagination'];
    final metaMap = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : <String, dynamic>{};

    if (metaMap.isEmpty) {
      metaMap.addAll(
        {
          'total':
              _readInt(json, ['total']) ?? _readInt(dataMap ?? {}, ['total']),
          'page': _readInt(json, ['page']) ?? _readInt(dataMap ?? {}, ['page']),
          'limit':
              _readInt(json, ['limit']) ?? _readInt(dataMap ?? {}, ['limit']),
          'totalPages':
              _readInt(json, ['totalPages']) ??
              _readInt(dataMap ?? {}, ['totalPages']),
        }..removeWhere((key, value) => value == null),
      );
    }

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
    final appointment = _readMap(json, ['appointment']);
    final post = _readMap(json, ['post', 'property']);
    final service = _readMap(json, ['service']);

    return AgentAppointmentDetails(
      id:
          _readString(appointment, ['id', 'appointmentId']) ??
          _readString(json, ['id', 'assignmentId', 'appointmentId']) ??
          '',
      postId:
          _readString(post, ['id', 'postId']) ??
          _readString(json, ['postId', 'post_id', 'taskId']) ??
          '',
      propertyTitle:
          _readString(post, ['title', 'propertyTitle']) ??
          _readString(json, ['propertyTitle', 'title', 'postTitle']) ??
          'Untitled Property',
      serviceType:
          _readString(service, ['serviceName', 'name', 'serviceType']) ??
          _readString(json, ['serviceType', 'serviceName', 'service']) ??
          'N/A',
      location:
          _readString(appointment, ['location', 'address']) ??
          _readString(post, ['location', 'address', 'fullAddress']) ??
          _readString(json, [
            'location',
            'address',
            'fullAddress',
            'assignedLocation',
          ]) ??
          '',
      status:
          _readString(appointment, ['status', 'appointmentStatus']) ??
          _readString(json, ['status', 'appointmentStatus']) ??
          '',
      appointmentDate:
          _readDateTime(json, [
            'appointmentDateTime',
            'appointmentDate',
            'date',
            'scheduleDate',
            'scheduledAt',
            'appointmentAt',
            'visitDate',
          ]) ??
          _readDateTime(appointment, [
            'appointmentDateTime',
            'appointmentDate',
            'date',
            'scheduleDate',
            'scheduledAt',
            'appointmentAt',
            'visitDate',
          ]),
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return const <String, dynamic>{};
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }
  return null;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
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
  }
  return null;
}

DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}
