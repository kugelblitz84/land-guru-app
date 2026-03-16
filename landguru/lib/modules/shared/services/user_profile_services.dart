import 'dart:convert';

import 'package:get/get.dart';
import 'package:landguru/core/core.dart';

import '../models/payloads/user_profile_payload_models.dart';
import '../models/user_system_model.dart';

class ProfileServices extends GetxService {
  ProfileServices._(this._apiClient);

  final ApiClient _apiClient;

  factory ProfileServices(ApiClient apiClient) {
    return ProfileServices._(apiClient);
  }

  Future<ProfileModel> fetchUserProfile() async {
    final response = await _apiClient.get('/users/profile/me');
    final map = _extractResponseMap(response.data);
    return ProfileModel.fromJson(map);
  }

  Future<ProfileModel> updateUserProfile({
    required UpdateUserProfilePayload payload,
  }) async {
    final response = await _apiClient.patch(
      '/users/profile/me',
      data: payload.toJson(),
    );
    final map = _extractResponseMap(response.data);
    return ProfileModel.fromJson(map);
  }

  Future<void> changePassword({required ChangePasswordPayload payload}) async {
    await _apiClient.patch(
      '/users/profile/change-password',
      data: payload.toJson(),
    );
  }

  Future<AccountSummaryModel> fetchAccountSummary() async {
    final response = await _apiClient.get('/users/profile/summary');
    final map = _extractResponseMap(response.data);
    return AccountSummaryModel.fromJson(map);
  }

  Map<String, dynamic> _extractResponseMap(dynamic payload) {
    final decoded = _decodeIfString(payload);

    if (decoded is Map<String, dynamic>) {
      final nestedData = decoded['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }

      final user = decoded['user'];
      if (user is Map<String, dynamic>) {
        return user;
      }

      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception('Invalid profile response');
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }
}
