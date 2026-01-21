import 'package:get/get.dart';

/// Controller for the agent shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class AgentShellController extends GetxController {
  // Agent information
  final RxString agentName = 'Agent'.obs;
  final RxString agentTitle = ''.obs; // e.g., "Adv." for Advocate
  final RxString agentAvatar = ''.obs;
  final RxBool isOnline = true.obs;

  // Notification badge count
  final RxInt unreadNotificationCount = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  /// Get display name with title (e.g., "Adv. Sahil")
  String get displayName {
    if (agentTitle.value.isNotEmpty) {
      return '${agentTitle.value} ${agentName.value}';
    }
    return agentName.value;
  }

  @override
  void onInit() {
    super.onInit();
    loadAgentData();
  }

  /// Load agent data from API/storage
  Future<void> loadAgentData() async {
    isLoading.value = true;
    try {
      // TODO: Load agent data from API
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for now
      agentTitle.value = 'Adv.';
      agentName.value = 'Sahil';
      unreadNotificationCount.value = 3;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh agent data
  Future<void> refresh() async {
    await loadAgentData();
  }

  /// Update agent name
  void updateAgentName(String name) {
    agentName.value = name;
  }

  /// Update agent title
  void updateAgentTitle(String title) {
    agentTitle.value = title;
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
