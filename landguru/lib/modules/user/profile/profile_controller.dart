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

  // User data
  RxBool get isLoading => _profileStore.isLoading;
  RxString get userName => _profileStore.userName;
  RxString get userPhone => _profileStore.userPhone;
  RxString get userEmail => _profileStore.userEmail;
  RxString get userAddress => _profileStore.userAddress;
  RxString get profileImage => _profileStore.profileImage;
  RxBool get isVerified => _profileStore.isVerified;

  // Account summary
  RxString get memberSince => _profileStore.memberSince;
  RxInt get activeDeals => _profileStore.activeDeals;
  RxInt get propertiesListed => _profileStore.propertiesListed;

  // Additional profile data
  RxString get division => _profileStore.division;
  RxString get district => _profileStore.district;
  RxString get upazilla => _profileStore.upazilla;
  RxString get pouroshova => _profileStore.pouroshova;
  RxString get wardNo => _profileStore.wardNo;
  RxString get postalCode => _profileStore.postalCode;
  RxString get fullAddress => _profileStore.fullAddress;

  // Verification documents
  RxString get nidNumber => _profileStore.nidNumber;
  RxBool get isNidVerified => _profileStore.isNidVerified;
  RxString get tinNumber => _profileStore.tinNumber;
  RxBool get isTinVerified => _profileStore.isTinVerified;

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
    await _profileStore.refreshProfile(forceRefresh: forceRefresh);
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

      // Navigate to login and clear all previous routes
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
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
