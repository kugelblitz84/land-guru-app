import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_widgets.dart';
import 'login_controller.dart';

/// Login screen view
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient placeholder
            Container(
              height: 280.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.primary.withAlpha(180),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50.h,
                    right: -50.w,
                    child: Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withAlpha(26),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20.h,
                    left: -30.w,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withAlpha(20),
                      ),
                    ),
                  ),
                  // House icon
                  Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 100.sp,
                      color: AppColors.white.withAlpha(180),
                    ),
                  ),
                  // Bottom fade
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.white],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // LandGuru Badge
                    Transform.translate(
                      offset: Offset(0, -30.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'LandGuru',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Welcome Text
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your phone number to access exclusive\nproperty listings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),

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
                    SizedBox(height: 16.h),

                    // Password Field
                    Obx(
                      () => PasswordField(
                        controller: controller.passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        obscureText: controller.isPasswordObscured.value,
                        onToggleVisibility: controller.togglePasswordVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.FORGOT_PASSWORD_PHONE),
                        child: Text(
                          'Forgot password ?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Login Button
                    Obx(
                      () => PrimaryButton(
                        text: 'Login',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.login,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.SIGNUP_PHONE),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
