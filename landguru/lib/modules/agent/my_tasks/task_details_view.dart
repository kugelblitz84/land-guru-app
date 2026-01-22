import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/enums/land_unit.dart';
import '../../user/properties/widgets/metrics_conversion_row.dart';
import '../../user/properties/property_details/widgets/property_details_widgets.dart';
import 'models/task_models.dart';
import 'task_details_controller.dart';
import 'widgets/task_details_popups.dart';

/// Unified Task Details View
/// Shows task details for all states: New, Active, In Review, Done
/// The UI elements react based on the task's current status
class AgentTaskDetailsView extends GetView<AgentTaskDetailsController> {
  const AgentTaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.task.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final task = controller.task.value;
        if (task == null) {
          return const Center(child: Text('Task not found'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    // Service Info Card
                    _buildServiceInfoCard(task),
                    SizedBox(height: 20.h),

                    // Task Status Section
                    _buildTaskStatusSection(task),
                    SizedBox(height: 20.h),

                    // Assigned Service Fee
                    _buildServiceFeeSection(task),
                    SizedBox(height: 20.h),

                    // Appointment Section
                    _buildAppointmentSection(task),
                    SizedBox(height: 20.h),

                    // Property & Client Info
                    _buildPropertyClientInfoSection(task),
                    SizedBox(height: 24.h),

                    // Work Log Section (for active/in-review/done tasks)
                    if (!controller.isNewTask) ...[
                      _buildWorkLogSection(task),
                      SizedBox(height: 24.h),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Button (based on task status)
            if (controller.shouldShowBottomButton) _buildBottomButton(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.grey900, size: 24.sp),
        onPressed: controller.goBack,
      ),
      title: Text(
        'Task Details',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildServiceInfoCard(AgentTask task) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SERVICE TYPE label
          Text(
            'SERVICE TYPE',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),

          // Service Name
          Text(
            task.serviceName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 2.h),

          // Service ID
          Text(
            task.serviceId,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
          ),
          SizedBox(height: 10.h),

          // Status badges row
          Row(
            children: [
              // Task status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
              SizedBox(width: 8.w),

              // Acceptance status badge (only for new tasks)
              if (controller.isNewTask)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: task.acceptanceStatus.backgroundColor,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: task.acceptanceStatus.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    task.acceptanceStatus.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: task.acceptanceStatus.textColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          // Accept Before date (for new tasks)
          if (controller.isNewTask && task.acceptBefore != null) ...[
            Text(
              'Accept Before: ${task.acceptBeforeFormatted}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 4.h),
          ],

          // Time ago
          Text(
            controller.assignedTimeAgo,
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusSection(AgentTask task) {
    // For Done tasks, show only "Completed" status
    if (controller.isDoneTask) {
      return _buildCompletedStatusSection();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Status',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey300,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStep(
                  icon: Icons.check,
                  label: 'Accepted',
                  status: TaskProcessingStatus.accepted,
                  currentStatus: controller.processingStatus,
                ),
                _buildStatusStep(
                  icon: Icons.sync,
                  label: 'Processing',
                  status: TaskProcessingStatus.processing,
                  currentStatus: controller.processingStatus,
                ),
                _buildStatusStep(
                  icon: Icons.description_outlined,
                  label: 'In Review',
                  status: TaskProcessingStatus.inReview,
                  currentStatus: controller.processingStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build completed status section for Done tasks
  Widget _buildCompletedStatusSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Status',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey300,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Completed checkmark
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.white, size: 28.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String label,
    required TaskProcessingStatus status,
    required TaskProcessingStatus currentStatus,
  }) {
    final bool isCompleted = status.isCompleted(currentStatus);
    final bool isActive = status.isActive(currentStatus);
    final bool isNewTask = controller.isNewTask;

    // For new tasks, all steps are inactive/grey
    Color circleColor;
    Color iconColor;
    Color textColor;

    if (isNewTask) {
      circleColor = AppColors.grey200;
      iconColor = AppColors.grey400;
      textColor = AppColors.grey400;
    } else if (isCompleted) {
      circleColor = AppColors.success;
      iconColor = AppColors.white;
      textColor = AppColors.grey900;
    } else if (isActive) {
      circleColor = AppColors.primary;
      iconColor = AppColors.white;
      textColor = AppColors.grey900;
    } else {
      circleColor = AppColors.grey200;
      iconColor = AppColors.grey400;
      textColor = AppColors.grey400;
    }

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeeSection(AgentTask task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Service Fee',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '৳ ${task.serviceFee.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection(AgentTask task) {
    final hasAppointment = task.appointment != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment (Optional)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: hasAppointment
                ? _buildScheduledAppointment(task.appointment!)
                : _buildUnscheduledAppointment(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnscheduledAppointment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Not Scheduled',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            color: AppColors.grey600,
          ),
        ),
        GestureDetector(
          onTap: () async {
            final result = await showSetAppointmentPopup(Get.context!);
            if (result == true) {
              await showScheduleFixedPopup(Get.context!);
            }
          },
          child: Text(
            'Set Date & Time',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledAppointment(TaskAppointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment type
        Text(
          appointment.type,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 4.h),

        // Date and time
        Text(
          appointment.formattedDateTime,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),

        // Status badge and reschedule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: appointment.status.backgroundColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                appointment.status.label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: appointment.status.textColor,
                ),
              ),
            ),

            // Reschedule link (only for upcoming)
            if (appointment.status == AppointmentStatus.upcoming ||
                appointment.status == AppointmentStatus.visited)
              GestureDetector(
                onTap: () async {
                  controller.rescheduleAppointment();
                  final result = await showSetAppointmentPopup(Get.context!);
                  if (result == true) {
                    await showScheduleFixedPopup(Get.context!);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'RESCHEDULE ?',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyClientInfoSection(AgentTask task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property & Client Info',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 12.h),

          // Client Info Card
          _buildClientInfoCard(task),
          SizedBox(height: 16.h),

          // Property Type
          PropertyDetailRow(
            icon: Icons.home,
            iconColor: AppColors.primary,
            label: 'Property Type',
            value: task.propertyType.label,
          ),
          SizedBox(height: 16.h),

          // Sellable Land Amount - with ChangeMetricsPopup
          Obx(() {
            final conversions = controller.getAllConversions(
              task.sellableLandAmount ?? 0,
            );
            final convertedValue = controller.getConvertedLandAmount(
              task.sellableLandAmount ?? 0,
            );
            final currentUnit = controller.selectedLandUnit.value.label;

            final conversionsMap = <String, double>{};
            conversions.forEach((unit, value) {
              if (unit.label != currentUnit) {
                conversionsMap[unit.label] = value;
              }
            });

            return PropertyDetailRowWithAction(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Sellable Land Amount',
              value: convertedValue,
              actionWidget: ChangeMetricsPopup(
                selectedUnit: controller.selectedLandUnit.value,
                onUnitChanged: (unit) {
                  controller.selectedLandUnit.value = unit;
                },
              ),
              conversions: conversionsMap,
              currentUnit: currentUnit,
            );
          }),
          SizedBox(height: 16.h),

          // Plot Size - with ChangeMetricsPopup
          Obx(() {
            final conversions = controller.getAllConversions(
              task.plotSize ?? 0,
            );
            final convertedValue = controller.getConvertedLandAmount(
              task.plotSize ?? 0,
            );
            final currentUnit = controller.selectedLandUnit.value.label;

            final conversionsMap = <String, double>{};
            conversions.forEach((unit, value) {
              if (unit.label != currentUnit) {
                conversionsMap[unit.label] = value;
              }
            });

            return PropertyDetailRowWithAction(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Plot Size',
              value: convertedValue,
              actionWidget: ChangeMetricsPopup(
                selectedUnit: controller.selectedLandUnit.value,
                onUnitChanged: (unit) {
                  controller.selectedLandUnit.value = unit;
                },
              ),
              conversions: conversionsMap,
              currentUnit: currentUnit,
            );
          }),
          SizedBox(height: 16.h),

          // Distance from Road
          PropertyDetailRow(
            imageAsset: 'assets/Logos/DistanceFromRoad.png',
            label: 'Distance from Road',
            value: task.distanceFromRoad ?? '-',
          ),
          SizedBox(height: 16.h),

          // Location
          PropertyDetailRow(
            icon: Icons.location_on,
            iconColor: AppColors.primary,
            label: 'Location',
            value: task.location,
          ),
          SizedBox(height: 16.h),

          // Property Photos
          _buildPropertyPhotosSection(task),
          SizedBox(height: 16.h),

          // Raw Documents
          _buildRawDocumentsSection(task),
        ],
      ),
    );
  }

  Widget _buildClientInfoCard(AgentTask task) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25.r,
            backgroundColor: AppColors.grey200,
            backgroundImage: task.clientImageUrl != null
                ? AssetImage(task.clientImageUrl!)
                : null,
            child: task.clientImageUrl == null
                ? Icon(Icons.person, color: AppColors.grey400, size: 24.sp)
                : null,
          ),
          SizedBox(width: 12.w),

          // Name and Verified badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.clientName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              if (task.isClientVerified) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 10.sp,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPhotosSection(AgentTask task) {
    if (task.propertyPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Property Photos',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: task.propertyPhotos.length > 3
                ? 4
                : task.propertyPhotos.length,
            itemBuilder: (context, index) {
              if (index == 3 && task.propertyPhotos.length > 3) {
                // More indicator
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Center(
                    child: Text(
                      '+${task.propertyPhotos.length - 3}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                );
              }

              return Container(
                width: 80.w,
                margin: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    task.propertyPhotos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey200,
                        child: Icon(
                          Icons.image,
                          color: AppColors.grey400,
                          size: 32.sp,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRawDocumentsSection(AgentTask task) {
    if (task.rawDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Raw Documents',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            Text(
              ' (From Client)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: task.rawDocuments.length,
            itemBuilder: (context, index) {
              final doc = task.rawDocuments[index];
              return _buildDocumentCard(doc);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(TaskDocument document) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 2,
            child: Container(
              constraints: BoxConstraints(maxWidth: 36.w, maxHeight: 36.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Flexible(
            flex: 1,
            child: Text(
              document.name,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            document.size,
            style: TextStyle(fontSize: 8.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkLogSection(AgentTask task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Log',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 16.h),

          // Work log entries
          Obx(() {
            final workLog = controller.task.value?.workLog ?? [];
            return Column(
              children: workLog
                  .map((entry) => _buildWorkLogEntry(entry))
                  .toList(),
            );
          }),

          // Add remark section (only for active tasks)
          if (controller.isActiveTask) ...[
            SizedBox(height: 16.h),
            _buildAddRemarkSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkLogEntry(WorkLogEntry entry) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Column(
            children: [
              Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(width: 2.w, height: 40.h, color: AppColors.grey300),
            ],
          ),
          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp
                Text(
                  entry.formattedTime,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey500,
                  ),
                ),
                SizedBox(height: 4.h),

                // Description
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),

                // Attachment (if any)
                if (entry.attachment != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.attachment!.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey900,
                              ),
                            ),
                            Text(
                              entry.attachment!.size,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRemarkSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          // Text input
          TextField(
            controller: controller.remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add Remark',
              hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.grey400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 12.h),

          // Attach and Post button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Attach button
              GestureDetector(
                onTap: controller.uploadDocument,
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 18.sp,
                      color: AppColors.grey500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Attach',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),

              // Post Update button
              Obx(
                () => SizedBox(
                  height: 36.h,
                  child: ElevatedButton(
                    onPressed: controller.isPostingRemark.value
                        ? null
                        : controller.postRemark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: controller.isPostingRemark.value
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Post Update',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward, size: 14.sp),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Helper text for active tasks
            if (controller.isActiveTask) ...[
              Text(
                'If task is completed, submit it for review.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
              SizedBox(height: 12.h),
            ],

            // Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isButtonLoading
                      ? null
                      : controller.isNewTask
                      ? controller.acceptTask
                      : _onSubmitForReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isButtonLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.isNewTask
                              ? 'Accept Task'
                              : 'Submit for Review',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isButtonLoading =>
      controller.isAccepting.value || controller.isSubmitting.value;

  Future<void> _onSubmitForReview() async {
    final confirmed = await showSubmitForReviewConfirmation(Get.context!);
    if (confirmed == true) {
      await showSubmittedForReviewSuccessPopup(Get.context!);
    }
  }
}
