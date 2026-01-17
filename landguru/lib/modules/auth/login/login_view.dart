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
      body: Stack(
        children: [
          // Background Image - Fixed at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/LoginPageImage.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Spacer for image
                SizedBox(height: 270.h),
                // White content container with rounded top corners
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 32.h),

                          // LandGuru Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'LandGuru',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

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
                              color: AppColors.black,
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
                              hintText: 'Enter you password',
                              obscureText: controller.isPasswordObscured.value,
                              onToggleVisibility:
                                  controller.togglePasswordVisibility,
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
                                "Dont' have an account? ",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Get.toNamed(AppRoutes.SIGNUP_PHONE),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
