import 'package:get/get.dart';

/// Service for User Bottom Navigation
/// Tabs: Home, Properties, Appointments, My Deals, Profile
class UserBottomNavController extends GetxService {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

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
