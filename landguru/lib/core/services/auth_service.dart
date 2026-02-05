import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/user_type.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'token_service.dart';
import 'user_type_service.dart';

class AuthService extends GetxService {
  AuthService(this._prefs, this._tokenService);

  final SharedPreferences _prefs;
  final TokenService _tokenService;

  final Rxn<Map<String, dynamic>> _user = Rxn<Map<String, dynamic>>();

  String? get token => _tokenService.token;
  Map<String, dynamic>? get user => _user.value;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> loadFromStorage() async {
    await _tokenService.loadFromStorage();

    final userJson = _prefs.getString(AppConstants.userDataKey);
    if (userJson != null && userJson.isNotEmpty) {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        _user.value = decoded;
      }
    }

    _syncUserType();
  }

  Future<void> sendOtp({
    required String phone,
    bool forgetPassword = false,
  }) async {
    final apiClient = Get.find<ApiClient>();
    await apiClient.post(
      '/auth/send-otp',
      data: {'phone': phone, 'forgetPassword': forgetPassword},
    );
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final apiClient = Get.find<ApiClient>();
    await apiClient.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
  }

  Future<Map<String, dynamic>?> completeSignup({
    required String phone,
    required String password,
    required String fullName,
    required String email,
    String? photoUrl,
    String? division,
    String? district,
    String? upazila,
    String? unionOrCityCorp,
    String? wardNo,
    String? postalCode,
    String? fullAddress,
  }) async {
    final apiClient = Get.find<ApiClient>();
    final response = await apiClient.post(
      '/auth/complete-signup',
      data: {
        'phone': phone,
        'password': password,
        'role': 'user',
        'fullName': fullName,
        'email': email,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (division != null && division.isNotEmpty) 'division': division,
        if (district != null && district.isNotEmpty) 'district': district,
        if (upazila != null && upazila.isNotEmpty) 'upazila': upazila,
        if (unionOrCityCorp != null && unionOrCityCorp.isNotEmpty)
          'unionOrCityCorp': unionOrCityCorp,
        if (wardNo != null && wardNo.isNotEmpty) 'wardNo': wardNo,
        if (postalCode != null && postalCode.isNotEmpty)
          'postalCode': postalCode,
        if (fullAddress != null && fullAddress.isNotEmpty)
          'fullAddress': fullAddress,
      },
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        _setUser(user);
      }
      return data;
    }

    return null;
  }

  Future<void> completeSignupIdentity({
    required String phone,
    required String nidFrontUrl,
    required String nidBackUrl,
    String? tinCertificateUrl,
  }) async {
    final apiClient = Get.find<ApiClient>();
    await apiClient.post(
      '/auth/complete-signup1',
      data: {
        'phone': phone,
        'nidFrontUrl': nidFrontUrl,
        'nidBackUrl': nidBackUrl,
        if (tinCertificateUrl != null && tinCertificateUrl.isNotEmpty)
          'tinCertificateUrl': tinCertificateUrl,
      },
    );
  }

  Future<void> login({required String phone, required String password}) async {
    final apiClient = Get.find<ApiClient>();
    final response = await apiClient.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken']?.toString();
      final user = data['user'];
      if (token != null && token.isNotEmpty) {
        _setToken(token);
      }
      if (user is Map<String, dynamic>) {
        _setUser(user);
      }
    }
  }

  void clearSession() {
    _user.value = null;
    _tokenService.clear();
    _prefs.remove(AppConstants.userDataKey);
    Get.find<UserTypeService>().clear();
  }

  void _setToken(String token) {
    _tokenService.setToken(token);
  }

  void _setUser(Map<String, dynamic> user) {
    _user.value = user;
    _prefs.setString(AppConstants.userDataKey, jsonEncode(user));
    _syncUserType();
  }

  void _syncUserType() {
    final role = _user.value?['role']?.toString().toLowerCase();
    if (role == 'agent') {
      Get.find<UserTypeService>().setUserType(UserType.agent);
    } else if (role == 'user') {
      Get.find<UserTypeService>().setUserType(UserType.user);
    }
  }
}
