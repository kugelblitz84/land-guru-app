import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/properties_widgets.dart';
import '../create_sell_post_controller.dart';

/// Create Sell Post Step 3: Verification Services Selection
class CreateSellPostServicesView extends GetView<CreateSellPostController> {
  const CreateSellPostServicesView({super.key});

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
          'Create Sell Post',
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
              currentStep: 3,
              totalSteps: controller.totalSteps,
              onSaveAsDraft: controller.saveAsDraft,
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Section Title
                  Text(
                    'Verification Services',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select the services needed to verify your land. Mandatory items ensure a faster sale and are pre-selected',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grey600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Info banner
                  InfoBanner(
                    message:
                        'You will be prompted for accepting and negotiating with quotation of the service fees later after we review your submission.',
                    type: InfoBannerTypes.info,
                  ),
                  SizedBox(height: 24.h),

                  // Mandatory Services
                  ...controller.mandatoryServices.map((service) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ServiceCheckboxItem(
                        service: service,
                        isSelected: true, // Always selected
                        onChanged: null, // Disabled
                      ),
                    );
                  }),

                  // Optional Services Section Header
                  const ServicesSectionHeader(title: 'OPTIONAL SERVICES'),

                  // Optional Services
                  Obx(
                    () => Column(
                      children: controller.optionalServices.map((service) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ServiceCheckboxItem(
                            service: service,
                            isSelected: controller.isServiceSelected(
                              service.id,
                            ),
                            onChanged: (selected) {
                              controller.toggleService(service.id);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
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
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      (controller.isLoading.value ||
                          controller.isSavingDraft.value)
                      ? null
                      : controller.validateAndNextFromServices,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Row(
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
          ),
        ],
      ),
    );
  }
}

