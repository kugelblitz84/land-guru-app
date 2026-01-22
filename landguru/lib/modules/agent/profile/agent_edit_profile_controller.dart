import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void onInit() {
    super.onInit();
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
  void loadProfile() {
    // Mock data - replace with API call
    fullNameController.text = 'User Name';
    phoneController.text = '+8801700000000';
    emailController.text = 'usename@email.com';
    postalCodeController.text = '5800';
    fullAddressController.text =
        'Holding #45, Ward #03, Bogura Pourashava, Bogura Sadar, Bogura-5800, Rajshahi';
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    // TODO: Implement image picker
    Get.snackbar(
      'Coming Soon',
      'Image picker will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSaving.value = true;
    try {
      // TODO: API call to save profile
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
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
}
