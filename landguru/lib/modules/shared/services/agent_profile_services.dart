import 'dart:convert';

import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import '../models/payloads/agent_profile_payload_models.dart';
import '../models/agent_system_model.dart';

class AgentProfileServices extends GetxService {
  AgentProfileServices._(this._apiClient);

  final ApiClient _apiClient;

  factory AgentProfileServices(ApiClient apiClient) {
    return AgentProfileServices._(apiClient);
  }

  Future<AgentProfileModel> fetchAgentProfile() async {
    final response = await _apiClient.get('/agents/profile');
    final map = _extractResponseMap(response.data);
    return AgentProfileModel.fromJson(map);
  }

  Future<AgentStats> fetchAgentStats() async {
    final response = await _apiClient.get('/agents/stats');
    final map = _extractResponseMap(response.data);
    final statsMap = _extractStatsMap(map);
    return AgentStats.fromJson(statsMap);
  }

  Future<void> updateAgentProfile({
    required UpdateAgentProfilePayload payload,
  }) async {
    await _apiClient.patch('/agents/profile', data: payload.toJson());
  }

  Future<void> updateProfilePhoto({
    required UpdateAgentProfilePhotoPayload payload,
  }) async {
    await _apiClient.patch('/agents/profile/photo', data: payload.toJson());
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

    throw Exception('Invalid agent profile response');
  }

  Map<String, dynamic> _extractStatsMap(Map<String, dynamic> payload) {
    final stats = payload['stats'];
    if (stats is Map<String, dynamic>) {
      return stats;
    }
    if (stats is Map) {
      return Map<String, dynamic>.from(stats);
    }
    return payload;
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }
}
