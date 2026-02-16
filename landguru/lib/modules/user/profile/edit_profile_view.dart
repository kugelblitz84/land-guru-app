import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'edit_profile_controller.dart';

/// Edit Profile screen
class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

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
          'Edit Profile',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Profile Photo
              Center(child: _buildProfilePhoto()),

              SizedBox(height: 24.h),

              // Personal Details Section
              Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),

              SizedBox(height: 16.h),

              // Full Name
              _buildLabel('Full Name', isRequired: true),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.fullNameController,
                hintText: 'Enter your full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Phone Number (Read-only)
              _buildLabel('Phone Number', isRequired: true),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.phoneController,
                hintText: 'Phone number',
                enabled: false,
                fillColor: AppColors.grey100,
              ),

              SizedBox(height: 16.h),

              // Email Address
              _buildLabel('Email Address', isRequired: true),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.emailController,
                hintText: 'Enter your email address',
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
              _buildLabel('Division', isRequired: true),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: controller.selectedDivision,
                items: controller.divisions,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedDivision.value = value;
                  }
                },
              ),

              SizedBox(height: 16.h),

              // District Dropdown
              _buildLabel('District', isRequired: true),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: controller.selectedDistrict,
                items: controller.districts,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedDistrict.value = value;
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Upazilla Dropdown
              _buildLabel('Upazilla', isRequired: true),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: controller.selectedUpazilla,
                items: controller.upazillas,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedUpazilla.value = value;
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Pouroshova/City Corp/Union Dropdown
              _buildLabel('Pouroshova/City Corp/Union', isRequired: true),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: controller.selectedPouroshova,
                items: controller.pouroshovas,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedPouroshova.value = value;
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Ward No Dropdown
              _buildLabel('Ward No', isRequired: true),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: controller.selectedWardNo,
                items: controller.wardNumbers,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedWardNo.value = value;
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Postal Code
              _buildLabel('Postal Code'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.postalCodeController,
                hintText: 'Enter postal code',
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 16.h),

              // Full Address
              _buildLabel('Full Address'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.fullAddressController,
                hintText: 'Enter your full address',
                maxLines: 3,
              ),

              SizedBox(height: 24.h),

              // Verification Documents Section
              Text(
                'Verification Documents',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),

              SizedBox(height: 16.h),

              // NID Document
              Obx(
                () => _buildVerificationDocument(
                  icon: Icons.credit_card_outlined,
                  title: 'National ID (NID)',
                  subtitle: 'ID: ${controller.nidNumber.value}',
                  isVerified: controller.isNidVerified,
                ),
              ),

              SizedBox(height: 12.h),

              // TIN Certificate
              Obx(
                () => _buildVerificationDocument(
                  icon: Icons.description_outlined,
                  title: 'TIN Certificate',
                  subtitle: 'Tax ID: ${controller.tinNumber.value}',
                  isVerified: controller.isTinVerified,
                ),
              ),

              SizedBox(height: 32.h),

              // Save Changes Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      disabledBackgroundColor: AppColors.primary.withAlpha(150),
                    ),
                    child: controller.isSaving.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _buildProfilePhoto() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey200, width: 2),
              ),
              child: ClipOval(
                child: Obx(() {
                  final imageUrl = controller.profileImage.value.trim();
                  if (imageUrl.isNotEmpty) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPhotoFallback();
                      },
                    );
                  }

                  return Image.asset(
                    'assets/images/User_DP/MainUser.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPhotoFallback();
                    },
                  );
                }),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Icon(Icons.edit, color: AppColors.white, size: 16.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(
          () => GestureDetector(
            onTap: controller.isImageUploading.value
                ? null
                : controller.pickImage,
            child: Text(
              controller.isImageUploading.value
                  ? 'Uploading...'
                  : 'Change Photo',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: controller.isImageUploading.value
                    ? AppColors.grey500
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    Color? fillColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: enabled ? AppColors.grey900 : AppColors.grey500,
      ),
    );
  }

  Widget _buildDropdown({
    required RxString value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Obx(() {
      final selectedValue = items.contains(value.value)
          ? value.value
          : (items.isNotEmpty ? items.first : null);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      );
    });
  }

  Widget _buildPhotoFallback() {
    return Container(
      color: AppColors.grey200,
      child: Icon(Icons.person, color: AppColors.grey400, size: 50.sp),
    );
  }

  Widget _buildVerificationDocument({
    required IconData icon,
    required String title,
    required String subtitle,
    required RxBool isVerified,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(50),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isVerified.value
                    ? AppColors.success.withAlpha(20)
                    : AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isVerified.value
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              child: Text(
                isVerified.value ? 'Verified' : 'Pending',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isVerified.value
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
