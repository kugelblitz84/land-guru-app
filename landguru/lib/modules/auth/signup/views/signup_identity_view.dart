import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../signup_controller.dart';

/// Signup Step 5: Identity verification
class SignupIdentityView extends GetView<SignupController> {
  const SignupIdentityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Step Progress Indicator with Skip button
                        Row(
                          children: [
                            Expanded(
                              child: const StepProgressIndicator(
                                currentStep: 5,
                                totalSteps: 5,
                              ),
                            ),
                          ],
                        ),

                        // Skip button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => controller.completeRegistration(skipIdentity: true),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Title
                        Text(
                          'Verify your identity',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Subtitle
                        Text(
                          'To buy or sell land securely, we need to verify your identity',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // National ID (NID) Section
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'National ID (NID)',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // NID Upload Cards
                        Row(
                          children: [
                            // Front Side
                            Expanded(
                              child: Obx(
                                () => _buildUploadCard(
                                  title: 'Front Side',
                                  subtitle: 'Tap to Upload',
                                  isUploaded: controller.nidFrontImagePath.value.isNotEmpty,
                                  onTap: controller.pickNidFrontImage,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // Back Side
                            Expanded(
                              child: Obx(
                                () => _buildUploadCard(
                                  title: 'Back Side',
                                  subtitle: 'Tap to Upload',
                                  isUploaded: controller.nidBackImagePath.value.isNotEmpty,
                                  onTap: controller.pickNidBackImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // TIN Certificate Section
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'TIN Certificate (Optional)',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // TIN Upload Card
                        Obx(
                          () => _buildTinUploadCard(
                            isUploaded: controller.tinCertificatePath.value.isNotEmpty,
                            onTap: controller.pickTinCertificate,
                          ),
                        ),

                        const Spacer(),

                        // Complete Registration Button
                        Obx(
                          () => PrimaryButton(
                            text: 'Complete Registration',
                            isLoading: controller.isLoading.value,
                            showArrow: false,
                            onPressed: () => controller.completeRegistration(),
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withAlpha(26) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withAlpha(26)
                    : AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.cloud_upload_outlined,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isUploaded ? 'Uploaded' : subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: isUploaded ? AppColors.success : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTinUploadCard({
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withAlpha(26) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withAlpha(26)
                    : AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.cloud_upload_outlined,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploaded ? 'Certificate Uploaded' : 'Tap to upload Certificate',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'PDF, JPG or PNG (Max 3MB)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
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
    );
  }
}
