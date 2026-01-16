import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for the Forgot Password flow (4 steps for User)
/// Step 1: Phone number
/// Step 2: OTP verification
/// Step 3: Set new password
/// Step 4: Success
class ForgotPasswordController extends GetxService {
  // Current step (1-4)
  final RxInt currentStep = 1.obs;

  // Step 1: Phone
  final phoneFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  // Step 2: OTP
  final otpFormKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final RxInt resendCountdown = 0.obs;

  // Step 3: New Password
  final passwordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  /// Move to next step
  void nextStep() {
    if (currentStep.value < 4) {
      currentStep.value++;
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  /// Step 1: Send OTP to phone
  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement send OTP API call
      await Future.delayed(const Duration(seconds: 1));
      nextStep();
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement verify OTP API call
      await Future.delayed(const Duration(seconds: 1));
      nextStep();
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Resend OTP
  Future<void> resendOtp() async {
    // TODO: Implement resend OTP
  }

  /// Step 3: Reset password
  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement reset password API call
      await Future.delayed(const Duration(seconds: 1));
      nextStep(); // Go to success step
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 4: Go back to login
  void goToLogin() {
    // TODO: Navigate back to login
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.toggle();
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
