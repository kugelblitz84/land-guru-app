import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../widgets/auth_widgets.dart';

/// Forgot Password Step 4: Success
class ForgotPasswordSuccessView extends StatelessWidget {
  const ForgotPasswordSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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

                        // Step Progress Indicator (completed)
                        const StepProgressIndicator(
                          currentStep: 4,
                          totalSteps: 4,
                        ),

                        const Spacer(flex: 2),

                        // Success Icon
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 80.sp,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Title
                        Text(
                          'Password Reset\nSuccessful!',
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
                        Text(
                          'Your password has been changed successfully.\nYou can now login with your new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Go to Login Button
                        PrimaryButton(
                          text: 'Go to Login',
                          isLoading: false,
                          showArrow: false,
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
}
