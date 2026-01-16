import 'package:get/get.dart';

/// Service for Agent Bottom Navigation
/// Tabs: Home, My Tasks, Appointments, Profile
class AgentBottomNavController extends GetxService {
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
      currentIndex.value = index;
    }
  }
}
