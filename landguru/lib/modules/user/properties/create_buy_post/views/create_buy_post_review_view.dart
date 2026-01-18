import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/properties_widgets.dart';
import '../create_buy_post_controller.dart';

/// Create Buy Post Step 2: Review & Submit
class CreateBuyPostReviewView extends GetView<CreateBuyPostController> {
  const CreateBuyPostReviewView({super.key});

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
              currentStep: 2,
              totalSteps: controller.totalSteps,
              onSaveAsDraft: controller.saveAsDraft,
            ),
          ),

          // Review content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Section Title
                  Text(
                    'Review your requirements',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Review your buy post once more and confirm your placement. Your post will be visible as below.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grey600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Review Card
                  _buildReviewCard(context),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // Submit button
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
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit for Review',
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

  Widget _buildReviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Obx(
            () => Text(
              controller.titleValue.value.isNotEmpty
                  ? controller.titleValue.value
                  : '${controller.propertyType.value?.label ?? ''} Needed',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Preferred Location
          Obx(
            () => _buildDetailRow(
              imageAsset: 'assets/Logos/Location.png',
              label: 'Preferred Location',
              value: controller.location.value.formattedAddress.isNotEmpty
                  ? controller.location.value.formattedAddress
                  : 'Not specified',
            ),
          ),
          SizedBox(height: 16.h),

          // Property Type
          Obx(
            () => _buildDetailRow(
              imageAsset: 'assets/Logos/flat.png',
              label: 'Property Type',
              value: controller.propertyType.value?.label ?? 'Not specified',
            ),
          ),
          SizedBox(height: 16.h),

          // Required Land Size
          Obx(
            () => _buildDetailRowWithAction(
              context: context,
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Required Land Size',
              value: controller.formattedLandSize.isNotEmpty
                  ? 'Min ${controller.formattedLandSize}'
                  : 'Not specified',
              actionLabel: 'Change Metrics',
              onAction: () async {
                final newUnit = await ChangeMetricsSheet.show(
                  context,
                  currentUnit: controller.landSizeUnit.value,
                );
                if (newUnit != null) {
                  controller.changeLandSizeUnit(newUnit);
                }
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Required Plot Size
          Obx(() {
            final plotSize = controller.formattedPlotSize;
            if (plotSize.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _buildDetailRowWithAction(
                  context: context,
                  imageAsset: 'assets/Logos/Land&plotSize.png',
                  label: 'Required Plot Size',
                  value: 'Min $plotSize',
                  actionLabel: 'Change Metrics',
                  onAction: () async {
                    final newUnit = await ChangeMetricsSheet.show(
                      context,
                      currentUnit: controller.plotSizeUnit.value,
                    );
                    if (newUnit != null) {
                      controller.changePlotSizeUnit(newUnit);
                    }
                  },
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Distance from Road
          Obx(
            () => _buildDetailRow(
              imageAsset: 'assets/Logos/DistanceFromRoad.png',
              label: 'Distance from Road',
              value: controller.distanceRange.value?.label ?? 'Not specified',
            ),
          ),
          SizedBox(height: 16.h),

          // Budget Range
          Obx(
            () => _buildDetailRow(
              imageAsset: 'assets/Logos/Budget Range.png',
              label: 'Budget Range',
              value: controller.formattedBudgetRange.isNotEmpty
                  ? controller.formattedBudgetRange
                  : 'Not specified',
            ),
          ),

          // Description
          Obx(() {
            if (controller.descriptionValue.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Divider(color: AppColors.grey200),
                SizedBox(height: 16.h),
                ExpandableDescription(
                  title: 'Description',
                  text: controller.descriptionValue.value,
                  maxLines: 1,
                  titleStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    IconData? icon,
    required String label,
    required String value,
    Color? iconColor,
    String? imageAsset,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: imageAsset != null
                ? Image.asset(
                    imageAsset,
                    width: 20.w,
                    height: 20.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        icon ?? Icons.info,
                        size: 20.sp,
                        color: iconColor ?? AppColors.primary,
                      );
                    },
                  )
                : Icon(
                    icon ?? Icons.info,
                    size: 20.sp,
                    color: iconColor ?? AppColors.primary,
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithAction({
    required BuildContext context,
    IconData? icon,
    required String label,
    required String value,
    Color? iconColor,
    required String actionLabel,
    required VoidCallback onAction,
    String? imageAsset,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: imageAsset != null
                ? Image.asset(
                    imageAsset,
                    width: 20.w,
                    height: 20.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        icon ?? Icons.info,
                        size: 20.sp,
                        color: iconColor ?? AppColors.primary,
                      );
                    },
                  )
                : Icon(
                    icon ?? Icons.info,
                    size: 20.sp,
                    color: iconColor ?? AppColors.primary,
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
