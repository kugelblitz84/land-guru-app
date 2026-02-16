import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/agent_profile_store.dart';
import '../../../core/services/user_profile_store.dart';
import '../../../core/services/user_type_service.dart';
import '../../../routes/app_routes.dart';

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
  static List<NotificationItem> _cachedNotifications = <NotificationItem>[];
  static NotificationFilter _cachedSelectedFilter = NotificationFilter.all;
  static bool _hasCachedData = false;

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
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      selectedFilter.value = _cachedSelectedFilter;
      notifications.assignAll(_cachedNotifications);
      _syncNotificationCount();
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Load notifications from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - uncomment to test with notifications
      notifications.value = [
        NotificationItem(
          id: '1',
          title: 'New Service Request Assigned',
          description:
              "You've been assigned for the service: Deed Writing #SERV892-POST-1042. View details and start completing the service as soon as possible.",
          timeAgo: '10m ago',
          type: NotificationType.offerPost,
          isRead: false,
          isActionRequired: true,
        ),
        NotificationItem(
          id: '2',
          title: 'New Service Request Assigned',
          description:
              "You've been assigned for the service: Ownership History Validation #SERV892-POST-1042. View details and start completing the service as soon as possible.",
          timeAgo: '20m ago',
          type: NotificationType.offerPost,
          isRead: false,
          isActionRequired: true,
        ),
        NotificationItem(
          id: '3',
          title: 'Complete Offer Post',
          description:
              'A Buyer accepted your offer on the Post "Modern Duplex Villa". Complete the post as soon as possible for fixing the appointment.',
          timeAgo: '1h ago',
          type: NotificationType.offerPost,
          isRead: false,
          isActionRequired: true,
        ),
        NotificationItem(
          id: '4',
          title: 'We Quoted on your Sell Post',
          description:
              'We quoted on the Post "Modern Duplex Villa". Review our service fees and pay your fees.',
          timeAgo: '2h ago',
          type: NotificationType.quote,
          isRead: false,
          isActionRequired: true,
        ),
        NotificationItem(
          id: '5',
          title: 'Upcoming Appointment',
          description: '#SERV892-POST-1042, 12 Jan 2026, 10:00 AM.',
          timeAgo: 'Yesterday',
          type: NotificationType.appointment,
          isRead: true,
          isActionRequired: false,
        ),
        NotificationItem(
          id: '6',
          title: 'Document Reviewed',
          description:
              'Your submission on the service: Pentagraph Map Verification was reviewed. No issues found.',
          timeAgo: '3d ago',
          type: NotificationType.serviceUpdate,
          isRead: true,
          isActionRequired: false,
        ),
        NotificationItem(
          id: '7',
          title: 'Profile Verified',
          description:
              'Congratulations! Your profile has been verified. You can now access all features.',
          timeAgo: '5d ago',
          type: NotificationType.profileVerified,
          isRead: true,
          isActionRequired: false,
        ),
        NotificationItem(
          id: '8',
          title: 'New Offer Received',
          description:
              'You received a new offer on your buy post "5 Katha Plot in Purbachal". Review the offer now.',
          timeAgo: '1w ago',
          type: NotificationType.newPost,
          isRead: true,
          isActionRequired: false,
        ),
      ];

      // Sync notification count with shell controller
      _syncNotificationCount();
      _syncCache();
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
  void changeFilter(NotificationFilter filter) {
    selectedFilter.value = filter;
    _syncCache();
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
      _syncCache();
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
    _syncCache();
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
