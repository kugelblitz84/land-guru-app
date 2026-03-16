import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';

/// Service for Agent Notifications screen
/// Handles: All, Action Required, Appointments tabs
class AgentNotificationsController extends GetxController {
  // Tab state
  final RxInt selectedTabIndex =
      0.obs; // 0: All, 1: Action Required, 2: Appointments

  // Loading states
  final RxBool isLoading = false.obs;

  // Lists
  final RxList allNotifications = [].obs;
  final RxList actionRequiredNotifications = [].obs;
  final RxList appointmentNotifications = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    isLoading.value = true;
    await ApiErrorHandler.call(
      () => Future<void>.delayed(const Duration(seconds: 1)),
      showError: false,
    );
    isLoading.value = false;
  }

  /// Mark as read
  Future<void> markAsRead(String notificationId) async {
    // TODO: Implement mark as read
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    // TODO: Implement mark all as read
  }

  /// Handle notification tap
  void onNotificationTap(String notificationId, String type) {
    // TODO: Navigate based on notification type
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}
