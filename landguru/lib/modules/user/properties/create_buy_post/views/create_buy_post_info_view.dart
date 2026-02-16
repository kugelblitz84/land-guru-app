import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/properties_widgets.dart';
import '../create_buy_post_controller.dart';

/// Create Buy Post Step 1: Requirements
class CreateBuyPostInfoView extends GetView<CreateBuyPostController> {
  const CreateBuyPostInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: controller.previousStep,
        ),
        centerTitle: true,
        title: Text(
          'Create Buy Post',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: PostStepIndicator(
              currentStep: 1,
              totalSteps: controller.totalSteps,
              onSaveAsDraft: controller.saveAsDraft,
            ),
          ),

          // Form content
          Expanded(
            child: Form(
              key: controller.requirementsFormKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Section Title
                    Text(
                      'What are you looking for?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Ad Title
                    _buildTextField(
                      label: 'Ad Title',
                      controller: controller.titleController,
                      hintText: 'E.g. 3 Bedroom Flat in Banshkhari',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Description
                    _buildTextField(
                      label: 'Description',
                      controller: controller.descriptionController,
                      hintText:
                          'Add description about your property, purpose for selling, new features and so on',
                      isRequired: true,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Property Type
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PropertyTypeSelector(
                            label: 'Property Type',
                            selectedType: controller.propertyType.value,
                            onChanged: controller.updatePropertyType,
                          ),
                          if (controller
                              .propertyTypeError
                              .value
                              .isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              controller.propertyTypeError.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Minimum Land Size
                    Obx(
                      () => MetricsInputField(
                        label: 'Minimum Land Size',
                        controller: controller.minLandSizeController,
                        selectedUnit: controller.landSizeUnit.value,
                        onUnitChanged: controller.changeLandSizeUnit,
                        hintText: '5.000',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum land size';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Land size conversions
                    Obx(() {
                      final value = controller.landSizeValue.value;
                      final unit = controller.landSizeUnit.value;
                      if (value > 0) {
                        return MetricsConversionRow(
                          value: value,
                          currentUnit: unit,
                          label: 'In other metrics',
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: 12.h),

                    // Land size range slider
                    Obx(
                      () => LandSizeRangeSlider(
                        currentValue: controller.landSizeValue.value,
                        currentUnit: controller.landSizeUnit.value,
                        onChanged: controller.updateLandSizeFromSlider,
                        label: 'Select range',
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Minimum Plot Size (Optional)
                    Obx(
                      () => MetricsInputField(
                        label: 'Minimum Plot Size (Optional)',
                        controller: controller.minPlotSizeController,
                        selectedUnit: controller.plotSizeUnit.value,
                        onUnitChanged: controller.changePlotSizeUnit,
                        isRequired: false,
                        hintText: '5.000',
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Plot size conversions
                    Obx(() {
                      final value = controller.plotSizeValue.value;
                      final unit = controller.plotSizeUnit.value;
                      if (value > 0) {
                        return MetricsConversionRow(
                          value: value,
                          currentUnit: unit,
                          label: 'In other metrics',
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: 12.h),

                    // Plot size range slider
                    Obx(
                      () => LandSizeRangeSlider(
                        currentValue: controller.plotSizeValue.value,
                        currentUnit: controller.plotSizeUnit.value,
                        onChanged: controller.updatePlotSizeFromSlider,
                        label: 'Select range',
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Distance From Road
                    Obx(
                      () => DistanceRangeSelector(
                        selectedRange: controller.distanceRange.value,
                        onChanged: controller.updateDistanceRange,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Budget Range
                    Obx(
                      () => BudgetRangeSlider(
                        selectedRange: controller.budgetRange.value,
                        minBudgetController: controller.minBudgetController,
                        maxBudgetController: controller.maxBudgetController,
                        onChanged: controller.updateBudgetRange,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Preferred Location Section
                    Text(
                      'Preferred Location',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Obx(
                      () => LocationPicker(
                        location: controller.location.value,
                        onChanged: controller.updateLocation,
                        showFullAddress: false,
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),

          // Next button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey300.withAlpha(100),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSavingDraft.value
                          ? null
                          : controller.validateAndNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.white,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '(*) marks are mandatory fields',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText: hintText,
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
}
