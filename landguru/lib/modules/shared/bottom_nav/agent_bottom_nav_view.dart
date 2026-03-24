import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../agent/dashboard/agent_dashboard_view.dart';
import '../../agent/my_tasks/my_tasks_view.dart';
import '../../agent/appointments/agent_appointments_view.dart';
import '../../agent/profile/agent_profile_view.dart';
import '../shell/agent_shell_wrapper.dart';
import 'agent_bottom_nav_controller.dart';

/// Agent Bottom Navigation shell containing all main tabs
/// Tabs: Home (Dashboard), My Tasks, Appointments, Profile
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
          () => Stack(
            children: List.generate(4, (index) {
              if (!controller.visitedTabs.contains(index)) {
                return const SizedBox.shrink();
              }
              return Offstage(
                offstage: controller.currentIndex.value != index,
                child: TickerMode(
                  enabled: controller.currentIndex.value == index,
                  child: _buildTab(index),
                ),
              );
            }),
          ),
          // () => IndexedStack(
          //   index: controller.currentIndex.value,
          //   children: [
          //     _buildShellContent(const AgentDashboardContentView()),
          //     _buildShellContent(const AgentMyTasksContentView()),
          //     _buildShellContent(const AgentAppointmentsContentView()),
          //     const AgentProfileView(),
          //   ],
          // ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return _tabNavigator(id: 0, content: const AgentDashboardContentView());
      case 1:
        return _tabNavigator(id: 1, content: const AgentMyTasksContentView());
      case 2:
        return _tabNavigator(
          id: 2,
          content: const AgentAppointmentsContentView(),
        );
      case 3:
        return const AgentProfileView();
      default:
        return const SizedBox.shrink();
    }
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
}

class _tabNavigator extends StatelessWidget {
  final int id;
  final Widget content;

  const _tabNavigator({required this.id, required this.content});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(id),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) =>
            AgentShellWrapper(showHeader: true, child: content),
      ),
    );
  }
}
