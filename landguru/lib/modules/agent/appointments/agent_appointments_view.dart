import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'agent_appointments_controller.dart';
import 'models/appointments_model.dart';

/// Agent Appointments screen - Full version with Scaffold
class AgentAppointmentsView extends GetView<AgentAppointmentsController> {
  const AgentAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: AgentAppointmentsContentView()),
    );
  }
}

/// Agent Appointments content view - Content only, no Scaffold
/// Used within AgentShellWrapper for tab-based navigation
class AgentAppointmentsContentView
    extends GetView<AgentAppointmentsController> {
  const AgentAppointmentsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        _buildTabBar(),
        SizedBox(height: 12.h),

        // Content
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
                    controller.loadMoreAppointmentsIfNeeded();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Sort button
                      _buildSortButton(),
                      SizedBox(height: 12.h),

                      // Appointments list
                      _buildAppointmentsList(),
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

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Row(
            children: [
              _buildTabButton(
                label: 'Upcoming',
                isSelected:
                    controller.selectedTab.value ==
                    AgentAppointmentTabs.upcoming,
                onTap: () =>
                    controller.changeTab(AgentAppointmentTabs.upcoming),
              ),
              _buildTabButton(
                label: 'Past',
                isSelected:
                    controller.selectedTab.value == AgentAppointmentTabs.past,
                onTap: () => controller.changeTab(AgentAppointmentTabs.past),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.grey600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(
            () => PopupMenuButton<String>(
              onSelected: controller.changeSortBy,
              offset: Offset(0, 30.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              itemBuilder: (context) {
                return controller.sortOptions.map((option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.sortBy.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_downward,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Obx(() {
      final appointments = controller.filteredAppointments;

      if (appointments.isEmpty) {
        return _buildEmptyState();
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: appointments
              .map((appointment) => _buildAppointmentCard(appointment))
              .toList(),
        ),
      );
    });
  }

  Widget _buildAppointmentCard(AgentAppointment appointment) {
    return GestureDetector(
      onTap: () => controller.goToAppointmentDetails(appointment),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey300, width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date box with light blue background
              Container(
                width: 65.w,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appointment.formattedMonth,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      appointment.formattedDay,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Details section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Property title
                    Text(
                      appointment.propertyTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),

                    // Post ID
                    Text(
                      appointment.postId,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Tags row
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 3.h,
                      children: [
                        _buildTag(
                          text: appointment.propertyTypeLabel,
                          backgroundColor: appointment.propertyTypeColor,
                          textColor: AppColors.white,
                        ),
                        _buildTag(
                          text: AgentAppointmentStatuses.label(
                            appointment.status,
                          ),
                          backgroundColor:
                              AgentAppointmentStatuses.backgroundColor(
                                appointment.status,
                              ),
                          textColor: AgentAppointmentStatuses.textColor(
                            appointment.status,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Location
                    Text(
                      appointment.location,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.grey600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),

                    // Service type
                    Text(
                      'SERVICE TYPE: ${appointment.serviceType}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: AppColors.grey400, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
            Icon(
              Icons.calendar_today_outlined,
              size: 64.sp,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              controller.selectedTab.value == AgentAppointmentTabs.upcoming
                  ? 'No upcoming appointments'
                  : 'No past appointments',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your appointments will appear here',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
