import 'package:get/get.dart';
import '../models/agent_system_model.dart';
import '../../../core/services/api_error_handler.dart';
import '../controllers/agent_profile_store.dart';

/// Controller for the agent shell - manages shared state across bottom nav tabs
/// This controller persists across all tabs and provides shared functionality
class AgentShellController extends GetxController {
  final _profileStore = Get.find<AgentProfileStore>();

  Rx<AgentProfileStateModel> get profileModel => _profileStore.profileModel;
  RxBool get isLoading => _profileStore.isLoading;

  /// Get display name with title (e.g., "Adv. Sahil")
  String get displayName {
    return _profileStore.displayName;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _profileStore.hydrateFromSession();
    ApiErrorHandler.call(
      () => _profileStore.refreshProfile(showError: false),
      showError: false,
    );
  }

  /// Load agent data from API/storage
  Future<void> loadAgentData() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(showError: false),
      showError: false,
    );
  }

  /// Refresh agent data
  Future<void> refresh() async {
    await ApiErrorHandler.call(
      () => _profileStore.refreshProfile(forceRefresh: true, showError: false),
      showError: false,
    );
  }

  /// Update agent name
  void updateAgentName(String name) {
    _profileStore.profileModel.value = _profileStore.profileModel.value
        .copyWith(agentName: name);
  }

  /// Update agent title
  void updateAgentTitle(String title) {
    _profileStore.profileModel.value = _profileStore.profileModel.value
        .copyWith(agentTitle: title);
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
