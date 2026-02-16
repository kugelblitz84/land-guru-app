import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/task_models.dart';
import '../my_tasks_controller.dart';

/// In Review Tasks tab content - shows tasks submitted for review
class InReviewTasksView extends GetView<AgentMyTasksController> {
  const InReviewTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.getFilteredTasksForTab(2);

      if (tasks.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with task count
          _buildHeader(tasks.length),
          SizedBox(height: 8.h),

          // Service type filter
          _buildServiceTypeFilter(),
          SizedBox(height: 12.h),

          // Task list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: tasks
                  .map((task) => _buildInReviewTaskCard(task))
                  .toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader(int taskCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Showing $taskCount Tasks',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
    );
  }

  Widget _buildServiceTypeFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: controller.showServiceTypeFilter,
        child: Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Service Type: ',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                ),
                Text(
                  controller.serviceTypeFilter.value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInReviewTaskCard(AgentTask task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name
          Text(
            task.serviceName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),

          // Service ID
          Text(
            task.serviceId,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
          ),
          SizedBox(height: 4.h),

          // Client info row
          Row(
            children: [
              Icon(Icons.person, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Client: ',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
              ),
              Text(
                task.clientName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Time ago
          Text(
            _getTimeAgo(task.assignedAt),
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
          ),
          SizedBox(height: 12.h),

          // View Details button (outlined style)
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: OutlinedButton(
              onPressed: () => controller.goToTaskDetails(task),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey700,
                side: BorderSide(color: AppColors.grey300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get time ago string without "Assigned:" prefix
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_outlined, size: 64.sp, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              'No tasks in review',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Submitted tasks will appear here',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
