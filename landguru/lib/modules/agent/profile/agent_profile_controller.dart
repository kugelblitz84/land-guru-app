import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/agent_bottom_nav_controller.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import '../../shared/shell/agent_shell_controller.dart';
import '../../shared/shell/main_shell_controller.dart';

/// Controller for Agent Profile screen
class AgentProfileController extends GetxController {
  final _profileStore = Get.find<AgentProfileStore>();

  RxBool get isLoading => _profileStore.isLoading;

  // Agent data
  RxString get agentName => _profileStore.agentName;
  RxString get agentTitle => _profileStore.agentTitle;
  RxString get agentId => _profileStore.agentId;
  RxString get agentType => _profileStore.agentType;
  RxBool get isVerified => _profileStore.isVerified;
  RxString get profileImage => _profileStore.profileImage;
  RxString get email => _profileStore.email;
  RxString get phone => _profileStore.phone;

  // Stats
  RxInt get totalTasksCompleted => _profileStore.totalTasksCompleted;
  RxDouble get totalEarned => _profileStore.totalEarned;

  // Assigned location
  RxString get assignedLocation => _profileStore.assignedLocation;

  // Services provided - full list from design
  RxList<String> get servicesProvided => _profileStore.servicesProvided;

  final _token = Get.find<TokenService>();
  final _authService = Get.find<AuthService>();

  /// Get display name with title
  String get displayName => _profileStore.displayName;

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    loadProfile();
  }

  /// Load agent profile
  Future<void> loadProfile({bool forceRefresh = false}) async {
    await _profileStore.refreshProfile(forceRefresh: forceRefresh);
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
      _authService.clearSession();
      _token.clear();

      if (Get.isRegistered<UserProfileStore>()) {
        Get.find<UserProfileStore>().clear();
      }
      if (Get.isRegistered<AgentProfileStore>()) {
        Get.find<AgentProfileStore>().clear();
      }

      _clearScopedControllers();

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
    await loadProfile(forceRefresh: true);
  }

  void _clearScopedControllers() {
    if (Get.isRegistered<MainShellController>()) {
      Get.delete<MainShellController>(force: true);
    }
    if (Get.isRegistered<AgentShellController>()) {
      Get.delete<AgentShellController>(force: true);
    }
    if (Get.isRegistered<UserBottomNavController>()) {
      Get.delete<UserBottomNavController>(force: true);
    }
    if (Get.isRegistered<AgentBottomNavController>()) {
      Get.delete<AgentBottomNavController>(force: true);
    }
  }
}
