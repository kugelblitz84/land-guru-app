import 'package:get/get.dart';
import '../models/user_system_model.dart';
import '../../../core/services/api_error_handler.dart';
import '../controllers/user_profile_store.dart';
import '../notifications/services/notifications_service.dart';

/// Controller for the main shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class MainShellController extends GetxController {
  final _profileStore = Get.find<UserProfileStore>();
  final _notificationsService = Get.find<NotificationsService>();

  Rx<UserProfileStateModel> get profileModel => _profileStore.profileModel;
  RxBool get isLoading => _profileStore.isLoading;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _profileStore.hydrateFromSession();
    loadUserData();
  }

  /// Load user data from API/storage
  Future<void> loadUserData() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(showError: false),
      showError: false,
    );

    await _syncUnreadNotificationCount();
  }

  /// Refresh user data
  Future<void> refresh() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(forceRefresh: true, showError: false),
      showError: false,
    );

    await _syncUnreadNotificationCount();
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

  Future<void> _syncUnreadNotificationCount() async {
    final unreadResult = await ApiErrorHandler.call<int>(
      () => _notificationsService.fetchUnreadNotificationCount(),
      showError: false,
    );

    if (unreadResult.isSuccess && unreadResult.data != null) {
      _profileStore.updateUnreadCount(unreadResult.data!);
    }
  }
}
