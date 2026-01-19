import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/properties_widgets.dart';
import '../create_sell_post_controller.dart';

/// Create Sell Post Step 4: Review & Submit
class CreateSellPostReviewView extends GetView<CreateSellPostController> {
  const CreateSellPostReviewView({super.key});

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
              currentStep: 4,
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
                    'Review you post',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Review your sell post once more and confirm your payment.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grey600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Property Preview Card
                  _buildPropertyPreviewCard(),
                  SizedBox(height: 20.h),

                  // Description
                  Builder(
                    builder: (context) {
                      final description = controller.descriptionController.text;
                      if (description.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpandableDescription(
                            title: 'Description',
                            text: description,
                            maxLines: 1,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      );
                    },
                  ),

                  // Details with Change Metrics
                  Obx(
                    () => _buildDetailRowWithAction(
                      imageAsset: 'assets/Logos/Land&plotSize.png',
                      label: 'Sellable Land Amount',
                      value: controller.formattedLandAmount.isNotEmpty
                          ? controller.formattedLandAmount
                          : 'Not specified',
                      actionWidget: ChangeMetricsPopup(
                        selectedUnit: controller.landAmountUnit.value,
                        onUnitChanged: controller.changeLandAmountUnit,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Obx(() {
                    // Access reactive values to trigger observation
                    final _ = controller.plotSizeValue.value;
                    final unit = controller.plotSizeUnit.value;
                    final plotSize = controller.formattedPlotSize;
                    if (plotSize.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        _buildDetailRowWithAction(
                          imageAsset: 'assets/Logos/Land&plotSize.png',
                          label: 'Plot Size',
                          value: plotSize,
                          actionWidget: ChangeMetricsPopup(
                            selectedUnit: unit,
                            onUnitChanged: controller.changePlotSizeUnit,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    );
                  }),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/DistanceFromRoad.png',
                    label: 'Distance from Road',
                    value:
                        controller.distanceRange.value?.label ??
                        'Not specified',
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/Location.png',
                    label: 'Location',
                    value: controller.location.value.formattedAddress.isNotEmpty
                        ? controller.location.value.formattedAddress
                        : 'Not specified',
                  ),
                  SizedBox(height: 24.h),

                  // Property Photos
                  Obx(() {
                    final photos = controller.photos.toList();
                    return _buildMediaSection(
                      icon: Icons.image_outlined,
                      label: 'Property Photos',
                      child: photos.isNotEmpty
                          ? PhotoGridPreview(photos: photos, maxVisible: 3)
                          : Text(
                              'No photos added',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                    );
                  }),
                  SizedBox(height: 20.h),

                  // Property Video
                  Obx(() {
                    final video = controller.video.value;
                    return _buildMediaSection(
                      icon: Icons.videocam_outlined,
                      label: 'Property Video',
                      child: video != null
                          ? VideoPreviewCompact(video: video)
                          : Text(
                              'No video added',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                    );
                  }),
                  SizedBox(height: 24.h),

                  // Legal Documents
                  Text(
                    'Legal Documents',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Deed Documents
                  Obx(() {
                    final documents = controller.deedDocuments.toList();
                    return documents.isNotEmpty
                        ? DocumentListPreview(
                            label: 'Deed section',
                            documents: documents,
                          )
                        : const SizedBox.shrink();
                  }),
                  SizedBox(height: 16.h),

                  // Khatian Documents
                  Obx(() {
                    final documents = controller.khatianDocuments.toList();
                    return documents.isNotEmpty
                        ? DocumentListPreview(
                            label: 'Khatian section',
                            documents: documents,
                          )
                        : const SizedBox.shrink();
                  }),
                  SizedBox(height: 24.h),

                  // Info banner
                  InfoBanner(
                    message:
                        'You will be prompted for accepting and negotiating with quotation of the service fees later after we review your submission.',
                    type: InfoBannerType.info,
                  ),

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

  Widget _buildPropertyPreviewCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Property Image Placeholder
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(100),
                  AppColors.primaryDark.withAlpha(150),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.home,
                color: AppColors.white.withAlpha(200),
                size: 36.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.titleController.text.isNotEmpty
                      ? controller.titleController.text
                      : 'Property Title',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Obx(() {
                  // Access reactive values to trigger observation
                  final _ = controller.landAmountValue.value;
                  final __ = controller.pricePerKathaValue.value;
                  return Text(
                    'Asking Price: ${controller.formattedAskingPrice}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                SizedBox(height: 8.h),
                Obx(() {
                  final propertyType = controller.propertyType.value;
                  return propertyType != null
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            propertyType.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    IconData? icon,
    required String label,
    required String value,
    String? imageAsset,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                icon ?? Icons.info,
                size: 20.sp,
                color: AppColors.primary,
              );
            },
          )
        else
          Icon(icon ?? Icons.info, size: 20.sp, color: AppColors.primary),
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
                  fontWeight: FontWeight.w500,
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
    IconData? icon,
    required String label,
    required String value,
    required Widget actionWidget,
    String? imageAsset,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                icon ?? Icons.info,
                size: 20.sp,
                color: AppColors.primary,
              );
            },
          )
        else
          Icon(icon ?? Icons.info, size: 20.sp, color: AppColors.primary),
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
                  actionWidget,
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.grey700),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}
