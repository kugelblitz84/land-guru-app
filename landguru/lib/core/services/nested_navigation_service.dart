import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/shared/bottom_nav/user_bottom_nav_controller.dart';
import '../../modules/shared/bottom_nav/nested_navigator.dart';

/// Service to handle nested navigation within the bottom nav tabs.
/// Use this to navigate to detail pages while keeping the bottom nav visible.
class NestedNavigationService {
  NestedNavigationService._();

  /// Get the UserBottomNavController if available
  static UserBottomNavController? get _navController {
    try {
      return Get.find<UserBottomNavController>();
    } catch (e) {
      return null;
    }
  }

  /// Check if nested navigation is available (we're inside the main shell)
  static bool get isAvailable => _navController != null;

  /// Navigate to a page within the current tab (nested navigation).
  /// Falls back to regular Get.to() if nested navigation is not available.
  ///
  /// [page] - The widget to navigate to
  /// [arguments] - Optional arguments to pass to the route (accessible via Get.arguments)
  /// [binding] - Optional binding to execute before navigation
  /// [settings] - Optional route settings
  /// [transition] - Optional transition animation
  /// [duration] - Optional transition duration
  static Future<T?>? to<T>(
    Widget page, {
    dynamic arguments,
    Bindings? binding,
    RouteSettings? settings,
    Transition? transition,
    Duration? duration,
  }) {
    // Execute binding if provided
    binding?.dependencies();

    final controller = _navController;
    if (controller != null) {
      // Build route settings with arguments
      final routeSettings = settings ??
          RouteSettings(
            name: page.runtimeType.toString(),
            arguments: arguments,
          );

      return Get.toNested<T>(
        page,
        navigatorKey: controller.currentNavigatorKey,
        settings: routeSettings,
        transition: transition,
        duration: duration,
      );
    }
    // Fallback to regular navigation
    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: arguments ?? settings?.arguments,
      binding: binding,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
    );
  }

  /// Navigate to a page within a specific tab.
  /// Also switches to that tab.
  static Future<T?>? toTab<T>(
    int tabIndex,
    Widget page, {
    RouteSettings? settings,
    Transition? transition,
    Duration? duration,
  }) {
    final controller = _navController;
    if (controller != null) {
      // Switch to the target tab first
      controller.currentIndex.value = tabIndex;
      // Then navigate within that tab
      return Get.toNested<T>(
        page,
        navigatorKey: controller.navigatorKeys[tabIndex],
        settings: settings,
        transition: transition,
        duration: duration,
      );
    }
    // Fallback to regular navigation
    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: settings?.arguments,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
    );
  }

  /// Go back within the nested navigator.
  /// Falls back to Get.back() if nested navigation is not available.
  static void back<T>({T? result}) {
    final controller = _navController;
    if (controller != null && controller.canPopNested()) {
      controller.currentNavigatorKey.currentState?.pop(result);
    } else {
      Get.back(result: result);
    }
  }

  /// Check if we can pop within the current nested navigator
  static bool canPop() {
    final controller = _navController;
    if (controller != null) {
      return controller.canPopNested();
    }
    return Navigator.canPop(Get.context!);
  }

  /// Pop to the root of the current tab
  static void popToRoot() {
    final controller = _navController;
    if (controller != null) {
      Get.popToRootNested(navigatorKey: controller.currentNavigatorKey);
    }
  }

  /// Switch to a specific tab (by index)
  static void switchToTab(int index) {
    final controller = _navController;
    if (controller != null) {
      controller.changeTab(index);
    }
  }

  /// Switch to a specific tab (by name)
  static void switchToTabByName(String tabName) {
    final controller = _navController;
    if (controller != null) {
      controller.navigateToTab(tabName);
    }
  }
}
