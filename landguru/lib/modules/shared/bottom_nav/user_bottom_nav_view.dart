import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../user/appointments/appointments_view.dart';
import '../../user/home/home_view.dart';
import '../../user/my_deals/my_deals_view.dart';
import '../../user/profile/profile_view.dart';
import '../../user/properties/properties_view.dart';
import '../shell/main_shell_wrapper.dart';
import 'nested_navigator.dart';
import 'user_bottom_nav_controller.dart';

/// User Bottom Navigation shell containing all main tabs
/// Uses a shared header shell for tabs 0-3 (Home, Properties, Appointments, My Deals)
/// Profile tab (4) has its own layout without the shell header
/// Each tab has its own nested Navigator to support internal navigation
/// while keeping the bottom nav bar visible
class UserBottomNavView extends GetView<UserBottomNavController> {
  const UserBottomNavView({super.key});

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
              // Tab 0: Home - uses nested navigator with shell wrapper
              _buildNestedTab(
                index: 0,
                child: _buildShellContent(const HomeContentView()),
              ),

              // Tab 1: Properties - uses nested navigator with shell wrapper
              _buildNestedTab(
                index: 1,
                child: _buildShellContent(const PropertiesContentView()),
              ),

              // Tab 2: Appointments - uses nested navigator with shell wrapper
              _buildNestedTab(
                index: 2,
                child: _buildShellContent(const AppointmentsContentView()),
              ),

              // Tab 3: My Deals - uses nested navigator with shell wrapper
              _buildNestedTab(
                index: 3,
                child: _buildShellContent(const MyDealsContentView()),
              ),

              // Tab 4: Profile - uses nested navigator without shell wrapper
              _buildNestedTab(index: 4, child: const ProfileView()),
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

  /// Wrap content with shell (shared header)
  Widget _buildShellContent(Widget content) {
    return MainShellWrapper(showHeader: true, child: content);
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
                  icon: Icons.apartment_outlined,
                  activeIcon: Icons.apartment,
                  label: 'Properties',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Appointments',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.handshake_outlined,
                  activeIcon: Icons.handshake,
                  label: 'My Deals',
                ),
                _buildNavItem(
                  index: 4,
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
