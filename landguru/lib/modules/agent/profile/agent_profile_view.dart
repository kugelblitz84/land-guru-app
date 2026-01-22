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
                        SizedBox(height: 20.h),
                        _buildStatsRow(),
                        SizedBox(height: 16.h),
                        _buildAssignedLocationSection(),
                        SizedBox(height: 16.h),
                        _buildServicesSection(),
                        SizedBox(height: 16.h),
                        _buildViewProfileButton(),
                        SizedBox(height: 12.h),
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
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey200, width: 3),
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
                  onTap: controller.goToEditProfile,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(Icons.edit, color: AppColors.white, size: 16.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Name
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
          SizedBox(height: 4.h),

          // Agent ID and Type
          Obx(
            () => Column(
              children: [
                Text(
                  'Agent ID: ${controller.agentId.value}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                ),
                Text(
                  'Agent Type: ${controller.agentType.value}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Verified badge
          Obx(
            () => controller.isVerified.value
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Stats row - Tasks completed and earnings as separate cards
  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Total Tasks Completed Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL TASK\nCOMPLETED',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                          height: 1.3,
                        ),
                      ),
                      Icon(
                        Icons.check_box,
                        color: AppColors.success,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Text(
                      controller.totalTasksCompleted.toString(),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Total Earned Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL EARNED',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '৳',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Text(
                      controller.totalEarned.value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Assigned Location Section
  Widget _buildAssignedLocationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withAlpha(30),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(
                () => RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grey800,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'Assigned Location: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: controller.assignedLocation.value),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Services you Provide Section
  Widget _buildServicesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Services you Provide:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.servicesProvided
                    .asMap()
                    .entries
                    .map((entry) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Text(
                            '${entry.key + 1}. ${entry.value}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.grey700,
                              height: 1.4,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'These services were selected on time of the creation of your account. If you want to change, contact your assigned admin.',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.grey500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// View Profile Information Button
  Widget _buildViewProfileButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        onTap: controller.goToEditProfile,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(50),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'View Profile Information',
                  style: TextStyle(
                    fontSize: 14.sp,
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
      ),
    );
  }

  /// Logout button
  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        onTap: controller.logout,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
