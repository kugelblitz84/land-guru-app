import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/theme/app_colors.dart';
import 'appointments_controller.dart';
import 'models/appointment_models.dart';

/// User Appointments screen with tabs - Full version with Scaffold
class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: AppointmentsContentView()),
    );
  }
}

/// Appointments content view - Content only, no Scaffold
/// Used within MainShellWrapper for tab-based navigation
class AppointmentsContentView extends StatelessWidget {
  const AppointmentsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<AppointmentsController>()) {
      Get.put(AppointmentsController());
    }
    final controller = Get.find<AppointmentsController>();

    return DefaultTabController(
      length: 2,
      initialIndex: controller.selectedTab.value == AppointmentTabs.upcoming
          ? 0
          : 1,
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildPrimaryTabs(controller),
          SizedBox(height: 16.h),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTabContent(controller),
                _buildTabContent(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppointmentsController controller) {
    return Column(
      children: [
        _buildSecondaryFilters(controller),
        SizedBox(height: 16.h),
        _buildSectionHeader(controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final appointments = controller.filteredAppointments;

            return LayoutBuilder(
              builder: (context, constraints) {
                if (appointments.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: _buildEmptyState(controller),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(
                        controller,
                        appointments[index],
                      );
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPrimaryTabs(AppointmentsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TabBar(
          onTap: (index) => controller.changeTab(
            index == 0 ? AppointmentTabs.upcoming : AppointmentTabs.past,
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(6.w),
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.grey600,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryFilters(AppointmentsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() {
        if (controller.selectedTab.value == AppointmentTabs.upcoming) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'My Requests',
                  isSelected:
                      controller.upcomingFilter.value ==
                      UpcomingFilters.myRequests,
                  onTap: () => controller.changeUpcomingFilter(
                    UpcomingFilters.myRequests,
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  label: 'Upcoming Visit',
                  isSelected:
                      controller.upcomingFilter.value ==
                      UpcomingFilters.upcomingVisit,
                  onTap: () => controller.changeUpcomingFilter(
                    UpcomingFilters.upcomingVisit,
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  label: 'Agent Visit',
                  isSelected:
                      controller.upcomingFilter.value ==
                      UpcomingFilters.agentVisit,
                  onTap: () => controller.changeUpcomingFilter(
                    UpcomingFilters.agentVisit,
                  ),
                  badgeCount: controller.agentVisitBadgeCount,
                ),
              ],
            ),
          );
        } else {
          // Past tab filters - left aligned
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFilterChip(
                label: 'My Visit',
                isSelected: controller.pastFilter.value == PastFilters.myVisit,
                onTap: () => controller.changePastFilter(PastFilters.myVisit),
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                label: 'Agent Visit',
                isSelected:
                    controller.pastFilter.value == PastFilters.agentVisit,
                onTap: () =>
                    controller.changePastFilter(PastFilters.agentVisit),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          // border: Border.all(
          //   color: isSelected ? AppColors.primary : AppColors.grey300,
          // ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.grey600,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : AppColors.error,
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

  Widget _buildSectionHeader(AppointmentsController controller) {
    return Obx(() {
      final isUpcomingVisitsHeader =
          controller.selectedTab.value == AppointmentTabs.upcoming &&
          controller.upcomingFilter.value == UpcomingFilters.upcomingVisit;
      final horizontalPadding = isUpcomingVisitsHeader ? 16.w : 12.w;

      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: _buildSectionHeaderContent(controller),
        ),
      );
    });
  }

  Widget _buildSectionHeaderContent(AppointmentsController controller) {
    final title = controller.sectionTitle;
    final subtitle = controller.sectionSubtitle;
    final showResultsHeader =
        controller.selectedTab.value == AppointmentTabs.upcoming &&
            controller.upcomingFilter.value == UpcomingFilters.upcomingVisit ||
        controller.selectedTab.value == AppointmentTabs.past;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
          SizedBox(height: 8.h),
        ],
        if (showResultsHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${controller.filteredAppointments.length} Properties',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Date',
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
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildAppointmentCard(
    AppointmentsController controller,
    Appointment appointment,
  ) {
    // Determine card type based on current filter
    final isMyRequests =
        controller.selectedTab.value == AppointmentTabs.upcoming &&
        controller.upcomingFilter.value == UpcomingFilters.myRequests;

    if (isMyRequests) {
      return _buildMyRequestCard(controller, appointment);
    } else {
      return _buildVisitCard(controller, appointment);
    }
  }

  /// Card for "My Requests" filter - Square image style
  Widget _buildMyRequestCard(
    AppointmentsController controller,
    Appointment appointment,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Property image (square)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: appointment.propertyImageUrl != null
                ? Image.asset(
                    appointment.propertyImageUrl!,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder(
                        appointment.propertyType,
                        false,
                      );
                    },
                  )
                : _buildImagePlaceholder(appointment.propertyType, false),
          ),
          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.propertyTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  appointment.postId,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Price: ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      '৳ ${appointment.price}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _buildTag(
                      text: appointment.propertyTypeLabel,
                      backgroundColor: appointment.propertyTypeColor,
                      textColor: AppColors.white,
                    ),
                    _buildTag(
                      text: AppointmentStatuses.label(appointment.status),
                      backgroundColor: AppointmentStatuses.backgroundColor(
                        appointment.status,
                      ),
                      textColor: AppointmentStatuses.textColor(
                        appointment.status,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Requested: ${appointment.requestedTimeAgo}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),

          // Arrow
          Icon(Icons.chevron_right, color: AppColors.grey400, size: 24.sp),
        ],
      ),
    );
  }

  /// Card for Upcoming/Past Visits - Date box + details (no image)
  Widget _buildVisitCard(
    AppointmentsController controller,
    Appointment appointment,
  ) {
    final isAgentVisit = appointment.agentName != null;
    final showArrow = isAgentVisit;

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
              // Date box with light blue background - matches card height
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

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    Text(
                      appointment.postId,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                    SizedBox(height: 4.h),
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
                          text: AppointmentStatuses.label(appointment.status),
                          backgroundColor: AppointmentStatuses.backgroundColor(
                            appointment.status,
                          ),
                          textColor: AppointmentStatuses.textColor(
                            appointment.status,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Show location for my visits, service type for agent visits
                    if (isAgentVisit) ...[
                      Text(
                        'SERVICE TYPE: ${appointment.serviceType}',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: AppColors.grey600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Agent: ${appointment.agentName}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ] else ...[
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
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Client: ',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            appointment.clientName ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow (only for agent visits)
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey400,
                  size: 20.sp,
                ),
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
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

  Widget _buildImagePlaceholder(PropertyType propertyType, bool isCircular) {
    Color color1, color2;
    IconData icon;

    switch (propertyType) {
      case PropertyType.plainLand:
        color1 = const Color(0xFF8BC34A);
        color2 = const Color(0xFF689F38);
        icon = Icons.landscape;
        break;
      case PropertyType.waterLand:
        color1 = const Color(0xFF4FC3F7);
        color2 = const Color(0xFF0288D1);
        icon = Icons.water;
        break;
      case PropertyType.flat:
        color1 = const Color(0xFF90CAF9);
        color2 = const Color(0xFF42A5F5);
        icon = Icons.apartment;
        break;
    }

    if (isCircular) {
      return Container(
        width: 65.w,
        height: 65.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
        ),
        child: Center(
          child: Icon(icon, size: 26.sp, color: AppColors.white.withAlpha(180)),
        ),
      );
    }

    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(icon, size: 32.sp, color: AppColors.white.withAlpha(180)),
      ),
    );
  }

  Widget _buildEmptyState(AppointmentsController controller) {
    String message = 'No appointments found';
    IconData icon = Icons.event_busy;

    if (controller.selectedTab.value == AppointmentTabs.upcoming) {
      switch (controller.upcomingFilter.value) {
        case UpcomingFilters.myRequests:
          message = 'No visit requests yet';
          icon = Icons.pending_actions;
          break;
        case UpcomingFilters.upcomingVisit:
          message = 'No upcoming visits scheduled';
          icon = Icons.calendar_today;
          break;
        case UpcomingFilters.agentVisit:
          message = 'No agent visits scheduled';
          icon = Icons.person_search;
          break;
        default:
          message = 'No upcoming appointments';
          icon = Icons.calendar_month;
          break;
      }
    } else {
      message = 'No past visits';
      icon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
