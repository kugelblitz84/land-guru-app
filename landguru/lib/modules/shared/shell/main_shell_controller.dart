import 'package:get/get.dart';
import '../../../core/models/user_system_model.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/user_profile_store.dart';

/// Controller for the main shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class MainShellController extends GetxController {
  final _profileStore = Get.find<UserProfileStore>();

  Rx<UserProfileStateModel> get profileModel => _profileStore.profileModel;
  RxBool get isLoading => _profileStore.isLoading;

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    ApiErrorHandler.call(
      () => _profileStore.refreshProfile(showError: false),
      showError: false,
    );
  }

  /// Load user data from API/storage
  Future<void> loadUserData() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(showError: false),
      showError: false,
    );
  }

  /// Refresh user data
  Future<void> refresh() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(forceRefresh: true, showError: false),
      showError: false,
    );
  }

  /// Update user name
  void updateUserName(String name) {
    _profileStore.profileModel.value = _profileStore.profileModel.value
        .copyWith(userName: name);
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
