import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/shared/bottom_nav/user_bottom_nav_controller.dart';

/// Service to handle app navigation in a simple GetX-first way.
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

  /// Navigate to a page using GetX navigation.
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

    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: arguments ?? settings?.arguments,
      binding: binding,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
    );
  }

  /// Switch to a specific tab and navigate to a page.
  static Future<T?>? toTab<T>(
    int tabIndex,
    Widget page, {
    RouteSettings? settings,
    Transition? transition,
    Duration? duration,
  }) {
    final controller = _navController;
    if (controller != null) {
      controller.changeTab(tabIndex);
    }

    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: settings?.arguments,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
    );
  }

  /// Go back to previous page.
  static void back<T>({T? result}) {
    Get.back(result: result);
  }

  /// Check if we can pop from current route stack.
  static bool canPop() {
    return Get.key.currentState?.canPop() ?? false;
  }

  /// Pop to the root route.
  static void popToRoot() {
    Get.until((route) => route.isFirst);
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
