import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../shell/main_shell_controller.dart';

/// Notification types
enum NotificationType {
  offerPost,
  quote,
  serviceUpdate,
  appointment,
  profileVerified,
  newPost,
  general,
}

/// Notification filter tabs
enum NotificationFilter { all, actionRequired, appointments }

/// Model for notification item
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;
  final bool isActionRequired;
  final String? relatedId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
    this.isActionRequired = false,
    this.relatedId,
  });

  /// Get icon for notification type
  IconData get icon {
    switch (type) {
      case NotificationType.offerPost:
      case NotificationType.quote:
        return Icons.warning_amber_rounded;
      case NotificationType.serviceUpdate:
        return Icons.description_outlined;
      case NotificationType.appointment:
        return Icons.calendar_today_outlined;
      case NotificationType.profileVerified:
        return Icons.info_outline;
      case NotificationType.newPost:
        return Icons.local_offer_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  /// Get icon background color
  Color get iconBackgroundColor {
    switch (type) {
      case NotificationType.offerPost:
      case NotificationType.quote:
        return const Color(0xFFFFEBEE);
      case NotificationType.serviceUpdate:
        return const Color(0xFFF5F5F5);
      case NotificationType.appointment:
        return const Color(0xFFE8F5E9);
      case NotificationType.profileVerified:
        return const Color(0xFFF5F5F5);
      case NotificationType.newPost:
        return const Color(0xFFE3F2FD);
      case NotificationType.general:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Get icon color
  Color get iconColor {
    switch (type) {
      case NotificationType.offerPost:
      case NotificationType.quote:
        return const Color(0xFFF44336);
      case NotificationType.serviceUpdate:
        return const Color(0xFF757575);
      case NotificationType.appointment:
        return const Color(0xFF4CAF50);
      case NotificationType.profileVerified:
        return const Color(0xFF757575);
      case NotificationType.newPost:
        return const Color(0xFF3B6CF5);
      case NotificationType.general:
        return const Color(0xFF757575);
    }
  }
}

/// Shared controller for Notifications screen
/// Used by both User and Agent
class NotificationsController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final Rx<NotificationFilter> selectedFilter = NotificationFilter.all.obs;

  /// Get filtered notifications
  List<NotificationItem> get filteredNotifications {
    switch (selectedFilter.value) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.actionRequired:
        return notifications.where((n) => n.isActionRequired).toList();
      case NotificationFilter.appointments:
        return notifications
            .where((n) => n.type == NotificationType.appointment)
            .toList();
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
  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      // TODO: Load notifications from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - uncomment to test with notifications
      notifications.value = [
        NotificationItem(
          id: '1',
          title: 'Complete Offer Post',
          description:
              'A Buyer accepted your offer on the Post "Modern Duplex Villa". Complete the post as soon as possible for fixing the appointment',
          timeAgo: '10m ago',
          type: NotificationType.offerPost,
          isRead: false,
          isActionRequired: true,
        ),
        NotificationItem(
          id: '2',
          title: 'We Quoted on your Sell Post',
          description:
              'We quoted on the Post "Modern Duplex Villa". Review our service fees and pay your fees.',
          timeAgo: '10m ago',
          type: NotificationType.quote,
          isRead: false,
          isActionRequired: true,
        ),
      ];

      // Sync notification count with shell controller
      _syncNotificationCount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync notification count with MainShellController
  void _syncNotificationCount() {
    if (Get.isRegistered<MainShellController>()) {
      final shellController = Get.find<MainShellController>();
      shellController.updateNotificationCount(unreadCount);
    }
  }

  /// Change filter tab
  void changeFilter(NotificationFilter filter) {
    selectedFilter.value = filter;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      notifications[index] = NotificationItem(
        id: notification.id,
        title: notification.title,
        description: notification.description,
        timeAgo: notification.timeAgo,
        type: notification.type,
        isRead: true,
        isActionRequired: notification.isActionRequired,
        relatedId: notification.relatedId,
      );
      _syncNotificationCount();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    notifications.value = notifications.map((n) {
      return NotificationItem(
        id: n.id,
        title: n.title,
        description: n.description,
        timeAgo: n.timeAgo,
        type: n.type,
        isRead: true,
        isActionRequired: n.isActionRequired,
        relatedId: n.relatedId,
      );
    }).toList();
    _syncNotificationCount();
  }

  /// Handle notification tap
  void onNotificationTap(NotificationItem notification) {
    markAsRead(notification.id);
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
    await loadNotifications();
  }

  /// Clear all notifications (for testing empty state)
  void clearNotifications() {
    notifications.clear();
    _syncNotificationCount();
  }
}
