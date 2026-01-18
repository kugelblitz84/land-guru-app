import 'package:get/get.dart';

/// Controller for the main shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class MainShellController extends GetxController {
  // User information
  final RxString userName = 'User'.obs;
  final RxString userAvatar = ''.obs;
  final RxBool isOnline = true.obs;

  // Notification badge count
  final RxInt unreadNotificationCount = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load user data from API/storage
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // TODO: Load user data from API
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for now
      userName.value = 'User';
      unreadNotificationCount.value = 3;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh user data
  Future<void> refresh() async {
    await loadUserData();
  }

  /// Update user name
  void updateUserName(String name) {
    userName.value = name;
  }

  /// Update notification count
  void updateNotificationCount(int count) {
    unreadNotificationCount.value = count;
  }

  /// Clear notification badge
  void clearNotificationBadge() {
    unreadNotificationCount.value = 0;
  }
}
