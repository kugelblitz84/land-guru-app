import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'token_service.dart';
import 'user_type_service.dart';

class AuthService extends GetxService {
  AuthService(this._prefs, this._tokenService, this._apiClient);

  final SharedPreferences _prefs;
  final TokenService _tokenService;
  final ApiClient _apiClient;

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

  Future<void> sendOtp({required SendOtpPayload payload}) async {
    await _apiClient.post('/auth/send-otp', data: payload.toJson());
  }

  Future<void> verifyOtp({required VerifyOtpPayload payload}) async {
    await _apiClient.post('/auth/verify-otp', data: payload.toJson());
  }

  Future<void> resetPasswordWithOtp({
    required ResetPasswordWithOtpPayload payload,
  }) async {
    final body = payload.toJson();

    final candidatePaths = <String>[
      '/auth/reset-password',
      '/auth/forgot-password/reset',
      '/auth/forgot-password',
    ];

    Object? lastError;
    for (final path in candidatePaths) {
      try {
        await _apiClient.post(path, data: body);
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    throw Exception('Failed to reset password');
  }

  Future<AuthSessionResponse> completeSignup({
    required CompleteSignupPayload payload,
  }) async {
    final response = await _apiClient.post(
      '/auth/complete-signup',
      data: payload.toJson(),
    );

    final authResponse = AuthSessionResponse.fromPayload(response.data);
    final user = authResponse.user;
    if (user != null) {
      _setUser(user);
    }

    return authResponse;
  }

  Future<void> completeSignupIdentity({
    required CompleteSignupIdentityPayload payload,
  }) async {
    await _apiClient.post('/auth/complete-signup1', data: payload.toJson());
  }

  Future<AuthSessionResponse> login({required LoginPayload payload}) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: payload.toJson(),
    );

    final authResponse = AuthSessionResponse.fromPayload(response.data);
    final token = authResponse.accessToken;
    if (token != null && token.isNotEmpty) {
      _setToken(token);
    }

    final user = authResponse.user;
    if (user != null) {
      _setUser(user);
    }

    return authResponse;
  }

  void clearSession() {
    _user.value = null;
    _tokenService.clear();
    _prefs.remove(AppConstants.userDataKey);
    Get.find<UserTypeService>().clear();
  }

  void updateUserFields(Map<String, dynamic> updates) {
    final current = Map<String, dynamic>.from(_user.value ?? {});
    current.addAll(updates);
    _setUser(current);
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
    if (role == UserTypeService.roleAgent) {
      Get.find<UserTypeService>().setUserType(UserTypeService.roleAgent);
    } else if (role == UserTypeService.roleUser) {
      Get.find<UserTypeService>().setUserType(UserTypeService.roleUser);
    }
  }
}
