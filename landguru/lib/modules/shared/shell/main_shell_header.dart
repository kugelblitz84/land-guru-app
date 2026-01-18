import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../bottom_nav/user_bottom_nav_controller.dart';
import 'main_shell_controller.dart';

/// Shared header widget displayed across all main tabs (except Profile)
/// Contains user avatar, welcome text, and notification icon
class MainShellHeader extends StatelessWidget {
  const MainShellHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainShellController>();

    return Row(
      children: [
        // User Avatar with online indicator
        _buildUserAvatar(controller),
        SizedBox(width: 12.w),

        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
              ),
              Obx(
                () => Text(
                  '${controller.userName.value}!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notification icon with badge
        _buildNotificationIcon(controller),
      ],
    );
  }

  Widget _buildUserAvatar(MainShellController controller) {
    return Stack(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary.withAlpha(150), AppColors.primaryDark],
            ),
          ),
          child: Obx(() {
            if (controller.userAvatar.value.isNotEmpty) {
              // TODO: Replace with actual image when avatar URL is available
              return ClipOval(
                child: Icon(Icons.person, color: AppColors.white, size: 28.sp),
              );
            }
            return Icon(Icons.person, color: AppColors.white, size: 28.sp);
          }),
        ),
        // Online indicator
        Obx(
          () => controller.isOnline.value
              ? Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(MainShellController controller) {
    return GestureDetector(
      onTap: () {
        // Navigate to notifications
        final navController = Get.find<UserBottomNavController>();
        navController.goToNotifications();
      },
      child: Stack(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.grey900,
              size: 24.sp,
            ),
          ),
          // Notification badge
          Obx(() {
            final count = controller.unreadNotificationCount.value;
            if (count == 0) return const SizedBox.shrink();
            return Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
