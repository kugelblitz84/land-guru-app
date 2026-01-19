import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/my_post_status.dart';
import 'models/sell_post_models.dart';
import 'sell_post_details_controller.dart';
import 'widgets/sell_post_widgets.dart';

/// Sell Post Details View
/// Handles all 4 states: Pending, Quoted, Active, Draft
class SellPostDetailsView extends GetView<SellPostDetailsController> {
  const SellPostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(Icons.arrow_back, color: AppColors.grey900, size: 24.sp),
        ),
        title: Text(
          'Your Property Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = controller.postDetails.value;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Image
                    _buildPropertyImage(post),

                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Title and Price
                          _buildTitleSection(post),

                          // Draft: Edit and Delete buttons
                          if (post.status == MyPostStatus.draft) ...[
                            SizedBox(height: 16.h),
                            DraftActionButtons(
                              onEdit: controller.editPost,
                              onDelete: controller.deletePost,
                            ),
                          ],

                          SizedBox(height: 12.h),

                          // Tags
                          _buildTagsSection(post),

                          // Quoted: Bill Breakdown Section
                          if (post.status == MyPostStatus.quoted &&
                              post.billBreakdown != null) ...[
                            SizedBox(height: 16.h),
                            BillBreakdownSection(
                              billBreakdown: post.billBreakdown!,
                              onRequote: controller.requestRequote,
                              onPayAndActivate: controller.payAndActivate,
                            ),
                            SizedBox(height: 12.h),
                            RequoteSummaryCard(
                              billBreakdown: post.billBreakdown!,
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // Description
                          _buildDescriptionSection(post),

                          SizedBox(height: 16.h),

                          // Sellable Land Amount
                          _buildMetricRow(
                            icon: 'assets/Logos/Area.png',
                            label: 'Sellable Land Amount',
                            value: post.sellableLandAmount,
                            showChangeMetrics: true,
                          ),

                          SizedBox(height: 16.h),

                          // Plot Size
                          _buildMetricRow(
                            icon: 'assets/Logos/Area.png',
                            label: 'Plot Size',
                            value: post.plotSize,
                            showChangeMetrics: true,
                          ),

                          SizedBox(height: 16.h),

                          // Distance from Road
                          _buildDetailRow(
                            icon: Icons.straighten,
                            label: 'Distance from Road',
                            value: post.distanceFromRoad,
                          ),

                          SizedBox(height: 16.h),

                          // Location
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: post.location,
                          ),

                          // Active: Land Shape Section
                          if (post.status == MyPostStatus.active) ...[
                            SizedBox(height: 20.h),
                            _buildLandShapeSection(),
                          ],

                          SizedBox(height: 20.h),

                          // Property Photos
                          _buildPropertyPhotosSection(post),

                          SizedBox(height: 20.h),

                          // Active: Other Features Section
                          if (post.status == MyPostStatus.active) ...[
                            Obx(() {
                              final dueExpanded = controller.isFeatureExpanded(
                                0,
                              );
                              final videoExpanded = controller
                                  .isFeatureExpanded(1);
                              final ownershipExpanded = controller
                                  .isFeatureExpanded(2);

                              return OtherFeaturesSection(
                                dueDiligenceChecklist:
                                    post.dueDiligenceChecklist,
                                ownershipHistory: post.ownershipHistory,
                                servicesTaken: post.servicesTaken,
                                dueDiligenceExpanded: dueExpanded,
                                videoExpanded: videoExpanded,
                                ownershipExpanded: ownershipExpanded,
                                onToggleExpansion:
                                    controller.toggleFeatureExpansion,
                              );
                            }),
                            SizedBox(height: 16.h),
                          ],

                          // Property Video
                          _buildPropertyVideoSection(),

                          SizedBox(height: 20.h),

                          // Legal Documents
                          _buildLegalDocumentsSection(post),

                          // Active: Pentagraph Map Section
                          if (post.status == MyPostStatus.active) ...[
                            SizedBox(height: 16.h),
                            Obx(() {
                              final isExpanded = controller.isFeatureExpanded(
                                10,
                              );
                              return PentagraphMapSection(
                                isExpanded: isExpanded,
                                onToggle: () =>
                                    controller.toggleFeatureExpansion(10),
                              );
                            }),
                          ],

                          // Active: Services Taken Section
                          if (post.status == MyPostStatus.active &&
                              post.servicesTaken != null) ...[
                            SizedBox(height: 16.h),
                            Obx(() {
                              final isExpanded = controller.isFeatureExpanded(
                                11,
                              );
                              return ServicesTakenSection(
                                services: post.servicesTaken!,
                                isExpanded: isExpanded,
                                onToggle: () =>
                                    controller.toggleFeatureExpansion(11),
                              );
                            }),
                          ],

                          SizedBox(height: 100.h), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action button (Draft only)
            if (post.status == MyPostStatus.draft)
              ContinueEditingButton(onPressed: controller.continueEditing),
          ],
        );
      }),
    );
  }

  Widget _buildPropertyImage(SellPostDetails post) {
    return SizedBox(
      height: 220.h,
      width: double.infinity,
      child: post.imageUrl != null
          ? Image.asset(
              post.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primary.withAlpha(50),
      child: Center(
        child: Icon(
          Icons.image,
          size: 60.sp,
          color: AppColors.primary.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildTitleSection(SellPostDetails post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '৳ ${post.price}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          post.postId,
          style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
        ),
      ],
    );
  }

  Widget _buildTagsSection(SellPostDetails post) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        // Property Type
        _buildTag(
          post.propertyType,
          AppColors.primary.withAlpha(30),
          AppColors.primary,
        ),

        // Post Type
        _buildTag(
          'Sell Post',
          AppColors.primary.withAlpha(30),
          AppColors.primary,
        ),

        // Status badge
        _buildTag(
          post.status.label,
          post.status.backgroundColor,
          post.status.textColor,
        ),

        // Verified badge (Active only)
        if (post.isVerified)
          _buildTag(
            'Verified',
            AppColors.success.withAlpha(30),
            AppColors.success,
            icon: Icons.check_circle,
          ),
      ],
    );
  }

  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor, {
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(SellPostDetails post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final isExpanded = controller.isDescriptionExpanded.value;
          final description = post.description;
          final shouldTruncate = description.length > 150;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpanded || !shouldTruncate
                    ? description
                    : '${description.substring(0, 150)}...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.grey700,
                  height: 1.5,
                ),
              ),
              if (shouldTruncate)
                GestureDetector(
                  onTap: controller.toggleDescription,
                  child: Text(
                    isExpanded ? 'Show Less' : 'Read More',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMetricRow({
    required String icon,
    required String label,
    required String value,
    bool showChangeMetrics = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          icon,
          width: 20.sp,
          height: 20.sp,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.square_foot,
              size: 20.sp,
              color: AppColors.primary,
            );
          },
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  if (showChangeMetrics)
                    GestureDetector(
                      onTap: () {
                        // TODO: Show metrics conversion
                      },
                      child: Text(
                        'Change Metrics',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandShapeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 10.w),
            Text(
              'Land Shape',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grey200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: Image.asset(
              'assets/images/Maps/LandShape.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 48.sp,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Land Shape Map',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyPhotosSection(SellPostDetails post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 10.w),
            Text(
              'Property Photos',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: post.propertyPhotos.length > 4
                ? 4
                : post.propertyPhotos.length,
            itemBuilder: (context, index) {
              // Show +N for remaining photos
              if (index == 3 && post.propertyPhotos.length > 4) {
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '+${post.propertyPhotos.length - 3}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                );
              }

              return Container(
                width: 80.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    post.propertyPhotos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey200,
                        child: Icon(
                          Icons.image,
                          color: AppColors.grey400,
                          size: 24.sp,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 10.w),
            Text(
              'Property Video',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: Center(
            child: Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 40.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalDocumentsSection(SellPostDetails post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal Documents',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 16.h),

        // Deed Section
        if (post.deedDocuments.isNotEmpty) ...[
          _buildDocumentSection('Deed section *', post.deedDocuments),
          SizedBox(height: 16.h),
        ],

        // Khatian Section
        if (post.khatianDocuments.isNotEmpty)
          _buildDocumentSection('Khatian section *', post.khatianDocuments),
      ],
    );
  }

  Widget _buildDocumentSection(String title, List<LegalDocument> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 18.sp,
              color: AppColors.grey600,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...documents.map((doc) => _buildDocumentItem(doc)),
      ],
    );
  }

  Widget _buildDocumentItem(LegalDocument document) {
    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (document.iconType) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconBgColor = AppColors.error.withAlpha(20);
        iconColor = AppColors.error;
        break;
      case 'docx':
        iconData = Icons.description;
        iconBgColor = AppColors.primary.withAlpha(20);
        iconColor = AppColors.primary;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconBgColor = AppColors.grey200;
        iconColor = AppColors.grey600;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(iconData, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  document.size,
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
