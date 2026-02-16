import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../task_details_controller.dart';

/// Show Set Appointment popup as a centered dialog
Future<bool?> showSetAppointmentPopup(
  BuildContext context, {
  bool resetForm = true,
}) {
  final controller = Get.find<AgentTaskDetailsController>();
  if (resetForm) {
    controller.resetAppointmentForm();
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => const _SetAppointmentPopup(),
  );
}

class _SetAppointmentPopup extends GetView<AgentTaskDetailsController> {
  const _SetAppointmentPopup();

  // Light blue/grey color for input fields (matching design)
  static const Color _inputFieldColor = Color(0xFFEEF2F6);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Set Appointment Date & Time',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                "Once you update the status, you won't be able to change date and time later on.",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.grey500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),

              // Title field
              Text(
                'Title *',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.appointmentTitleController,
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey400,
                  ),
                  filled: true,
                  fillColor: _inputFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Date field
              Text(
                'Date *',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: () => controller.pickAppointmentDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: _inputFieldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.selectedAppointmentDate.value != null
                          ? controller.formattedAppointmentDate
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: controller.selectedAppointmentDate.value != null
                            ? AppColors.grey900
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Time field
              Text(
                'Time *',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: () => controller.pickAppointmentTime(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: _inputFieldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.selectedAppointmentTime.value != null
                          ? controller.formattedAppointmentTime
                          : 'Select time',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: controller.selectedAppointmentTime.value != null
                            ? AppColors.grey900
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Set button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.isSettingAppointment.value
                        ? null
                        : () async {
                            final success = await controller.setAppointment();
                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSettingAppointment.value
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Set Date & Time',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

/// Show Schedule Fixed Success popup as a centered dialog
Future<void> showScheduleFixedPopup(BuildContext context) {
  final controller = Get.find<AgentTaskDetailsController>();
  final task = controller.task.value;

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: 24.sp, color: AppColors.grey500),
              ),
            ),
            SizedBox(height: 8.h),

            // Success badge icon
            _SuccessBadgeIcon(size: 80.w),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Schedule Fixed',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'You can view your all appointments in\nAppointment Section',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Task info card
            if (task != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      task.serviceName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      task.serviceId,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Custom success badge icon widget (verification badge style)
class _SuccessBadgeIcon extends StatelessWidget {
  final double size;

  const _SuccessBadgeIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Use verified icon which has the badge shape
          Icon(Icons.verified, color: AppColors.success, size: size),
          // White checkmark overlay
          Icon(Icons.check, color: AppColors.white, size: size * 0.45),
        ],
      ),
    );
  }
}

/// Show Submit for Review Confirmation popup as a centered dialog
Future<bool?> showSubmitForReviewConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => const _SubmitForReviewConfirmationPopup(),
  );
}

class _SubmitForReviewConfirmationPopup
    extends GetView<AgentTaskDetailsController> {
  const _SubmitForReviewConfirmationPopup();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Are You Sure ?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "Once you submit for review, you won't be able to submit your work log later. Admin will review your submission later on.",
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.grey500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                // Yes button
                Expanded(
                  child: Obx(
                    () => SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final success = await controller
                                    .submitForReview();
                                if (success && context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSubmitting.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Cancel button
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey700,
                        side: BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
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
          ],
        ),
      ),
    );
  }
}

/// Show Submitted for Review Success popup as a centered dialog
Future<void> showSubmittedForReviewSuccessPopup(BuildContext context) {
  final controller = Get.find<AgentTaskDetailsController>();
  final task = controller.task.value;

  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Get.back(result: true); // Go back to task list
                },
                child: Icon(Icons.close, size: 24.sp, color: AppColors.grey500),
              ),
            ),
            SizedBox(height: 8.h),

            // Success badge icon
            _SuccessBadgeIcon(size: 80.w),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Submitted for Review',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Your submission will be reviewed\nby your assigned admin soon',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Task info card
            if (task != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      task.serviceName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      task.serviceId,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
