import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/properties_widgets.dart';
import '../create_sell_post_controller.dart';

/// Create Sell Post Step 2: Property Visuals & Documents
class CreateSellPostMediaView extends GetView<CreateSellPostController> {
  const CreateSellPostMediaView({super.key});

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
                    'Upload photos & video tour to attract buyers',
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
                  SizedBox(height: 24.h),

                  // Property Video
                  Obx(() {
                    final video = controller.video.value;
                    return VideoUploadWidget(
                      video: video,
                      onAddVideo: controller.addVideo,
                      onRemoveVideo: controller.removeVideo,
                      label: 'Property Video',
                      isRequired: true,
                      maxSizeMB: 500,
                    );
                  }),
                  SizedBox(height: 32.h),

                  // Legal Documents Section
                  Text(
                    'Legal Documents',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Info banner
                  InfoBanner(
                    message:
                        'Upload all raw documents of your Deeds/Khatians. We will organize and verify them for you',
                    type: InfoBannerType.info,
                  ),
                  SizedBox(height: 20.h),

                  // Deed Section
                  Obx(() {
                    final documents = controller.deedDocuments.toList();
                    return DocumentUploadWidget(
                      label: 'Deed section',
                      documents: documents,
                      onAddDocument: controller.addDeedDocument,
                      onRemoveDocument: controller.removeDeedDocument,
                      isRequired: true,
                    );
                  }),
                  SizedBox(height: 24.h),

                  // Khatian Section
                  Obx(() {
                    final documents = controller.khatianDocuments.toList();
                    return DocumentUploadWidget(
                      label: 'Khatian section',
                      documents: documents,
                      onAddDocument: controller.addKhatianDocument,
                      onRemoveDocument: controller.removeKhatianDocument,
                      isRequired: true,
                    );
                  }),
                  SizedBox(height: 24.h),

                  // Other Documents
                  Obx(() {
                    final documents = controller.otherDocuments.toList();
                    return DocumentUploadWidget(
                      label: 'Other documents',
                      documents: documents,
                      onAddDocument: controller.addOtherDocument,
                      onRemoveDocument: controller.removeOtherDocument,
                      isRequired: false,
                    );
                  }),

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
