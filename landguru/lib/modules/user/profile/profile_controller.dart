import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for User Profile screen
class ProfileController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;

  // User data
  final RxString userName = 'User'.obs;
  final RxString userPhone = '+880 1712-345678'.obs;
  final RxString userEmail = 'user@example.com'.obs;
  final RxString userAddress = 'Dhaka, Bangladesh'.obs;
  final RxString profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // TODO: Load profile from API or local storage
      await Future.delayed(const Duration(milliseconds: 500));
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
      // TODO: Clear local storage / tokens
      await Future.delayed(const Duration(milliseconds: 500));

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
  Future<void> refresh() async {
    await loadProfile();
  }
}
