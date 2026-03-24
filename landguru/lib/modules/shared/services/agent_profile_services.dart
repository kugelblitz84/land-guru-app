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

  Future<AgentProfileUpdateResponse> updateAgentProfile({
    required UpdateAgentProfilePayload payload,
  }) async {
    final response = await _apiClient.patch(
      '/agents/profile',
      data: payload.toJson(),
    );
    final map = _extractPayloadMap(response.data);
    return AgentProfileUpdateResponse.fromJson(map);
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

  Map<String, dynamic> _extractPayloadMap(dynamic payload) {
    final decoded = _decodeIfString(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Invalid profile update response');
  }
}

class AgentProfileUpdateResponse {
  const AgentProfileUpdateResponse({
    required this.success,
    required this.message,
    this.agentId,
    this.name,
  });

  final bool success;
  final String message;
  final String? agentId;
  final String? name;

  factory AgentProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    final message = _readText(json['message']);

    return AgentProfileUpdateResponse(
      success: success,
      message:
          message ??
          (success
              ? 'Profile updated successfully'
              : 'Failed to update profile'),
      agentId: _readText(json['agentId']),
      name: _readText(json['name']),
    );
  }

  static String? _readText(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return text;
  }
}
