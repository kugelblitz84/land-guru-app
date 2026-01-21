import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'agent_profile_controller.dart';

/// Agent Profile screen
class AgentProfileView extends GetView<AgentProfileController> {
  const AgentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        _buildProfileHeader(),
                        SizedBox(height: 24.h),
                        _buildStatsRow(),
                        SizedBox(height: 24.h),
                        _buildMenuSection(),
                        SizedBox(height: 32.h),
                        _buildLogoutButton(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Profile header with avatar, name, and verification badge
  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/User_DP/sahil.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey200,
                        child: Icon(
                          Icons.person,
                          color: AppColors.grey400,
                          size: 40.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Edit profile photo
                  },
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Name with verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.displayName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              Obx(
                () => controller.isVerified.value
                    ? Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Agent type and ID
          Obx(
            () => Text(
              '${controller.agentType.value} • ${controller.agentId.value}',
              style: TextStyle(fontSize: 13.sp, color: AppColors.grey600),
            ),
          ),
          SizedBox(height: 4.h),

          // Email
          Obx(
            () => Text(
              controller.email.value,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
          ),
        ],
      ),
    );
  }

  /// Stats row - Tasks completed and earnings
  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.task_alt,
                label: 'Tasks Completed',
                value: controller.totalTasksCompleted.toString(),
              ),
            ),
            Container(
              width: 1,
              height: 40.h,
              color: AppColors.primary.withAlpha(50),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.account_balance_wallet,
                label: 'Total Earned',
                value: '৳${_formatCurrency(controller.totalEarned.value)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.grey600),
        ),
      ],
    );
  }

  /// Menu section with profile options
  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: controller.goToEditProfile,
                ),
                _buildMenuDivider(),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: controller.goToChangePassword,
                ),
                _buildMenuDivider(),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Assigned Location',
                  subtitle: controller.assignedLocation.value,
                  onTap: () {},
                ),
                _buildMenuDivider(),
                _buildMenuItem(
                  icon: Icons.work_outline,
                  title: 'Services You Provide',
                  subtitle: controller.servicesProvided.join(', '),
                  onTap: () {},
                ),
                _buildMenuDivider(),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                _buildMenuDivider(),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.grey700, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.grey200,
      indent: 62.w,
    );
  }

  /// Logout button
  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton.icon(
          onPressed: controller.logout,
          icon: Icon(Icons.logout, size: 20.sp),
          label: Text(
            'Logout',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
