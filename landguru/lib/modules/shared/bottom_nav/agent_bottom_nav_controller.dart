import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import 'nested_navigator.dart';

/// Controller for Agent Bottom Navigation
/// Tabs: Home, My Tasks, Appointments, Profile
class AgentBottomNavController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// Navigator keys for each tab (for nested navigation)
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home (Dashboard)
    GlobalKey<NavigatorState>(), // My Tasks
    GlobalKey<NavigatorState>(), // Appointments
    GlobalKey<NavigatorState>(), // Profile
  ];

  /// Tab items for agent
  static const List<String> tabNames = [
    'Home',
    'My Tasks',
    'Appointments',
    'Profile',
  ];

  /// Get current tab's navigator key
  GlobalKey<NavigatorState> get currentNavigatorKey =>
      navigatorKeys[currentIndex.value];

  /// Change tab - always pop to root when switching
  void changeTab(int index) {
    Get.popToRootNested(navigatorKey: navigatorKeys[currentIndex.value]);
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

  /// Navigate to a page within the current tab (nested navigation)
  Future<T?>? pushNested<T>(Widget page, {RouteSettings? settings}) {
    return Get.toNested<T>(
      page,
      navigatorKey: currentNavigatorKey,
      settings: settings,
    );
  }

  /// Navigate to a page within a specific tab
  Future<T?>? pushNestedToTab<T>(
    int tabIndex,
    Widget page, {
    RouteSettings? settings,
  }) {
    if (tabIndex >= 0 && tabIndex < navigatorKeys.length) {
      return Get.toNested<T>(
        page,
        navigatorKey: navigatorKeys[tabIndex],
        settings: settings,
      );
    }
    return null;
  }

  /// Pop from current tab's nested navigator
  void popNested() {
    Get.backNested(navigatorKey: currentNavigatorKey);
  }

  /// Check if can pop from current tab
  bool canPopNested() {
    return Get.canPopNested(navigatorKey: currentNavigatorKey);
  }

  /// Handle back button - returns true if handled, false to let system handle
  Future<bool> onWillPop() async {
    if (canPopNested()) {
      popNested();
      return false; // Don't exit app
    }
    return true; // Let system handle (might exit app)
  }
}
