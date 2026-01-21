import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    try {
      // TODO: Implement login API call
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay

      // TODO: Get user role from backend and navigate accordingly
      // For now, navigate to user main (for development/testing)
      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
