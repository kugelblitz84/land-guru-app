import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_type_service.dart';
import '../../../routes/app_routes.dart';

/// Controller for the Login screen
class LoginController extends GetxController {
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
    final authService = Get.find<AuthService>();
    final userTypeService = Get.find<UserTypeService>();

    final result = await ApiErrorHandler.call(
      () => authService.login(
        phone: phoneController.text.trim(),
        password: passwordController.text,
      ),
    );
    isLoading.value = false;

    if (!result.isSuccess) {
      return;
    }

    if (userTypeService.isAgent) {
      Get.offAllNamed(AppRoutes.AGENT_MAIN);
    } else {
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
