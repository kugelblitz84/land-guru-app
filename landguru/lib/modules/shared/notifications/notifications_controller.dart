import 'dart:async';

import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import '../controllers/agent_profile_store.dart';
import '../controllers/user_profile_store.dart';
import 'services/notifications_service.dart';
import '../../../core/services/user_type_service.dart';
import '../../../routes/app_routes.dart';
import 'models/notification_model.dart';

/// Shared controller for Notifications screen
/// Used by both User and Agent
class NotificationsController extends GetxController {
  NotificationsController(this._notificationsService);

  final NotificationsService _notificationsService;

  static List<NotificationItem> _cachedNotifications = <NotificationItem>[];
  static String _cachedSelectedFilter = NotificationFilters.all;
  static bool _hasCachedData = false;

  // State
  final RxBool isLoading = false.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString selectedFilter = NotificationFilters.all.obs;

  /// Get filtered notifications
  List<NotificationItem> get filteredNotifications {
    switch (selectedFilter.value) {
      case NotificationFilters.all:
        return notifications;
      case NotificationFilters.actionRequired:
        return notifications.where((n) => n.isActionRequired).toList();
      case NotificationFilters.appointments:
        return notifications
            .where((n) => n.type == NotificationTypes.appointment)
            .toList();
      default:
        return notifications;
    }
  }

  /// Check if there are unread notifications
  bool get hasUnreadNotifications => notifications.any((n) => !n.isRead);

  /// Get unread count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      selectedFilter.value = _cachedSelectedFilter;
      notifications.assignAll(_cachedNotifications);
      _syncNotificationCount();
      return;
    }

    isLoading.value = true;
    final result = await ApiErrorHandler.call(
      () => _notificationsService.fetchNotificationHistory(
        query: const NotificationHistoryQuery(page: 1, limit: 50),
      ),
      errorTitle: 'Error',
      fallbackMessage: 'Failed to load notifications',
    );
    if (!result.isSuccess) {
      isLoading.value = false;
      return;
    }

    final history = result.data;
    if (history == null) {
      notifications.clear();
      _syncNotificationCount();
      _syncCache();
      isLoading.value = false;
      return;
    }

    notifications.assignAll(history.notifications);

    // Sync notification count with shell controller
    _syncNotificationCount();
    _syncCache();
    isLoading.value = false;
  }

  /// Sync notification count with MainShellController
  void _syncNotificationCount() {
    if (!Get.isRegistered<UserTypeService>()) {
      return;
    }

    final userTypeService = Get.find<UserTypeService>();
    if (userTypeService.isAgent) {
      if (Get.isRegistered<AgentProfileStore>()) {
        Get.find<AgentProfileStore>().updateUnreadCount(unreadCount);
      }
      return;
    }

    if (userTypeService.isUser) {
      if (Get.isRegistered<UserProfileStore>()) {
        Get.find<UserProfileStore>().updateUnreadCount(unreadCount);
      }
      return;
    }

    if (Get.isRegistered<UserProfileStore>()) {
      Get.find<UserProfileStore>().updateUnreadCount(unreadCount);
    }
    if (Get.isRegistered<AgentProfileStore>()) {
      Get.find<AgentProfileStore>().updateUnreadCount(unreadCount);
    }
  }

  /// Change filter tab
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _syncCache();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      if (notification.isRead) {
        return;
      }

      notifications[index] = notification.copyWith(isRead: true);
      _syncNotificationCount();
      _syncCache();

      final result = await ApiErrorHandler.call(
        () => _notificationsService.markAsRead(notificationId: notificationId),
        showError: false,
      );

      if (!result.isSuccess) {
        notifications[index] = notification;
        _syncNotificationCount();
        _syncCache();
      }
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final previous = List<NotificationItem>.from(notifications);

    notifications.value = notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    _syncNotificationCount();
    _syncCache();

    final result = await ApiErrorHandler.call(
      () => _notificationsService.markAllAsRead(),
      showError: false,
    );

    if (!result.isSuccess) {
      notifications.assignAll(previous);
      _syncNotificationCount();
      _syncCache();
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationItem notification) {
    unawaited(markAsRead(notification.id));
    // TODO: Navigate to relevant page based on notification type
  }

  /// Navigate to explore listings (from empty state)
  void goToExploreListings() {
    Get.toNamed(AppRoutes.PROPERTIES_FOR_SALE);
  }

  /// Go back to previous page
  void goBack() {
    Get.back();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  /// Clear all notifications (for testing empty state)
  void clearNotifications() {
    notifications.clear();
    _syncNotificationCount();
    _syncCache();
  }

  void _syncCache() {
    _cachedNotifications = List<NotificationItem>.from(notifications);
    _cachedSelectedFilter = selectedFilter.value;
    _hasCachedData = true;
  }
}
