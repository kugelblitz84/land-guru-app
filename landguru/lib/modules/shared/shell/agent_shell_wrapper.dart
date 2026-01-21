import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'agent_shell_header.dart';

/// Wrapper widget that provides the shared header shell for Agent tab content
/// Use this to wrap content views that should display the common header
class AgentShellWrapper extends StatelessWidget {
  /// The content to display below the header
  final Widget child;

  /// Whether to show the header (useful for sub-pages within a tab)
  final bool showHeader;

  /// Background color for the shell
  final Color? backgroundColor;

  /// Additional padding around the content
  final EdgeInsetsGeometry? contentPadding;

  const AgentShellWrapper({
    super.key,
    required this.child,
    this.showHeader = true,
    this.backgroundColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            if (showHeader) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    const AgentShellHeader(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],

            // Content section
            Expanded(
              child: contentPadding != null
                  ? Padding(padding: contentPadding!, child: child)
                  : child,
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrollable variant of AgentShellWrapper for pages with scrollable content
/// The header stays fixed while content scrolls
class AgentShellScrollWrapper extends StatelessWidget {
  /// The scrollable content widgets
  final List<Widget> children;

  /// Whether to show the header
  final bool showHeader;

  /// Background color
  final Color? backgroundColor;

  /// Horizontal padding for the content
  final double? horizontalPadding;

  /// Callback for refresh functionality
  final Future<void> Function()? onRefresh;

  const AgentShellScrollWrapper({
    super.key,
    required this.children,
    this.showHeader = true,
    this.backgroundColor,
    this.horizontalPadding,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final padding = horizontalPadding ?? 16.w;

    Widget scrollContent = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showHeader) SizedBox(height: 16.h),
            ...children,
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );

    if (onRefresh != null) {
      scrollContent = RefreshIndicator(
        onRefresh: onRefresh!,
        child: scrollContent,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header section
            if (showHeader) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    const AgentShellHeader(),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],

            // Scrollable content section
            Expanded(child: scrollContent),
          ],
        ),
      ),
    );
  }
}
