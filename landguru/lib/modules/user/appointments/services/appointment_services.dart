import 'package:get/get.dart';
import 'package:landguru/core/services/api_client.dart';
import 'dart:convert';
import '../models/appointment_models.dart';

class AppointmentServices extends GetxService {
  AppointmentServices(this._apiClient);

  final ApiClient _apiClient;

  Future<AppointmentListResponse> fetchUpcomingAppointments({
    required String filter,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/appointments/upcoming',
      queryParameters: {
        'page': page,
        'limit': limit,
        'filter': UpcomingApiFilters.queryValue(filter),
      },
    );

    final payload = _extractResponseMap(response.data);
    return AppointmentListResponse.fromJson(payload);
  }

  Map<String, dynamic> _extractResponseMap(dynamic payload) {
    final decoded = _decodeIfString(payload);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception('Invalid appointments response');
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }

  Future<AppointmentListResponse> fetchUpcomingMyRequests({
    int page = 1,
    int limit = 10,
  }) {
    return fetchUpcomingAppointments(
      filter: UpcomingApiFilters.myRequests,
      page: page,
      limit: limit,
    );
  }

  Future<AppointmentListResponse> fetchUpcomingVisits({
    int page = 1,
    int limit = 10,
  }) {
    return fetchUpcomingAppointments(
      filter: UpcomingApiFilters.upcomingVisits,
      page: page,
      limit: limit,
    );
  }

  Future<AppointmentListResponse> fetchUpcomingAgentVisits({
    int page = 1,
    int limit = 10,
  }) {
    return fetchUpcomingAppointments(
      filter: UpcomingApiFilters.agentVisits,
      page: page,
      limit: limit,
    );
  }

  Future<AppointmentListResponse> fetchPastAppointments({
    required String filter,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/appointments/past',
      queryParameters: {
        'page': page,
        'limit': limit,
        'filter': PastApiFilters.queryValue(filter),
      },
    );

    final payload = _extractResponseMap(response.data);
    return AppointmentListResponse.fromJson(payload);
  }

  Future<AppointmentListResponse> fetchPastMyVisits({
    int page = 1,
    int limit = 10,
  }) {
    return fetchPastAppointments(
      filter: PastApiFilters.myVisits,
      page: page,
      limit: limit,
    );
  }

  Future<AppointmentListResponse> fetchPastAgentVisits({
    int page = 1,
    int limit = 10,
  }) {
    return fetchPastAppointments(
      filter: PastApiFilters.agentVisits,
      page: page,
      limit: limit,
    );
  }
}
