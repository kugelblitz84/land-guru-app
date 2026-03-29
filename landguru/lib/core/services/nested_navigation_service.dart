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

  /// Returns the active nested navigator id for tab stacks (0-3).
  static int? get _activeTabNavigatorId {
    final controller = _navController;
    if (controller == null) return null;

    final index = controller.currentIndex.value;
    return (index >= 0 && index <= 3) ? index : null;
  }

  /// Navigate to a page using GetX navigation.
  static Future<T?>? to<T>(
    Widget page, {
    dynamic arguments,
    Bindings? binding,
    RouteSettings? settings,
    Transition? transition,
    Duration? duration,
    int? id,
  }) {
    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: arguments ?? settings?.arguments,
      binding: binding,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
      id: id ?? _activeTabNavigatorId,
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

    final nestedId = (tabIndex >= 0 && tabIndex <= 3) ? tabIndex : null;

    return Get.to<T>(
      () => page,
      routeName: settings?.name,
      arguments: settings?.arguments,
      transition: transition ?? Transition.rightToLeft,
      duration: duration,
      id: nestedId,
    );
  }

  /// Go back to previous page.
  static void back<T>({T? result}) {
    final nestedId = _activeTabNavigatorId;
    if (nestedId != null) {
      final nestedState = Get.nestedKey(nestedId)?.currentState;
      if (nestedState?.canPop() ?? false) {
        nestedState?.pop(result);
        return;
      }
    }

    final rootState = Get.key.currentState;
    if (rootState?.canPop() ?? false) {
      rootState?.pop(result);
    }
  }

  /// Check if we can pop from current route stack.
  static bool canPop() {
    final nestedId = _activeTabNavigatorId;
    if (nestedId != null) {
      final canPopNested = Get.nestedKey(nestedId)?.currentState?.canPop();
      if (canPopNested == true) {
        return true;
      }
    }

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
