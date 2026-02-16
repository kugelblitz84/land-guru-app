import 'package:get/get.dart';
import '../../../core/services/agent_profile_store.dart';

/// Controller for the agent shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class AgentShellController extends GetxController {
  final _profileStore = Get.find<AgentProfileStore>();

  RxString get agentName => _profileStore.agentName;
  RxString get agentTitle => _profileStore.agentTitle;
  RxString get agentAvatar => _profileStore.profileImage;
  RxBool get isOnline => _profileStore.isOnline;
  RxInt get unreadNotificationCount => _profileStore.unreadNotificationCount;
  RxBool get isLoading => _profileStore.isLoading;

  /// Get display name with title (e.g., "Adv. Sahil")
  String get displayName {
    return _profileStore.displayName;
  }

  @override
  void onInit() {
    super.onInit();
    _profileStore.hydrateFromSession();
    _profileStore.refreshProfile(showError: false);
  }

  /// Load agent data from API/storage
  Future<void> loadAgentData() async {
    await _profileStore.refreshProfile(showError: false);
  }

  /// Refresh agent data
  Future<void> refresh() async {
    await _profileStore.refreshProfile(forceRefresh: true, showError: false);
  }

  /// Update agent name
  void updateAgentName(String name) {
    _profileStore.agentName.value = name;
  }

  /// Update agent title
  void updateAgentTitle(String title) {
    _profileStore.agentTitle.value = title;
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
