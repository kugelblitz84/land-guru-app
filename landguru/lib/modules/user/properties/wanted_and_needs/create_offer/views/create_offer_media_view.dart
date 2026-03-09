import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../widgets/properties_widgets.dart';
import '../create_offer_controller.dart';

/// Create Offer Step 2: Property Photos
class CreateOfferMediaView extends GetView<CreateOfferController> {
  const CreateOfferMediaView({super.key});

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
          'Create New Sell Post And Offer',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 16.sp,
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
                    'Property Visuals',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Upload photos to attract buyers',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
                  ),
                  SizedBox(height: 24.h),

                  // Property Photos
                  Obx(() {
                    final photos = controller.photos.toList();
                    return PhotoUploadWidget(
                      photos: photos,
                      onAddPhoto: controller.addPhoto,
                      onRemovePhoto: controller.removePhoto,
                      maxPhotos: 10,
                      label: 'Property Photos',
                      isRequired: true,
                    );
                  }),
                  SizedBox(height: 32.h),

                  // Info banner about later requirements
                  InfoBanner(
                    message:
                        'You will need to upload property video, legal documents and confirm your payment for the services later when buyer confirms your post. You can also publish this post later if the buyer doesn\'t response to your post within 3-5 business days. This post will be saved as offered post.',
                    type: InfoBannerTypes.info,
                  ),
                  SizedBox(height: 24.h),

                  // Location privacy info
                  InfoBanner(
                    message:
                        'Your full location will remain private to the buyer.',
                    type: InfoBannerTypes.info,
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
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSavingDraft.value
                          ? null
                          : controller.validateAndNextFromMedia,
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
}

