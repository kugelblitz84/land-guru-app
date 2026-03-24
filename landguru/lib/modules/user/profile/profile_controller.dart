import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/agent_bottom_nav_controller.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import '../../shared/shell/agent_shell_controller.dart';
import '../../shared/shell/main_shell_controller.dart';
import '/modules/shared/models/user_system_model.dart';

/// Controller for User Profile screen
class ProfileController extends GetxController {
  ProfileController(
    this._profileStore,
    this._token,
    this._authService, {
    AgentProfileStore? agentProfileStore,
  }) : _agentProfileStore = agentProfileStore;

  // State
  final RxBool isLoggingOut = false.obs;
  final UserProfileStore _profileStore;

  // Profile model is the source of truth for profile views.
  Rx<UserProfileStateModel> get profileModel => _profileStore.profileModel;
  RxBool get isLoading => _profileStore.isLoading;

  final TokenService _token;
  final AuthService _authService;
  final AgentProfileStore? _agentProfileStore;

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

  /// Load user profile
  Future<void> loadProfile({bool forceRefresh = false}) async {
    await _profileStore.refreshProfile(forceRefresh: forceRefresh);

    if (!_authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
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

        _profileStore.clear();
        _agentProfileStore?.clear();

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
