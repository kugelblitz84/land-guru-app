import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import 'models/profile_model.dart';
import 'dart:convert';

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

    final response = await _apiClient.patch('/users/profile/me', data: payload);
    final map = _extractResponseMap(response.data);
    return ProfileModel.fromJson(map);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.patch(
      '/users/profile/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
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
