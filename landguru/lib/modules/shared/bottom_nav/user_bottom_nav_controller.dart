import 'package:get/get.dart';

/// Controller for User Bottom Navigation
/// Tabs: Home, Properties, Appointments, My Deals, Profile
class UserBottomNavController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// Whether notifications page is showing (within Home tab)
  final RxBool showNotifications = false.obs;

  /// Tab items for user
  static const List<String> tabNames = [
    'Home',
    'Properties',
    'Appointments',
    'My Deals',
    'Profile',
  ];

  /// Change tab
  void changeTab(int index) {
    // If switching to a different tab, hide notifications
    if (index != 0) {
      showNotifications.value = false;
    }
    currentIndex.value = index;
  }

  /// Navigate to specific tab by name
  void navigateToTab(String tabName) {
    final index = tabNames.indexOf(tabName);
    if (index != -1) {
      changeTab(index);
    }
  }

  /// Show notifications page (stays in Home tab)
  void goToNotifications() {
    currentIndex.value = 0;
    showNotifications.value = true;
  }

  /// Go back from notifications to home
  void backFromNotifications() {
    showNotifications.value = false;
  }
}
