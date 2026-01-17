import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_controller.dart';

/// User Profile screen
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),

                        // Profile Avatar
                        _buildProfileAvatar(),

                        SizedBox(height: 16.h),

                        // User Name
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // User Phone
                        Obx(
                          () => Text(
                            controller.userPhone.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Menu Items
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: controller.goToEditProfile,
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: controller.goToChangePassword,
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notification Settings',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {},
                        ),

                        SizedBox(height: 24.h),

                        // Logout Button
                        _buildLogoutButton(),

                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(150),
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.white,
        size: 50.sp,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey700, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoggingOut.value ? null : _showLogoutDialog,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(26),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.error.withAlpha(77)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isLoggingOut.value)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              else
                Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 22.sp,
                ),
              SizedBox(width: 12.w),
              Text(
                controller.isLoggingOut.value ? 'Logging out...' : 'Logout',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.grey600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
