import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'agent_dashboard_controller.dart';
import 'models/dashboard_models.dart';

/// Agent Dashboard/Home screen - Full version with Scaffold
/// Use this for standalone navigation (not within shell)
class AgentDashboardView extends GetView<AgentDashboardController> {
  const AgentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: const AgentDashboardContentView()),
    );
  }
}

/// Agent Dashboard content view - Content only, no Scaffold
/// Used within AgentShellWrapper for tab-based navigation
class AgentDashboardContentView extends GetView<AgentDashboardController> {
  const AgentDashboardContentView({super.key});

  // Responsive sizing constants
  static const double _horizontalPadding = 16;
  static const double _sectionSpacing = 20;
  static const double _cardBorderRadius = 10;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _horizontalPadding.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      _buildAssignedLocationCard(),
                      SizedBox(height: 12.h),
                      _buildStatsRow(),
                      SizedBox(height: _sectionSpacing.h),
                      _buildRequiresSchedulingSection(),
                      SizedBox(height: _sectionSpacing.h),
                      _buildTodaysScheduleSection(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Assigned Location Card - Blue card with location pin
  Widget _buildAssignedLocationCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withAlpha(50),
          borderRadius: BorderRadius.circular(_cardBorderRadius.r),
          border: Border.all(color: AppColors.primary.withAlpha(100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 6.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    height: 1.35,
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
          ],
        ),
      ),
    );
  }

  /// Stats Cards Row - NEW, ACTIVE, DONE
  Widget _buildStatsRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'NEW',
              count: controller.stats.value.newRequests,
              subtitle: 'Requests',
              backgroundColor: AppColors.secondary,
              textColor: AppColors.white,
              icon: Icons.description_outlined,
              onTap: controller.goToNewRequests,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _StatCard(
              label: 'ACTIVE',
              count: controller.stats.value.activeJobs,
              subtitle: 'Jobs',
              backgroundColor: AppColors.primaryLight.withAlpha(50),
              textColor: AppColors.primary,
              icon: Icons.description_outlined,
              hasBorder: true,
              borderColor: AppColors.primaryLight.withAlpha(100),
              onTap: controller.goToActiveJobs,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _StatCard(
              label: 'DONE',
              count: controller.stats.value.doneThisMonth,
              subtitle: 'In ${controller.stats.value.currentMonth}',
              backgroundColor: AppColors.successLight.withAlpha(50),
              textColor: AppColors.success,
              icon: Icons.check_box_outlined,
              hasBorder: true,
              borderColor: AppColors.success.withAlpha(100),
              onTap: controller.goToDoneJobs,
            ),
          ),
        ],
      ),
    );
  }

  /// Requires Scheduling Section
  Widget _buildRequiresSchedulingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionHeader(
          title: 'Requires Scheduling',
          actionText: 'See All',
          onActionTap: controller.viewAllRequiresScheduling,
        ),
        SizedBox(height: 10.h),
        Obx(
          () => controller.requiresScheduling.isEmpty
              ? _buildEmptyState('No tasks requiring scheduling')
              : SizedBox(
                  height: 175.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: controller.requiresScheduling.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final task = controller.requiresScheduling[index];
                      return _SchedulingCard(task: task, onViewDetails: () {});
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /// Today's Schedule Section - Timeline style
  Widget _buildTodaysScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  controller.todayDateLabel.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(
          () => controller.todaySchedule.isEmpty
              ? _buildEmptyState('No appointments scheduled for today')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: controller.todaySchedule.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == controller.todaySchedule.length - 1;
                    return _ScheduleTimelineItem(
                      item: item,
                      isLast: isLast,
                      onViewDetails: () => controller.goToScheduleDetails(item),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(_cardBorderRadius.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, size: 36.sp, color: AppColors.grey400),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXTRACTED WIDGETS - For better performance and maintainability
// ============================================================================

/// Section header with title and action button
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                actionText!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.hasBorder = false,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhiteBg = backgroundColor == AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: hasBorder
              ? Border.all(color: borderColor ?? AppColors.grey200, width: 1)
              : null,
          boxShadow: hasBorder
              ? [
                  BoxShadow(
                    color: AppColors.black.withAlpha(8),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(icon, color: textColor, size: 14.sp),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isWhiteBg ? AppColors.grey900 : textColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: isWhiteBg ? AppColors.grey600 : textColor.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scheduling card for horizontal list
class _SchedulingCard extends StatelessWidget {
  final SchedulingTask task;
  final VoidCallback onViewDetails;

  const _SchedulingCard({required this.task, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row - Badge and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'NEW REQUEST',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  task.assignedTimeAgo,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.grey500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Service Name
          Text(
            task.serviceName,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),

          // Service ID
          Text(
            task.serviceId,
            style: TextStyle(fontSize: 10.sp, color: AppColors.grey500),
          ),
          SizedBox(height: 6.h),

          // Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 12.sp, color: AppColors.grey500),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  task.location,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Accept Before
          Text(
            'Accept Before: ${task.acceptBeforeFormatted}',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // View Details Button
          SizedBox(
            width: double.infinity,
            height: 34.h,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Schedule timeline item widget
class _ScheduleTimelineItem extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;
  final VoidCallback onViewDetails;

  const _ScheduleTimelineItem({
    required this.item,
    required this.isLast,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column (Circle + Connecting Line)
          SizedBox(
            width: 24.w,
            child: Column(
              children: [
                // Blue circle indicator
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Connecting line (except for last item) - expands to fill remaining height
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.grey300),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Schedule Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.grey200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(6),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Type (Client Meeting / Site Visit)
                  Text(
                    item.type,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),

                  // Service ID
                  Text(
                    item.serviceId,
                    style: TextStyle(fontSize: 10.sp, color: AppColors.grey500),
                  ),
                  SizedBox(height: 6.h),

                  // Client Info
                  Row(
                    children: [
                      Icon(Icons.person, size: 12.sp, color: AppColors.grey500),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Client: ${item.clientName}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12.sp,
                        color: AppColors.grey500,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_up,
                        size: 16.sp,
                        color: AppColors.grey500,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    height: 34.h,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey700,
                        side: BorderSide(color: AppColors.grey300),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
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
}
