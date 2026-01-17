import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import 'notifications_controller.dart';

/// User Notifications screen
class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () {
            final navController = Get.find<UserBottomNavController>();
            navController.backFromNotifications();
          },
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
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
            : controller.notifications.isEmpty
            ? _buildEmptyState()
            : _buildNotificationsList(),
      ),
    );
  }

  /// Build notifications list with filter tabs
  Widget _buildNotificationsList() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Obx(
            () => controller.hasUnreadNotifications
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        // Filter Tabs
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              _buildFilterTab(label: 'All', filter: NotificationFilter.all),
              SizedBox(width: 8.w),
              _buildFilterTab(
                label: 'Action Required',
                filter: NotificationFilter.actionRequired,
              ),
              SizedBox(width: 8.w),
              _buildFilterTab(
                label: 'Appointments',
                filter: NotificationFilter.appointments,
              ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: Obx(() {
            final filteredList = controller.filteredNotifications;
            if (filteredList.isEmpty) {
              return _buildFilterEmptyState();
            }
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(filteredList[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build filter tab chip
  Widget _buildFilterTab({
    required String label,
    required NotificationFilter filter,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filter;
      return GestureDetector(
        onTap: () => controller.changeFilter(filter),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.grey700,
            ),
          ),
        ),
      );
    });
  }

  /// Build notification item
  Widget _buildNotificationItem(NotificationItem notification) {
    return GestureDetector(
      onTap: () => controller.onNotificationTap(notification),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : AppColors.primary.withAlpha(13),
          border: Border(
            bottom: BorderSide(color: AppColors.grey200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: notification.iconBackgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.grey600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread indicator
                      if (!notification.isRead) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no notifications exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mail icon
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 50.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32.h),

            // Title
            Text(
              "You're all caught up",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle
            Text(
              'Check back later for updates on appointments,\nnew listings, and open houses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // Explore button
            SizedBox(
              width: 220.w,
              height: 50.h,
              child: ElevatedButton(
                onPressed: controller.goToExploreListings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Explore New Listings',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for filtered results
  Widget _buildFilterEmptyState() {
    String message;
    switch (controller.selectedFilter.value) {
      case NotificationFilter.actionRequired:
        message = 'No action required notifications';
        break;
      case NotificationFilter.appointments:
        message = 'No appointment notifications';
        break;
      default:
        message = 'No notifications';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
