import 'dart:convert';

import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import 'models/profile_model.dart';

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
    required String fullName,
    required String email,
    required String division,
    required String district,
    required String upazila,
    required String unionOrCityCorp,
    required String wardNo,
    required String postalCode,
    required String fullAddress,
    String? photoUrl,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      if (division.isNotEmpty) 'division': division,
      if (district.isNotEmpty) 'district': district,
      if (upazila.isNotEmpty) 'upazila': upazila,
      if (unionOrCityCorp.isNotEmpty) 'unionOrCityCorp': unionOrCityCorp,
      if (wardNo.isNotEmpty) 'wardNo': wardNo,
      if (postalCode.isNotEmpty) 'postalCode': postalCode,
      if (fullAddress.isNotEmpty) 'fullAddress': fullAddress,
    };

    await _apiClient.patch('/agents/profile', data: payload);
  }

  Future<void> updateProfilePhoto({required String photoUrl}) async {
    await _apiClient.patch(
      '/agents/profile/photo',
      data: {'photoUrl': photoUrl},
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
