import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../routes/app_routes.dart';

/// Controller for User Profile screen
class ProfileController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;

  // User data
  final RxString userName = 'User Name'.obs;
  final RxString userPhone = '+8801700000000'.obs;
  final RxString userEmail = 'username@email.com'.obs;
  final RxString userAddress = 'Dhaka, Bangladesh'.obs;
  final RxString profileImage = ''.obs;
  final RxBool isVerified = true.obs;

  // Additional profile data
  final RxString division = 'Rajshahi'.obs;
  final RxString district = 'Rajshahi'.obs;
  final RxString upazilla = 'Bogura'.obs;
  final RxString pouroshova = 'Bogura Pouroshova'.obs;
  final RxString wardNo = '03'.obs;
  final RxString postalCode = '5800'.obs;
  final RxString fullAddress =
      'Holding #45, Ward #03, Bogura Pourashava, Bogura Sadar, Bogura-5800, Rajshahi'
          .obs;

  // Verification documents
  final RxString nidNumber = '88***321'.obs;
  final RxBool isNidVerified = true.obs;
  final RxString tinNumber = '44***99'.obs;
  final RxBool isTinVerified = true.obs;
  final _token = Get.find<TokenService>();
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
      //await Future.delayed(const Duration(milliseconds: 500));
      _token.clear();
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
