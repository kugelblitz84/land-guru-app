import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

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
  final RxString profileImage = ''.obs;

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
    loadCurrentProfile();
  }

  /// Load current profile data
  void loadCurrentProfile() {
    // Get data from ProfileController if available
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      fullNameController.text = profileController.userName.value;
      phoneController.text = profileController.userPhone.value;
      emailController.text = profileController.userEmail.value;
      postalCodeController.text = profileController.postalCode.value;
      fullAddressController.text = profileController.fullAddress.value;
      profileImage.value = profileController.profileImage.value;

      selectedDivision.value = profileController.division.value;
      selectedDistrict.value = profileController.district.value;
      selectedUpazilla.value = profileController.upazilla.value;
      selectedPouroshova.value = profileController.pouroshova.value;
      selectedWardNo.value = profileController.wardNo.value;

      nidNumber.value = profileController.nidNumber.value;
      isNidVerified.value = profileController.isNidVerified.value;
      tinNumber.value = profileController.tinNumber.value;
      isTinVerified.value = profileController.isTinVerified.value;
    }
  }

  /// Pick new profile image
  Future<void> pickImage() async {
    // TODO: Implement image picker
    Get.snackbar(
      'Info',
      'Image picker not implemented yet',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update ProfileController if available
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.userName.value = fullNameController.text;
        profileController.userEmail.value = emailController.text;
        profileController.postalCode.value = postalCodeController.text;
        profileController.fullAddress.value = fullAddressController.text;
        profileController.division.value = selectedDivision.value;
        profileController.district.value = selectedDistrict.value;
        profileController.upazilla.value = selectedUpazilla.value;
        profileController.pouroshova.value = selectedPouroshova.value;
        profileController.wardNo.value = selectedWardNo.value;
      }

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
