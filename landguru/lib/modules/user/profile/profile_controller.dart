import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/agent_bottom_nav_controller.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import '../../shared/shell/agent_shell_controller.dart';
import '../../shared/shell/main_shell_controller.dart';

/// Controller for User Profile screen
class ProfileController extends GetxController {
  // State
  final RxBool isLoggingOut = false.obs;
  final _profileStore = Get.find<UserProfileStore>();

  // Profile model is the source of truth for profile views.
  Rx<UserProfileStateModel> get profileModel => _profileStore.profileModel;
  RxBool get isLoading => _profileStore.isLoading;

  final _token = Get.find<TokenService>();
  final _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    loadProfile();
  }

  /// Load user profile
  Future<void> loadProfile({bool forceRefresh = false}) async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(forceRefresh: forceRefresh),
      showError: false,
    );
  }

  /// Navigate to edit profile
  void goToEditProfile() {
    Get.toNamed(AppRoutes.PROFILE_EDIT);
  }

  /// Navigate to change password
  void goToChangePassword() {
    Get.toNamed(AppRoutes.PROFILE_CHANGE_PASSWORD);
  }

  /// Logout
  Future<void> logout() async {
    isLoggingOut.value = true;
    final result = await ApiErrorHandler.call(
      () async {
        _authService.clearSession();
        _token.clear();

        if (Get.isRegistered<UserProfileStore>()) {
          Get.find<UserProfileStore>().clear();
        }
        if (Get.isRegistered<AgentProfileStore>()) {
          Get.find<AgentProfileStore>().clear();
        }

        _clearScopedControllers();

        // Navigate to login and clear all previous routes
        Get.offAllNamed(AppRoutes.LOGIN);
      },
      errorTitle: 'Error',
      fallbackMessage: 'Failed to logout',
    );

    isLoggingOut.value = false;
    if (!result.isSuccess) {
      return;
    }
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
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
