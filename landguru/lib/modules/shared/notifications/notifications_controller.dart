import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import '../controllers/agent_profile_store.dart';
import '../controllers/user_profile_store.dart';
import '../../../core/services/user_type_service.dart';
import '../../../routes/app_routes.dart';
import 'models/notification_model.dart';

/// Shared controller for Notifications screen
/// Used by both User and Agent
class NotificationsController extends GetxController {
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
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
      errorTitle: 'Error',
      fallbackMessage: 'Failed to load notifications',
    );
    if (!result.isSuccess) {
      isLoading.value = false;
      return;
    }

    // Mock data - uncomment to test with notifications
    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'New Service Request Assigned',
        description:
            "You've been assigned for the service: Deed Writing #SERV892-POST-1042. View details and start completing the service as soon as possible.",
        timeAgo: '10m ago',
        type: NotificationTypes.offerPost,
        isRead: false,
        isActionRequired: true,
      ),
      NotificationItem(
        id: '2',
        title: 'New Service Request Assigned',
        description:
            "You've been assigned for the service: Ownership History Validation #SERV892-POST-1042. View details and start completing the service as soon as possible.",
        timeAgo: '20m ago',
        type: NotificationTypes.offerPost,
        isRead: false,
        isActionRequired: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Complete Offer Post',
        description:
            'A Buyer accepted your offer on the Post "Modern Duplex Villa". Complete the post as soon as possible for fixing the appointment.',
        timeAgo: '1h ago',
        type: NotificationTypes.offerPost,
        isRead: false,
        isActionRequired: true,
      ),
      NotificationItem(
        id: '4',
        title: 'We Quoted on your Sell Post',
        description:
            'We quoted on the Post "Modern Duplex Villa". Review our service fees and pay your fees.',
        timeAgo: '2h ago',
        type: NotificationTypes.quote,
        isRead: false,
        isActionRequired: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Upcoming Appointment',
        description: '#SERV892-POST-1042, 12 Jan 2026, 10:00 AM.',
        timeAgo: 'Yesterday',
        type: NotificationTypes.appointment,
        isRead: true,
        isActionRequired: false,
      ),
      NotificationItem(
        id: '6',
        title: 'Document Reviewed',
        description:
            'Your submission on the service: Pentagraph Map Verification was reviewed. No issues found.',
        timeAgo: '3d ago',
        type: NotificationTypes.serviceUpdate,
        isRead: true,
        isActionRequired: false,
      ),
      NotificationItem(
        id: '7',
        title: 'Profile Verified',
        description:
            'Congratulations! Your profile has been verified. You can now access all features.',
        timeAgo: '5d ago',
        type: NotificationTypes.profileVerified,
        isRead: true,
        isActionRequired: false,
      ),
      NotificationItem(
        id: '8',
        title: 'New Offer Received',
        description:
            'You received a new offer on your buy post "5 Katha Plot in Purbachal". Review the offer now.',
        timeAgo: '1w ago',
        type: NotificationTypes.newPost,
        isRead: true,
        isActionRequired: false,
      ),
    ];

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
      notifications[index] = notification.copyWith(isRead: true);
      _syncNotificationCount();
      _syncCache();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    notifications.value = notifications.map((n) {
      return n.copyWith(isRead: true);
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
