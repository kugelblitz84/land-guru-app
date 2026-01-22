import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../widgets/auth_widgets.dart';

/// Forgot Password - Agent Request Sent (Step 2 of 2)
/// Displayed when an agent submits a password reset request
/// Admin will review and contact the agent
class ForgotPasswordAgentRequestSentView extends StatelessWidget {
  const ForgotPasswordAgentRequestSentView({super.key});

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
          'Forgot Password',
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
                      children: [
                        SizedBox(height: 16.h),

                        // Step Progress Indicator (Step 2 of 2 for Agent)
                        const StepProgressIndicator(
                          currentStep: 2,
                          totalSteps: 2,
                        ),

                        const Spacer(flex: 2),

                        // Success Badge Icon (Green checkmark badge)
                        _buildSuccessBadge(),
                        SizedBox(height: 32.h),

                        // Title
                        Text(
                          'Password Reset\nRequest Sent',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'Your designated admin will review your request and contact with you soon.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Back to Login Button
                        PrimaryButton(
                          text: 'Back to Login',
                          isLoading: false,
                          showArrow: true,
                          onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
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

  /// Build the green badge with checkmark icon
  Widget _buildSuccessBadge() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main checkmark icon
          Icon(Icons.check, size: 50.sp, color: AppColors.white),
          // Small badge circle at bottom right
          // Positioned(
          //   bottom: 8.h,
          //   right: 8.w,
          //   child: Container(
          //     width: 20.w,
          //     height: 20.h,
          //     decoration: BoxDecoration(
          //       color: AppColors.white,
          //       shape: BoxShape.circle,
          //       border: Border.all(color: AppColors.success, width: 2),
          //     ),
          //     child: Icon(Icons.check, size: 12.sp, color: AppColors.success),
          //   ),
          // ),
        ],
      ),
    );
  }
}
