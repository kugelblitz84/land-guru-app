import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_services.dart';

/// Controller for Edit Profile screen
class EditProfileController extends GetxController {
  // Form
  final formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final postalCodeController = TextEditingController();
  final fullAddressController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isImageUploading = false.obs;
  final RxString profileImage = ''.obs;
  final _profileServices = Get.find<ProfileServices>();
  final _profileStore = Get.find<UserProfileStore>();
  final _imagePicker = ImagePicker();

  // Dropdown values
  final RxString selectedDivision = 'Rajshahi'.obs;
  final RxString selectedDistrict = 'Rajshahi'.obs;
  final RxString selectedUpazilla = 'Bogura'.obs;
  final RxString selectedPouroshova = 'Bogura Pouroshova'.obs;
  final RxString selectedWardNo = '03'.obs;

  // Dropdown options
  final List<String> divisions = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  final List<String> districts = [
    'Dhaka',
    'Gazipur',
    'Narayanganj',
    'Rajshahi',
    'Bogura',
    'Chittagong',
    'Comilla',
  ];

  final List<String> upazillas = [
    'Bogura Sadar',
    'Bogura',
    'Sherpur',
    'Shibganj',
    'Dhunat',
    'Gabtali',
  ];

  final List<String> pouroshovas = [
    'Bogura Pouroshova',
    'Sherpur Pouroshova',
    'Shibganj Pouroshova',
    'Dhunat Pouroshova',
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
  final RxString nidNumber = '88***321'.obs;
  final RxBool isNidVerified = true.obs;
  final RxString tinNumber = '44***99'.obs;
  final RxBool isTinVerified = true.obs;

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    loadCurrentProfile();
    _profileStore.refreshProfile(showError: false).then((_) {
      loadCurrentProfile();
    });
  }

  /// Load current profile data
  void loadCurrentProfile() {
    fullNameController.text = _profileStore.userName.value;
    phoneController.text = _profileStore.userPhone.value;
    emailController.text = _profileStore.userEmail.value;
    postalCodeController.text = _profileStore.postalCode.value;
    fullAddressController.text = _profileStore.fullAddress.value;
    profileImage.value = _profileStore.profileImage.value;

    selectedDivision.value = _ensureOption(
      divisions,
      _profileStore.division.value,
    );
    selectedDistrict.value = _ensureOption(
      districts,
      _profileStore.district.value,
    );
    selectedUpazilla.value = _ensureOption(
      upazillas,
      _profileStore.upazilla.value,
    );
    selectedPouroshova.value = _ensureOption(
      pouroshovas,
      _profileStore.pouroshova.value,
    );
    selectedWardNo.value = _ensureOption(
      wardNumbers,
      _profileStore.wardNo.value,
    );

    nidNumber.value = _profileStore.nidNumber.value;
    isNidVerified.value = _profileStore.isNidVerified.value;
    tinNumber.value = _profileStore.tinNumber.value;
    isTinVerified.value = _profileStore.isTinVerified.value;
  }

  /// Pick new profile image
  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) {
      return;
    }

    isImageUploading.value = true;
    final uploadService = Get.find<UploadService>();
    final result = await ApiErrorHandler.call(
      () => uploadService.uploadFile(
        file: File(pickedFile.path),
        contentType: _guessContentType(pickedFile.path),
        type: 'AVATAR',
      ),
    );

    if (result.isSuccess && result.data != null) {
      profileImage.value = result.data!;
    }

    isImageUploading.value = false;
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
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
      final result = await ApiErrorHandler.call(
        () => _profileServices.updateUserProfile(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          division: selectedDivision.value.trim(),
          district: selectedDistrict.value.trim(),
          upazila: selectedUpazilla.value.trim(),
          unionOrCityCorp: selectedPouroshova.value.trim(),
          wardNo: selectedWardNo.value.trim(),
          postalCode: postalCodeController.text.trim(),
          fullAddress: fullAddressController.text.trim(),
          photoUrl: profileImage.value.trim(),
        ),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      await _profileStore.refreshProfile(forceRefresh: true, showError: false);

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(200),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _ensureOption(List<String> options, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return options.isNotEmpty ? options.first : '';
    }

    if (!options.contains(normalized)) {
      options.add(normalized);
    }

    return normalized;
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

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    postalCodeController.dispose();
    fullAddressController.dispose();
    super.onClose();
  }
}
