import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for Edit Profile screen
class EditProfileController extends GetxService {
  // Form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxString profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentProfile();
  }

  /// Load current profile data
  void loadCurrentProfile() {
    // TODO: Populate controllers with current data
  }

  /// Pick new profile image
  Future<void> pickImage() async {
    // TODO: Implement image picker
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Implement save profile API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Navigate back
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
