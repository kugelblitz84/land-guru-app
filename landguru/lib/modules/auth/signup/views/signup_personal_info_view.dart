import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../signup_controller.dart';

/// Signup Step 4: Personal information
class SignupPersonalInfoView extends GetView<SignupController> {
  const SignupPersonalInfoView({super.key});

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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.personalInfoFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Step Progress Indicator
                  const StepProgressIndicator(currentStep: 4, totalSteps: 5),

                  SizedBox(height: 24.h),

                  // Title
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    'Please fill up your details to create your account.',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
                  ),
                  SizedBox(height: 24.h),

                  // Profile Photo Upload
                  Center(
                    child: GestureDetector(
                      onTap: controller.pickProfileImage,
                      child: Obx(
                        () => Column(
                          children: [
                            Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(26),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(77),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (controller
                                      .profileImageLocalPath
                                      .value
                                      .isNotEmpty)
                                    ClipOval(
                                      child: Image.file(
                                        File(
                                          controller
                                              .profileImageLocalPath
                                              .value,
                                        ),
                                        width: 100.w,
                                        height: 100.h,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else if (controller
                                      .profileImagePath
                                      .value
                                      .isNotEmpty)
                                    ClipOval(
                                      child: Image.network(
                                        controller.profileImagePath.value,
                                        width: 100.w,
                                        height: 100.h,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 60.sp,
                                                color: AppColors.primary,
                                              );
                                            },
                                      ),
                                    )
                                  else
                                    Image.asset(
                                      'assets/Logos/Camera.png',
                                      width: 42.w,
                                      height: 42.h,
                                      fit: BoxFit.contain,
                                    ),
                                  if (controller.isProfileImageUploading.value)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withAlpha(180),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SizedBox(
                                        width: 28.w,
                                        height: 28.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Upload Photo',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Full Name Field
                  _buildTextField(
                    label: 'Full Name *',
                    hint: 'Enter your full name',
                    controller: controller.nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Phone Number Field (Read-only)
                  _buildTextField(
                    label: 'Phone Number *',
                    hint: '',
                    controller: TextEditingController(
                      text: controller.formattedPhoneNumber,
                    ),
                    enabled: false,
                    fillColor: AppColors.grey200,
                  ),
                  SizedBox(height: 16.h),

                  // Email Field
                  _buildTextField(
                    label: 'Email Address *',
                    hint: 'Enter your full name',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Division Dropdown
                  _buildDropdown(
                    label: 'Division *',
                    hint: 'Select your division',
                    value: controller.selectedDivision,
                    items: controller.divisions,
                    onChanged: controller.updateDivision,
                  ),
                  SizedBox(height: 16.h),

                  // District Dropdown
                  Obx(
                    () => _buildDropdown(
                      label: 'District *',
                      hint: 'Select your district',
                      value: controller.selectedDistrict,
                      items: controller.districts,
                      onChanged: controller.updateDistrict,
                      enabled: controller.selectedDivision.value.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Upazilla Dropdown
                  Obx(
                    () => _buildDropdown(
                      label: 'Upazilla *',
                      hint: 'Select your upazilla',
                      value: controller.selectedUpazilla,
                      items: controller.upazillas,
                      onChanged: controller.updateUpazilla,
                      enabled: controller.selectedDistrict.value.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Pouroshova/City Corp/Union Dropdown
                  Obx(
                    () => _buildDropdown(
                      label: 'Pouroshova/City Corp/Union *',
                      hint: 'Select your Pouroshova/City Corp *',
                      value: controller.selectedUnion,
                      items: controller.unions,
                      onChanged: controller.updateUnion,
                      enabled: controller.selectedUpazilla.value.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Ward No Dropdown
                  Obx(
                    () => _buildDropdown(
                      label: 'Ward No *',
                      hint: 'Select Ward No',
                      value: controller.selectedWard,
                      items: controller.wards,
                      onChanged: controller.updateWard,
                      enabled: controller.selectedUnion.value.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Postal Code Field
                  _buildTextField(
                    label: 'Postal Code',
                    hint: 'Enter Postal Code',
                    controller: controller.postalCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  // Full Address Field
                  _buildFullAddressField(),
                  SizedBox(height: 24.h),

                  // Next Button
                  Obx(
                    () => PrimaryButton(
                      text: 'Next',
                      isLoading: controller.isLoading.value,
                      showArrow: true,
                      onPressed: controller.savePersonalInfo,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Mandatory fields note
                  Center(
                    child: Text(
                      '(*) marks are mandatory fields',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                      ),
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
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Color? fillColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16.sp,
            color: enabled ? AppColors.grey900 : AppColors.grey600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
            filled: true,
            fillColor: fillColor ?? const Color.fromARGB(255, 255, 255, 255),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Address',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.fullAddressController,
          maxLines: 3,
          onTap: () {
            controller.markFullAddressAsCustomized();
          },
          onChanged: (_) {
            controller.markFullAddressAsCustomized();
          },
          style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText:
                'Holding #45, Ward #03, Bogura Pourashava, Bogura Sadar, Bogura-5800, Rajshahi',
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required RxString value,
    required RxList<String> items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: enabled ? AppColors.white : AppColors.grey200,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value.isEmpty ? null : value.value,
                hint: Text(
                  hint,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? AppColors.grey600 : AppColors.grey400,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
