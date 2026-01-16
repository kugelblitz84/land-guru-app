import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for the Signup flow (4 steps)
/// Step 1: Phone number
/// Step 2: OTP verification
/// Step 3: Set password
/// Step 4: Personal info & identity
class SignupController extends GetxService {
  // Current step (1-4)
  final RxInt currentStep = 1.obs;

  // Step 1: Phone
  final phoneFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  // Step 2: OTP
  final otpFormKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final RxInt resendCountdown = 0.obs;

  // Step 3: Password
  final passwordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  // Step 4: Personal Info
  final personalInfoFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

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

  /// Step 3: Set password
  Future<void> setPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement set password API call
      await Future.delayed(const Duration(seconds: 1));
      nextStep();
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 4: Complete registration
  Future<void> completeRegistration() async {
    if (!personalInfoFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement complete registration API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Navigate to home
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
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
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
