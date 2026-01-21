import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'change_password_controller.dart';

/// Change Password screen
class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

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
          'Change Password',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Description
              Text(
                'Keep your account secure by regularly updating your password.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grey600,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 32.h),

              // Current Password
              _buildLabel('Current Password', isRequired: true),
              SizedBox(height: 8.h),
              Obx(
                () => _buildPasswordField(
                  controller: controller.currentPasswordController,
                  hintText: 'Enter current password',
                  obscureText: !controller.showCurrentPassword.value,
                  onToggleVisibility:
                      controller.toggleCurrentPasswordVisibility,
                  validator: controller.validateCurrentPassword,
                ),
              ),

              SizedBox(height: 24.h),

              // New Password
              _buildLabel('Set New Password', isRequired: true),
              SizedBox(height: 8.h),
              Obx(
                () => _buildPasswordField(
                  controller: controller.newPasswordController,
                  hintText: 'Atleast 8 characters minimum',
                  obscureText: !controller.showNewPassword.value,
                  onToggleVisibility: controller.toggleNewPasswordVisibility,
                  validator: controller.validateNewPassword,
                ),
              ),

              SizedBox(height: 24.h),

              // Confirm Password
              _buildLabel('Confirm Password', isRequired: true),
              SizedBox(height: 8.h),
              Obx(
                () => _buildPasswordField(
                  controller: controller.confirmPasswordController,
                  hintText: 'Re-enter password',
                  obscureText: !controller.showConfirmPassword.value,
                  onToggleVisibility:
                      controller.toggleConfirmPasswordVisibility,
                  validator: controller.validateConfirmPassword,
                ),
              ),

              const Spacer(),

              // Update Password Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      disabledBackgroundColor: AppColors.primary.withAlpha(150),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Forgot Password Link
              Center(
                child: GestureDetector(
                  onTap: controller.goToForgotPassword,
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey900,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(fontSize: 14.sp, color: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.grey400,
            size: 22.sp,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
    );
  }
}
