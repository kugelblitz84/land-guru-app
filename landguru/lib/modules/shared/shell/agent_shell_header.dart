import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../bottom_nav/agent_bottom_nav_controller.dart';
import 'agent_shell_controller.dart';

/// Shared header widget displayed across all main Agent tabs (except Profile)
/// Contains agent avatar, welcome text, and notification icon
class AgentShellHeader extends StatelessWidget {
  const AgentShellHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgentShellController>();

    return Row(
      children: [
        // Agent Avatar with online indicator
        _buildAgentAvatar(controller),
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
                  controller.displayName,
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

  Widget _buildAgentAvatar(AgentShellController controller) {
    return Stack(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grey200, width: 2),
          ),
          child: ClipOval(
            child: Obx(() {
              final avatar = controller.profileModel.value.profileImage.trim();
              if (avatar.isNotEmpty) {
                return Image.network(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildAvatarFallback();
                  },
                );
              }

              return Image.asset(
                'assets/images/User_DP/sahil.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback();
                },
              );
            }),
          ),
        ),
        // Online indicator
        Obx(
          () => controller.profileModel.value.isOnline
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

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.grey200,
      child: Icon(Icons.person, color: AppColors.grey400, size: 28.sp),
    );
  }

  Widget _buildNotificationIcon(AgentShellController controller) {
    return GestureDetector(
      onTap: () {
        // Navigate to agent notifications
        final navController = Get.find<AgentBottomNavController>();
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
            final count = controller.profileModel.value.unreadNotificationCount;
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
