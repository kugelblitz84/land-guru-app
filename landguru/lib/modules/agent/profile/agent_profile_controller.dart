import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for Agent Profile screen
class AgentProfileController extends GetxController {
  // State
  final RxBool isLoading = false.obs;

  // Agent data
  final RxString agentName = 'Sahil'.obs;
  final RxString agentTitle = 'Adv.'.obs;
  final RxString agentId = 'LAW-2026-0001'.obs;
  final RxString agentType = 'Lawyer'.obs;
  final RxBool isVerified = true.obs;
  final RxString profileImage = ''.obs;
  final RxString email = 'sahil.advocate@email.com'.obs;
  final RxString phone = '+880 1712-345678'.obs;

  // Stats
  final RxInt totalTasksCompleted = 156.obs;
  final RxDouble totalEarned = 245000.0.obs;

  // Assigned location
  final RxString assignedLocation =
      'Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.'
          .obs;

  // Services provided
  final RxList<String> servicesProvided = <String>[
    'Document Verification',
    'Ownership History Check',
    'Pentagraph Map Verification',
    'Legal Consultation',
  ].obs;

  /// Get display name with title
  String get displayName {
    if (agentTitle.value.isNotEmpty) {
      return '${agentTitle.value} ${agentName.value}';
    }
    return agentName.value;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Load agent profile
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // TODO: Load profile from API
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock data is already set above
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to edit profile
  void goToEditProfile() {
    Get.toNamed(AppRoutes.AGENT_PROFILE_EDIT);
  }

  /// Navigate to change password
  void goToChangePassword() {
    Get.toNamed(AppRoutes.AGENT_PROFILE_CHANGE_PASSWORD);
  }

  /// Navigate to view full profile
  void goToProfileDetails() {
    // TODO: Navigate to detailed profile view
  }

  /// Logout with confirmation dialog
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }

  /// Perform actual logout
  Future<void> _performLogout() async {
    isLoading.value = true;
    try {
      // TODO: Clear local storage/tokens
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to login and clear navigation stack
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile
  Future<void> refresh() async {
    await loadProfile();
  }
}
