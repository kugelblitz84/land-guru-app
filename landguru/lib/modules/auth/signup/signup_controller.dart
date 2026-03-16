import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/models.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/utils/constants.dart';
import '../../../routes/app_routes.dart';

/// Service for the Signup flow (5 steps)
/// Step 1: Phone number
/// Step 2: OTP verification
/// Step 3: Set password
/// Step 4: Personal info
/// Step 5: Identity verification
class SignupController extends GetxController {
  SignupController(this._authService, this._uploadService);

  final AuthService _authService;
  final UploadService _uploadService;

  // Total steps
  static const int totalSteps = 5;

  // Current step (1-5)
  final RxInt currentStep = 1.obs;

  // Step 1: Phone
  final phoneFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  // Step 2: OTP
  final otpFormKey = GlobalKey<FormState>();
  final RxList<TextEditingController> otpControllers =
      <TextEditingController>[].obs;
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
  final RxString profileImageLocalPath = ''.obs;
  final RxBool isProfileImageUploading = false.obs;
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

  final ImagePicker _imagePicker = ImagePicker();

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
  final RxList<String> wards = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ].obs;

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
    final result = await ApiErrorHandler.call(
      () => _authService.sendOtp(
        payload: SendOtpPayload(
          phone: phoneController.text.trim(),
          forgetPassword: false,
        ),
      ),
    );
    isLoading.value = false;

    if (!result.isSuccess) {
      profileImageLocalPath.value = '';
      return;
    }

    currentStep.value = 2;
    Get.toNamed(AppRoutes.SIGNUP_VERIFY_OTP);
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp() async {
    if (otpString.length != AppConstants.otpLength) {
      Get.snackbar(
        'Error',
        'Please enter the complete OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final result = await ApiErrorHandler.call(
      () => _authService.verifyOtp(
        payload: VerifyOtpPayload(
          phone: phoneController.text.trim(),
          otp: otpString,
        ),
      ),
    );
    isLoading.value = false;

    if (!result.isSuccess) {
      return;
    }

    currentStep.value = 3;
    Get.toNamed(AppRoutes.SIGNUP_SET_PASSWORD);
  }

  /// Step 2: Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    canResend.value = false;
    resendCountdown.value = 60;

    try {
      final result = await ApiErrorHandler.call(
        () => _authService.sendOtp(
          payload: SendOtpPayload(
            phone: phoneController.text.trim(),
            forgetPassword: false,
          ),
        ),
      );
      if (!result.isSuccess) {
        canResend.value = true;
        return;
      }

      Get.snackbar(
        'Success',
        'OTP sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Start countdown
      _startResendCountdown();
    } catch (_) {
      canResend.value = true;
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
    currentStep.value = 4;
    Get.toNamed(AppRoutes.SIGNUP_PERSONAL_INFO);
    isLoading.value = false;
  }

  /// Step 4: Save personal info and go to identity verification
  Future<void> savePersonalInfo() async {
    if (!personalInfoFormKey.currentState!.validate()) return;

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please set a password first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final result = await ApiErrorHandler.call(
      () => _authService.completeSignup(
        payload: CompleteSignupPayload(
          phone: phoneController.text.trim(),
          password: passwordController.text,
          fullName: nameController.text.trim(),
          email: emailController.text.trim(),
          photoUrl: profileImagePath.value.isEmpty
              ? null
              : profileImagePath.value,
          division: selectedDivision.value,
          district: selectedDistrict.value,
          upazila: selectedUpazilla.value,
          unionOrCityCorp: selectedUnion.value,
          wardNo: selectedWard.value,
          postalCode: postalCodeController.text.trim(),
          fullAddress: fullAddressController.text.trim(),
        ),
      ),
    );
    isLoading.value = false;

    if (!result.isSuccess) {
      return;
    }

    currentStep.value = 5;
    Get.toNamed(AppRoutes.SIGNUP_IDENTITY_VERIFICATION);
  }

  /// Step 5: Complete registration
  Future<void> completeRegistration({bool skipIdentity = false}) async {
    if (!skipIdentity && nidFrontImagePath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload NID front side',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!skipIdentity && nidBackImagePath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload NID back side',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    if (!skipIdentity) {
      final result = await ApiErrorHandler.call(
        () => _authService.completeSignupIdentity(
          payload: CompleteSignupIdentityPayload(
            phone: phoneController.text.trim(),
            nidFrontUrl: nidFrontImagePath.value,
            nidBackUrl: nidBackImagePath.value,
            tinCertificateUrl: tinCertificatePath.value,
          ),
        ),
      );
      if (!result.isSuccess) {
        isLoading.value = false;
        return;
      }
    }

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Registration completed successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate to login screen
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  /// Pick profile image
  Future<void> pickProfileImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) {
      return;
    }

    profileImageLocalPath.value = pickedFile.path;
    isProfileImageUploading.value = true;
    final result = await ApiErrorHandler.call(
      () => _uploadService.uploadFile(
        payload: UploadFilePayload(
          file: File(pickedFile.path),
          contentType: _guessContentType(pickedFile.path),
          type: 'AVATAR',
        ),
      ),
    );
    if (result.isSuccess && result.data != null) {
      profileImagePath.value = result.data!;
    }
    isProfileImageUploading.value = false;
  }

  /// Pick NID front image
  Future<void> pickNidFrontImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    nidFrontImagePath.value = pickedFile.path;
    final result = await ApiErrorHandler.call(
      () => _uploadService.uploadFile(
        payload: UploadFilePayload(
          file: File(pickedFile.path),
          contentType: _guessContentType(pickedFile.path),
          type: 'DEED',
        ),
      ),
    );
    if (result.isSuccess && result.data != null) {
      nidFrontImagePath.value = result.data!;
    } else {
      nidFrontImagePath.value = '';
    }
  }

  /// Pick NID back image
  Future<void> pickNidBackImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    nidBackImagePath.value = pickedFile.path;
    final result = await ApiErrorHandler.call(
      () => _uploadService.uploadFile(
        payload: UploadFilePayload(
          file: File(pickedFile.path),
          contentType: _guessContentType(pickedFile.path),
          type: 'DEED',
        ),
      ),
    );
    if (result.isSuccess && result.data != null) {
      nidBackImagePath.value = result.data!;
    } else {
      nidBackImagePath.value = '';
    }
  }

  /// Pick TIN certificate
  Future<void> pickTinCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    tinCertificatePath.value = path;
    final uploadResult = await ApiErrorHandler.call(
      () => _uploadService.uploadFile(
        payload: UploadFilePayload(
          file: File(path),
          contentType: _guessContentType(path),
          type: 'DEED',
        ),
      ),
    );
    if (uploadResult.isSuccess && uploadResult.data != null) {
      tinCertificatePath.value = uploadResult.data!;
    } else {
      tinCertificatePath.value = '';
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
    profileImageLocalPath.value = '';
    isProfileImageUploading.value = false;
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

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }
}
