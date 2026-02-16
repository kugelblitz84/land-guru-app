import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'my_tasks_controller.dart';
import 'views/new_tasks_view.dart';
import 'views/active_tasks_view.dart';
import 'views/in_review_tasks_view.dart';
import 'views/done_tasks_view.dart';

/// Agent My Tasks screen - Full version with Scaffold
class AgentMyTasksView extends GetView<AgentMyTasksController> {
  const AgentMyTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: AgentMyTasksContentView()),
    );
  }
}

/// Agent My Tasks content view - Content only, no Scaffold
/// Used within AgentShellWrapper for tab-based navigation
class AgentMyTasksContentView extends GetView<AgentMyTasksController> {
  const AgentMyTasksContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar and filter
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              SizedBox(width: 12.w),
              _buildFilterButton(),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Tab bar
        _buildTabBar(),
        SizedBox(height: 12.h),

        // Content based on selected tab
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 120) {
                    controller.loadMoreCurrentTabIfNeeded();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Assigned location info (shown on all tabs)
                      _buildAssignedLocationInfo(),
                      SizedBox(height: 12.h),

                      // Tab content
                      _buildTabContent(),
                      if (controller.isLoadingMore.value)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build content based on selected tab
  Widget _buildTabContent() {
    switch (controller.selectedTabIndex.value) {
      case 0:
        return const NewTasksView();
      case 1:
        return const ActiveTasksView();
      case 2:
        return const InReviewTasksView();
      case 3:
        return const DoneTasksView();
      default:
        return const NewTasksView();
    }
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: controller.showServiceTypeFilter,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.tune, color: AppColors.grey700, size: 22.sp),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.grey500, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search client, el...',
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
            ),
          ),
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return GestureDetector(
                onTap: controller.clearSearch,
                child: Icon(Icons.close, color: AppColors.grey500, size: 20.sp),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _buildTab(0, 'New', controller.newTasksCount),
            SizedBox(width: 16.w),
            _buildTab(1, 'Active', null),
            SizedBox(width: 16.w),
            _buildTab(2, 'In Review', null),
            SizedBox(width: 16.w),
            _buildTab(3, 'Done', null),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, int? badgeCount) {
    final isSelected = controller.selectedTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.grey600,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedLocationInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Assigned Location: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      TextSpan(
                        text: controller.assignedLocation.value.isNotEmpty
                            ? controller.assignedLocation.value
                            : 'Not assigned',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
