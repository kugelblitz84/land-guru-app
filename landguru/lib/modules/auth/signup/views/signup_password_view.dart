import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../signup_controller.dart';

/// Signup Step 3: Set password
class SignupPasswordView extends GetView<SignupController> {
  const SignupPasswordView({super.key});

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
                      key: controller.passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Step Progress Indicator
                          const StepProgressIndicator(
                            currentStep: 3,
                            totalSteps: 5,
                          ),

                          SizedBox(height: 60.h),

                          // Title
                          Text(
                            'Set password',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Subtitle
                          Text(
                            'To make your account secure, you need to enter a password.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Set New Password Field
                          Obx(
                            () => PasswordField(
                              controller: controller.passwordController,
                              label: 'Set New Password *',
                              hintText: 'Atleast 8 characters minimum',
                              obscureText: controller.isPasswordObscured.value,
                              onToggleVisibility:
                                  controller.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Confirm Password Field
                          Obx(
                            () => PasswordField(
                              controller: controller.confirmPasswordController,
                              label: 'Confirm Password *',
                              hintText: 'Re-enter password',
                              obscureText:
                                  controller.isConfirmPasswordObscured.value,
                              onToggleVisibility:
                                  controller.toggleConfirmPasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value !=
                                    controller.passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),

                          const Spacer(),

                          // Next Button
                          Obx(
                            () => PrimaryButton(
                              text: 'Next',
                              isLoading: controller.isLoading.value,
                              showArrow: true,
                              onPressed: controller.setPassword,
                            ),
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
