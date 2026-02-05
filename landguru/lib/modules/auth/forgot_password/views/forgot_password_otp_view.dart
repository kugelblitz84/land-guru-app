import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/otp_input_field.dart';
import '../forgot_password_controller.dart';

/// Forgot Password Step 2: Verify OTP
class ForgotPasswordOtpView extends GetView<ForgotPasswordController> {
  const ForgotPasswordOtpView({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Step Progress Indicator
                        const StepProgressIndicator(
                          currentStep: 2,
                          totalSteps: 4,
                        ),

                        SizedBox(height: 60.h),

                        // Title
                        Text(
                          'Verify Phone Number',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Subtitle with phone number
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: 'We sent a 4-digit code to ',
                              ),
                              TextSpan(
                                text: controller.formattedPhoneNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '.\nEnter it below to verify your identity',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // OTP Input Fields
                        OtpInputField(
                          length: 4,
                          controllers: controller.otpControllers,
                        ),

                        SizedBox(height: 24.h),

                        // Resend OTP
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.canResend.value
                                    ? controller.resendOtp
                                    : null,
                                child: Text(
                                  controller.canResend.value
                                      ? 'Resend'
                                      : 'Resend in ${controller.resendCountdown.value}s',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: controller.canResend.value
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Verify Button
                        Obx(
                          () => PrimaryButton(
                            text: 'Verify & Continue',
                            isLoading: controller.isLoading.value,
                            showArrow: true,
                            onPressed: controller.verifyOtp,
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
}
