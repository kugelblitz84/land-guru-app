import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for Agent Bottom Navigation
/// Tabs: Home, My Tasks, Appointments, Profile
class AgentBottomNavController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// Tab items for agent
  static const List<String> tabNames = [
    'Home',
    'My Tasks',
    'Appointments',
    'Profile',
  ];

  /// Change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Navigate to specific tab by name
  void navigateToTab(String tabName) {
    final index = tabNames.indexOf(tabName);
    if (index != -1) {
      changeTab(index);
    }
  }

  /// Navigate to notifications page (preserves current tab)
  void goToNotifications() {
    Get.toNamed(AppRoutes.AGENT_NOTIFICATIONS);
  }

  /// Handle back button - returns true if handled, false to let system handle
  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }
    return true;
  }
}
