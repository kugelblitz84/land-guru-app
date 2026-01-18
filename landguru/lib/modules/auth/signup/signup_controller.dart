import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Service for the Signup flow (5 steps)
/// Step 1: Phone number
/// Step 2: OTP verification
/// Step 3: Set password
/// Step 4: Personal info
/// Step 5: Identity verification
class SignupController extends GetxController {
  // Total steps
  static const int totalSteps = 5;

  // Current step (1-5)
  final RxInt currentStep = 1.obs;

  // Step 1: Phone
  final phoneFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  // Step 2: OTP
  final otpFormKey = GlobalKey<FormState>();
  final RxList<TextEditingController> otpControllers = <TextEditingController>[].obs;
  final RxInt resendCountdown = 0.obs;
  final RxBool canResend = true.obs;

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
  final postalCodeController = TextEditingController();
  final fullAddressController = TextEditingController();
  final RxString profileImagePath = ''.obs;
  final RxString selectedDivision = ''.obs;
  final RxString selectedDistrict = ''.obs;
  final RxString selectedUpazilla = ''.obs;
  final RxString selectedUnion = ''.obs;
  final RxString selectedWard = ''.obs;
  final RxBool isFullAddressCustomized = false.obs;

  // Step 5: Identity Verification
  final RxString nidFrontImagePath = ''.obs;
  final RxString nidBackImagePath = ''.obs;
  final RxString tinCertificatePath = ''.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Dropdown options (will be populated from API)
  final RxList<String> divisions = <String>[
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ].obs;
  final RxList<String> districts = <String>[].obs;
  final RxList<String> upazillas = <String>[].obs;
  final RxList<String> unions = <String>[].obs;
  final RxList<String> wards = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize OTP controllers
    for (int i = 0; i < 4; i++) {
      otpControllers.add(TextEditingController());
    }
    // Listen to postal code changes to update full address
    postalCodeController.addListener(_onPostalCodeChanged);
  }

  void _onPostalCodeChanged() {
    _updateFullAddressIfNotCustomized();
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
        return AppRoutes.SIGNUP_PHONE;
      case 2:
        return AppRoutes.SIGNUP_VERIFY_OTP;
      case 3:
        return AppRoutes.SIGNUP_SET_PASSWORD;
      case 4:
        return AppRoutes.SIGNUP_PERSONAL_INFO;
      case 5:
        return AppRoutes.SIGNUP_IDENTITY_VERIFICATION;
      default:
        return AppRoutes.SIGNUP_PHONE;
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
      Get.toNamed(AppRoutes.SIGNUP_VERIFY_OTP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp() async {
    if (otpString.length != 4) {
      Get.snackbar('Error', 'Please enter the complete OTP',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Implement verify OTP API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 3;
      Get.toNamed(AppRoutes.SIGNUP_SET_PASSWORD);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('Success', 'OTP sent successfully',
          snackPosition: SnackPosition.BOTTOM);

      // Start countdown
      _startResendCountdown();
    } catch (e) {
      canResend.value = true;
      Get.snackbar('Error', 'Failed to resend OTP',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _startResendCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  /// Step 3: Set password
  Future<void> setPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement set password API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 4;
      Get.toNamed(AppRoutes.SIGNUP_PERSONAL_INFO);
    } catch (e) {
      Get.snackbar('Error', 'Failed to set password. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 4: Save personal info and go to identity verification
  Future<void> savePersonalInfo() async {
    if (!personalInfoFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement save personal info API call
      await Future.delayed(const Duration(seconds: 1));
      currentStep.value = 5;
      Get.toNamed(AppRoutes.SIGNUP_IDENTITY_VERIFICATION);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save info. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 5: Complete registration
  Future<void> completeRegistration({bool skipIdentity = false}) async {
    if (!skipIdentity && nidFrontImagePath.value.isEmpty) {
      Get.snackbar('Error', 'Please upload NID front side',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!skipIdentity && nidBackImagePath.value.isEmpty) {
      Get.snackbar('Error', 'Please upload NID back side',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Implement complete registration API call
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar('Success', 'Registration completed successfully!',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to main screen
      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      Get.snackbar('Error', 'Registration failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick profile image
  Future<void> pickProfileImage() async {
    // TODO: Implement image picker
    // For now, just simulate
    profileImagePath.value = 'selected_profile_image.jpg';
  }

  /// Pick NID front image
  Future<void> pickNidFrontImage() async {
    // TODO: Implement image picker
    nidFrontImagePath.value = 'nid_front.jpg';
  }

  /// Pick NID back image
  Future<void> pickNidBackImage() async {
    // TODO: Implement image picker
    nidBackImagePath.value = 'nid_back.jpg';
  }

  /// Pick TIN certificate
  Future<void> pickTinCertificate() async {
    // TODO: Implement file picker
    tinCertificatePath.value = 'tin_certificate.pdf';
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.toggle();
  }

  /// Generate full address from location components
  String _generateFullAddress() {
    final parts = <String>[];
    if (selectedWard.value.isNotEmpty) {
      parts.add('Ward No. ${selectedWard.value}');
    }
    if (selectedUnion.value.isNotEmpty) {
      parts.add(selectedUnion.value);
    }
    if (selectedUpazilla.value.isNotEmpty) {
      parts.add(selectedUpazilla.value);
    }
    if (selectedDistrict.value.isNotEmpty) {
      parts.add(selectedDistrict.value);
    }
    if (postalCodeController.text.isNotEmpty) {
      parts.add(postalCodeController.text);
    }
    if (selectedDivision.value.isNotEmpty) {
      parts.add(selectedDivision.value);
    }
    return parts.join(', ');
  }

  /// Update full address field if not customized by user
  void _updateFullAddressIfNotCustomized() {
    if (!isFullAddressCustomized.value) {
      fullAddressController.text = _generateFullAddress();
    }
  }

  /// Mark full address as customized when user edits it
  void markFullAddressAsCustomized() {
    isFullAddressCustomized.value = true;
  }

  /// Update division and load districts
  void updateDivision(String? division) {
    if (division == null) return;
    selectedDivision.value = division;
    selectedDistrict.value = '';
    selectedUpazilla.value = '';
    selectedUnion.value = '';
    selectedWard.value = '';
    // TODO: Load districts from API based on division
    districts.value = ['District 1', 'District 2', 'District 3'];
    _updateFullAddressIfNotCustomized();
  }

  /// Update district and load upazillas
  void updateDistrict(String? district) {
    if (district == null) return;
    selectedDistrict.value = district;
    selectedUpazilla.value = '';
    selectedUnion.value = '';
    selectedWard.value = '';
    // TODO: Load upazillas from API based on district
    upazillas.value = ['Upazilla 1', 'Upazilla 2', 'Upazilla 3'];
    _updateFullAddressIfNotCustomized();
  }

  /// Update upazilla and load unions
  void updateUpazilla(String? upazilla) {
    if (upazilla == null) return;
    selectedUpazilla.value = upazilla;
    selectedUnion.value = '';
    selectedWard.value = '';
    // TODO: Load unions from API based on upazilla
    unions.value = ['Union 1', 'Union 2', 'Union 3', 'City Corp'];
    _updateFullAddressIfNotCustomized();
  }

  /// Update union
  void updateUnion(String? union) {
    if (union == null) return;
    selectedUnion.value = union;
    selectedWard.value = '';
    _updateFullAddressIfNotCustomized();
  }

  /// Update ward
  void updateWard(String? ward) {
    if (ward == null) return;
    selectedWard.value = ward;
    _updateFullAddressIfNotCustomized();
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
    nameController.clear();
    emailController.clear();
    postalCodeController.clear();
    fullAddressController.clear();
    profileImagePath.value = '';
    selectedDivision.value = '';
    selectedDistrict.value = '';
    selectedUpazilla.value = '';
    selectedUnion.value = '';
    selectedWard.value = '';
    isFullAddressCustomized.value = false;
    nidFrontImagePath.value = '';
    nidBackImagePath.value = '';
    tinCertificatePath.value = '';
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    postalCodeController.removeListener(_onPostalCodeChanged);
    postalCodeController.dispose();
    fullAddressController.dispose();
    super.onClose();
  }
}
