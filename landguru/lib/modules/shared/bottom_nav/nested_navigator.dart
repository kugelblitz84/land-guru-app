import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A widget that provides a nested Navigator for tab-based navigation.
/// This allows navigation within a tab while keeping the bottom nav bar visible.
class NestedNavigator extends StatelessWidget {
  /// Unique navigator key for this tab
  final GlobalKey<NavigatorState> navigatorKey;

  /// The initial/root page to display
  final Widget initialPage;

  /// Tab index for identification
  final int tabIndex;

  const NestedNavigator({
    super.key,
    required this.navigatorKey,
    required this.initialPage,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => initialPage,
          settings: settings,
        );
      },
    );
  }
}

/// Custom GetPageRoute that properly sets Get.arguments
class _NestedGetPageRoute<T> extends GetPageRoute<T> {
  _NestedGetPageRoute({
    required super.page,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.transition,
    super.transitionDuration,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Set Get.arguments when this route is active
    if (settings.arguments != null) {
      Get.routing.args = settings.arguments;
    }
    return super.buildContent(context);
  }
}

/// Extension to help with nested navigation
extension NestedNavigation on GetInterface {
  /// Navigate within a nested navigator (stays within the tab)
  Future<T?>? toNested<T>(
    Widget page, {
    required GlobalKey<NavigatorState> navigatorKey,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Transition? transition,
    Duration? duration,
  }) {
    // Set Get.arguments before navigation so controllers can access it in onInit
    if (settings?.arguments != null) {
      Get.routing.args = settings?.arguments;
    }

    return navigatorKey.currentState?.push<T>(
      _NestedGetPageRoute<T>(
        page: () => page,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        transition: transition ?? Transition.rightToLeft,
        transitionDuration: duration ?? const Duration(milliseconds: 300),
      ),
    );
  }

  /// Pop within a nested navigator
  void backNested({required GlobalKey<NavigatorState> navigatorKey}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }

  /// Check if can pop within nested navigator
  bool canPopNested({required GlobalKey<NavigatorState> navigatorKey}) {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Pop until root of nested navigator
  void popToRootNested({required GlobalKey<NavigatorState> navigatorKey}) {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
