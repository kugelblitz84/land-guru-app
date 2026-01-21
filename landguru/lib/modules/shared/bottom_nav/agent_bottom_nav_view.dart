import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../agent/dashboard/agent_dashboard_view.dart';
import '../../agent/profile/agent_profile_view.dart';
import '../shell/agent_shell_wrapper.dart';
import 'nested_navigator.dart';
import 'agent_bottom_nav_controller.dart';

/// Agent Bottom Navigation shell containing all main tabs
/// Tabs: Home (Dashboard), My Tasks, Appointments, Profile
/// Each tab has its own nested Navigator to support internal navigation
/// while keeping the bottom nav bar visible
class AgentBottomNavView extends GetView<AgentBottomNavController> {
  const AgentBottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: [
              // Tab 0: Home (Dashboard) - with shell header
              _buildNestedTab(
                index: 0,
                child: _buildShellContent(const AgentDashboardContentView()),
              ),

              // Tab 1: My Tasks - with shell header
              _buildNestedTab(
                index: 1,
                child: _buildShellContent(
                  _buildPlaceholderContent('My Tasks', Icons.task_alt),
                ),
              ),

              // Tab 2: Appointments - with shell header
              _buildNestedTab(
                index: 2,
                child: _buildShellContent(
                  _buildPlaceholderContent(
                    'Appointments',
                    Icons.calendar_today,
                  ),
                ),
              ),

              // Tab 3: Profile - without shell header (has its own layout)
              _buildNestedTab(index: 3, child: const AgentProfileView()),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  /// Build a tab with nested navigation support
  Widget _buildNestedTab({required int index, required Widget child}) {
    return NestedNavigator(
      navigatorKey: controller.navigatorKeys[index],
      initialPage: child,
      tabIndex: index,
    );
  }

  /// Wrap content with agent shell (shared header)
  Widget _buildShellContent(Widget content) {
    return AgentShellWrapper(showHeader: true, child: content);
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(color: AppColors.primary),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: 'My Tasks',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Appointments',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 5.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white.withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: AppColors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder content for tabs not yet implemented
  /// Note: This returns just the content, not wrapped in Scaffold
  /// The shell wrapper provides the Scaffold
  Widget _buildPlaceholderContent(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80.sp, color: AppColors.grey400),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 16.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
