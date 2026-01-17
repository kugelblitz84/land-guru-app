import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../widgets/auth_widgets.dart';
import '../signup_controller.dart';

/// Signup Step 1: Enter phone number
class SignupPhoneView extends GetView<SignupController> {
  const SignupPhoneView({super.key});

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
                    child: Form(
                      key: controller.phoneFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Step Progress Indicator
                          const StepProgressIndicator(
                            currentStep: 1,
                            totalSteps: 5,
                          ),

                          SizedBox(height: 60.h),

                          // Title
                          Text(
                            "What's your phone number?",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Subtitle
                          Text(
                            'We need your mobile number to verify your identity and secure your property listings',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 40.h),

                          // Phone Number Field
                          PhoneNumberField(
                            controller: controller.phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          const Spacer(),

                          // Get OTP Button
                          Obx(
                            () => PrimaryButton(
                              text: 'Get OTP',
                              isLoading: controller.isLoading.value,
                              showArrow: false,
                              onPressed: controller.sendOtp,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Already have account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.offNamed(AppRoutes.LOGIN),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
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
