import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for the Forgot Password flow (4 steps for User)
/// Step 1: Phone number
/// Step 2: OTP verification
/// Step 3: Set new password
/// Step 4: Success
class ForgotPasswordController extends GetxController {
  // Total steps
  static const int totalSteps = 4;

  // Current step (1-4)
  final RxInt currentStep = 1.obs;

  // Step 1: Phone
  final phoneFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  // Step 2: OTP
  final RxList<TextEditingController> otpControllers =
      <TextEditingController>[].obs;
  final RxInt resendCountdown = 0.obs;
  final RxBool canResend = true.obs;
  Timer? _resendTimer;

  // Step 3: New Password
  final passwordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize OTP controllers (4 digits)
    for (int i = 0; i < 4; i++) {
      otpControllers.add(TextEditingController());
    }
  }

  /// Get formatted phone number
  String get formattedPhoneNumber => '+880${phoneController.text}';

  /// Get OTP string
  String get otpString => otpControllers.map((c) => c.text).join();

  /// Navigate to next step
  void goToNextStep() {
    if (currentStep.value < totalSteps) {
      final nextRoute = _getRouteForStep(currentStep.value + 1);
      Get.toNamed(nextRoute);
    }
  }

  /// Navigate to previous step
  void goToPreviousStep() {
    Get.back();
  }

  String _getRouteForStep(int step) {
    switch (step) {
      case 1:
        return AppRoutes.FORGOT_PASSWORD_PHONE;
      case 2:
        return AppRoutes.FORGOT_PASSWORD_VERIFY_OTP;
      case 3:
        return AppRoutes.FORGOT_PASSWORD_SET_PASSWORD;
      case 4:
        return AppRoutes.FORGOT_PASSWORD_SUCCESS;
      default:
        return AppRoutes.FORGOT_PASSWORD_PHONE;
    }
  }

  /// Step 1: Send OTP to phone
  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement send OTP API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 2;
      _startResendCountdown();
      Get.toNamed(AppRoutes.FORGOT_PASSWORD_VERIFY_OTP);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp() async {
    if (otpString.length != 4) {
      Get.snackbar(
        'Error',
        'Please enter the complete OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Implement verify OTP API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 3;
      Get.toNamed(AppRoutes.FORGOT_PASSWORD_SET_PASSWORD);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    canResend.value = false;
    resendCountdown.value = 60;

    try {
      // TODO: Implement resend OTP API call
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        'Success',
        'OTP sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Start countdown
      _startResendCountdown();
    } catch (e) {
      canResend.value = true;
      Get.snackbar(
        'Error',
        'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _startResendCountdown() {
    canResend.value = false;
    resendCountdown.value = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// Step 3: Reset password
  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement reset password API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 4;
      Get.offAllNamed(AppRoutes.FORGOT_PASSWORD_SUCCESS);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 4: Go back to login
  void goToLogin() {
    resetForm();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.toggle();
  }

  /// Clear OTP fields
  void clearOtp() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  /// Reset all fields
  void resetForm() {
    currentStep.value = 1;
    phoneController.clear();
    clearOtp();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordObscured.value = true;
    isConfirmPasswordObscured.value = true;
    canResend.value = true;
    resendCountdown.value = 0;
    _resendTimer?.cancel();
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }
}
