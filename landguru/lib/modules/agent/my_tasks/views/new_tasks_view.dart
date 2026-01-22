import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/task_models.dart';
import '../my_tasks_controller.dart';

/// New Tasks tab content - shows new task requests awaiting acceptance
class NewTasksView extends GetView<AgentMyTasksController> {
  const NewTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.newTasks;

      if (tasks.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service type filter
          _buildServiceTypeFilter(),
          SizedBox(height: 12.h),

          // Task list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: tasks.map((task) => _buildNewTaskCard(task)).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildServiceTypeFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          // TODO: Implement filter functionality
        },
        child: Obx(
          () => Row(
            children: [
              Text(
                'Service Type: ',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
              ),
              Text(
                controller.serviceTypeFilter.value,
                style: TextStyle(
                  fontSize: 14.sp,
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
    );
  }

  Widget _buildNewTaskCard(AgentTask task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with status badge and time
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: task.status.backgroundColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    task.status.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: task.status.textColor,
                    ),
                  ),
                ),
                // Assigned time
                Text(
                  task.assignedTimeAgo,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),

          // Service name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              task.serviceName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ),

          // Service ID
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              task.serviceId,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
          ),
          SizedBox(height: 8.h),

          // Client info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Icon(Icons.person, size: 16.sp, color: AppColors.secondary),
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
          ),
          SizedBox(height: 4.h),

          // Location
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16.sp, color: AppColors.grey500),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    task.location,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Accept before deadline
          if (task.acceptBefore != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Accept Before: ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: task.acceptBeforeFormatted,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ] else
            SizedBox(height: 4.h),

          // View Details button
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: () => controller.goToTaskDetails(task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.sp, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              'No new tasks',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'New task requests will appear here',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
