import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/models.dart';
import '../../../core/services/api_error_handler.dart';
import '../../shared/controllers/agent_profile_store.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../shared/controllers/user_profile_store.dart';
import '../../../core/services/user_type_service.dart';
import '../../../routes/app_routes.dart';

/// Controller for the Login screen
class LoginController extends GetxController {
  LoginController(
    this._authService,
    this._userTypeService,
    this._agentProfileStore,
    this._userProfileStore,
  );

  final AuthService _authService;
  final UserTypeService _userTypeService;
  final AgentProfileStore _agentProfileStore;
  final UserProfileStore _userProfileStore;

  // Form
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordObscured = true.obs;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  /// Handle login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final result = await ApiErrorHandler.call(
      () => _authService.login(
        payload: LoginPayload(
          phone: phoneController.text.trim(),
          password: passwordController.text,
        ),
      ),
    );
    isLoading.value = false;

    if (!result.isSuccess) {
      return;
    }

    await ApiErrorHandler.call(
      () => Get.find<FcmService>().syncTokenWithBackend(force: true),
      showError: false,
    );

    if (_userTypeService.isAgent) {
      _agentProfileStore.hydrateFromSession();
      await _agentProfileStore.refreshProfile(showError: false);
      Get.offAllNamed(AppRoutes.AGENT_MAIN);
    } else {
      _userProfileStore.hydrateFromSession();
      await _userProfileStore.refreshProfile(showError: false);
      Get.offAllNamed(AppRoutes.MAIN);
    }
  }

  /// Navigate to forgot password
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD_PHONE);
  }

  /// Navigate to signup
  void goToSignup() {
    Get.toNamed(AppRoutes.SIGNUP_PHONE);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
