import 'package:get/get.dart';
import '../../../core/services/user_profile_store.dart';

/// Controller for the main shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class MainShellController extends GetxController {
  final _profileStore = Get.find<UserProfileStore>();

  RxString get userName => _profileStore.userName;
  RxString get userAvatar => _profileStore.profileImage;
  RxBool get isOnline => _profileStore.isOnline;
  RxInt get unreadNotificationCount => _profileStore.unreadNotificationCount;
  RxBool get isLoading => _profileStore.isLoading;

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    _profileStore.refreshProfile(showError: false);
  }

  /// Load user data from API/storage
  Future<void> loadUserData() async {
    await _profileStore.refreshProfile(showError: false);
  }

  /// Refresh user data
  Future<void> refresh() async {
    await _profileStore.refreshProfile(forceRefresh: true, showError: false);
  }

  /// Update user name
  void updateUserName(String name) {
    _profileStore.userName.value = name;
  }

  /// Update notification count
  void updateNotificationCount(int count) {
    _profileStore.updateUnreadCount(count);
  }

  /// Clear notification badge
  void clearNotificationBadge() {
    _profileStore.clearUnreadCount();
  }
}
