import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:landguru/core/core.dart';
import 'dart:io';

import '../../shared/models/payloads/agent_profile_payload_models.dart';
import '../../shared/services/agent_profile_services.dart';

/// Controller for Agent Edit Profile screen
class AgentEditProfileController extends GetxController {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final postalCodeController = TextEditingController();
  final fullAddressController = TextEditingController();

  // Dropdown values
  final RxString selectedDivision = 'Rajshahi'.obs;
  final RxString selectedDistrict = 'Rajshahi'.obs;
  final RxString selectedUpazilla = 'Bogura'.obs;
  final RxString selectedPouroshova = 'Bogura Pouroshova'.obs;
  final RxString selectedWardNo = '03'.obs;
  final RxString profileImageUrl = ''.obs;

  // Dropdown options
  final List<String> divisions = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  final List<String> districts = [
    'Rajshahi',
    'Bogura',
    'Chapainawabganj',
    'Naogaon',
    'Natore',
    'Nawabganj',
    'Pabna',
    'Sirajganj',
  ];

  final List<String> upazillas = [
    'Bogura',
    'Adamdighi',
    'Dhunat',
    'Gabtali',
    'Kahaloo',
    'Nandigram',
    'Sariakandi',
    'Shajahanpur',
    'Sherpur',
    'Shibganj',
    'Sonatala',
  ];

  final List<String> pouroshovas = [
    'Bogura Pouroshova',
    'Dhunat Pouroshova',
    'Gabtali Pouroshova',
    'Sariakandi Pouroshova',
  ];

  final List<String> wardNumbers = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
  ];

  // Verification documents
  final RxString nidNumber = '89***321'.obs;
  final RxString tinNumber = '44***99'.obs;
  final RxBool isNidVerified = true.obs;
  final RxBool isTinVerified = true.obs;

  // Bank information
  final RxString bankName = 'DBBL'.obs;
  final RxString bankAccountNo = '123456789123'.obs;
  final RxString swiftCode = 'DBBLBDDH'.obs;
  final RxString routingNo = '123456789123'.obs;

  // State
  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  final _profileServices = Get.find<AgentProfileServices>();
  final _profileStore = Get.find<AgentProfileStore>();
  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _profileStore.hydrateFromSession();
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    postalCodeController.dispose();
    fullAddressController.dispose();
    super.onClose();
  }

  /// Load profile data
  Future<void> loadProfile() async {
    if (isLoading.value) {
      return;
    }

    _populateFromStore();
    isLoading.value = true;
    try {
      await _profileStore.refreshProfile(forceRefresh: true);
      _populateFromStore();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) {
      return;
    }

    isImageUploading.value = true;
    try {
      final uploadService = Get.find<UploadService>();
      final uploadResponse = await ApiErrorHandler.call(
        () => uploadService.uploadFile(
          payload: UploadFilePayload(
            file: File(pickedFile.path),
            contentType: _guessContentType(pickedFile.path),
            type: 'AVATAR',
          ),
        ),
      );

      if (!uploadResponse.isSuccess || uploadResponse.data == null) {
        Get.snackbar(
          'Error',
          uploadResponse.error ?? 'Failed to upload image',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final photoUrl = uploadResponse.data!;
      final photoUpdateResponse = await ApiErrorHandler.call(
        () => _profileServices.updateProfilePhoto(
          payload: UpdateAgentProfilePhotoPayload(photoUrl: photoUrl),
        ),
      );

      if (!photoUpdateResponse.isSuccess) {
        Get.snackbar(
          'Error',
          photoUpdateResponse.error ?? 'Failed to update profile photo',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      profileImageUrl.value = photoUrl;

      await _profileStore.refreshProfile(forceRefresh: true, showError: false);
      _populateFromStore();

      Get.snackbar(
        'Success',
        'Profile photo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (isImageUploading.value) {
      Get.snackbar(
        'Please wait',
        'Profile image upload is still in progress.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    try {
      final updateResponse = await ApiErrorHandler.call(
        () => _profileServices.updateAgentProfile(
          payload: UpdateAgentProfilePayload(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            division: selectedDivision.value,
            district: selectedDistrict.value,
            upazila: selectedUpazilla.value,
            unionOrCityCorp: selectedPouroshova.value,
            wardNo: selectedWardNo.value,
            postalCode: postalCodeController.text.trim(),
            fullAddress: fullAddressController.text.trim(),
            photoUrl: profileImageUrl.value.trim(),
          ),
        ),
      );

      if (!updateResponse.isSuccess) {
        Get.snackbar(
          'Error',
          updateResponse.error ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final updatePayload = updateResponse.data;
      if (updatePayload == null) {
        Get.snackbar(
          'Error',
          'Invalid profile update response',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!updatePayload.success) {
        Get.snackbar(
          'Error',
          updatePayload.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _profileStore.refreshProfile(forceRefresh: true, showError: false);
      _populateFromStore();

      final successMessage = updatePayload.message;
      Get.back();
      Get.snackbar(
        'Success',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _ensureValueInOptions(String value, List<String> options) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return options.first;
    }

    final existing = options.firstWhereOrNull(
      (option) => option.toLowerCase() == normalized.toLowerCase(),
    );
    if (existing != null) {
      return existing;
    }

    options.insert(0, normalized);
    return normalized;
  }

  void _populateFromStore() {
    final profile = _profileStore.profileModel.value;
    fullNameController.text = profile.agentName;
    phoneController.text = profile.phone;
    emailController.text = profile.email;
    postalCodeController.text = profile.postalCode;
    fullAddressController.text = profile.fullAddress;

    selectedDivision.value = _ensureValueInOptions(profile.division, divisions);
    selectedDistrict.value = _ensureValueInOptions(profile.district, districts);
    selectedUpazilla.value = _ensureValueInOptions(profile.upazilla, upazillas);
    selectedPouroshova.value = _ensureValueInOptions(
      profile.pouroshova,
      pouroshovas,
    );
    selectedWardNo.value = _ensureValueInOptions(profile.wardNo, wardNumbers);

    nidNumber.value = profile.nidNumber;
    tinNumber.value = profile.tinNumber;
    isNidVerified.value = profile.isNidVerified;
    isTinVerified.value = profile.isTinVerified;

    bankName.value = profile.bankName;
    bankAccountNo.value = profile.bankAccountNo;
    swiftCode.value = profile.swiftCode;
    routingNo.value = profile.routingNo;
    profileImageUrl.value = profile.profileImage;
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
