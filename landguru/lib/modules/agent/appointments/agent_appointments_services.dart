import 'dart:convert';

//import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import 'models/appointments_model.dart';

class AgentAppointmentsServices extends GetxService {
  AgentAppointmentsServices._(this._apiClient);

  final ApiClient _apiClient;

  factory AgentAppointmentsServices(ApiClient apiClient) {
    return AgentAppointmentsServices._(apiClient);
  }

  Future<AgentAppointmentsListResponse> fetchAppointments({
    required String tab,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/agents/appointments',
      queryParameters: {'tab': tab, 'page': page, 'limit': limit},
    );

    final map = _extractResponseMap(response.data);
    return AgentAppointmentsListResponse.fromJson(map);
  }

  Future<AgentAppointmentDetails> fetchAppointmentDetails({
    required String assignmentId,
  }) async {
    final response = await _apiClient.get('/agents/appointments/$assignmentId');
    final map = _extractResponseMap(response.data);
    return AgentAppointmentDetails.fromJson(map);
  }

  // Future<dio.Response<dynamic>> _getWithFallback({
  //   required String primaryPath,
  //   required String fallbackPath,
  //   Map<String, dynamic>? queryParameters,
  // }) async {
  //   try {
  //     return await _apiClient.get(
  //       primaryPath,
  //       queryParameters: queryParameters,
  //     );
  //   } on dio.DioException catch (error) {
  //     final statusCode = error.response?.statusCode;
  //     final shouldTryFallback =
  //         statusCode == 404 || statusCode == 405 || statusCode == 501;
  //     if (!shouldTryFallback) {
  //       rethrow;
  //     }

  //     return _apiClient.get(fallbackPath, queryParameters: queryParameters);
  //   }
  // }

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

    throw Exception('Invalid agent appointments response');
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }
}
