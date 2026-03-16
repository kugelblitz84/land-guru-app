import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../for_sale/property_details/widgets/property_details_widgets.dart';
import '../../widgets/metrics_conversion_row.dart';
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Image
                    _buildPropertyImage(post),
                    SizedBox(height: 10.h),

                    // Title and Price
                    _buildTitleSection(post),
                    SizedBox(height: 8.h),

                    // Tags
                    _buildTagsSection(post),

                    // Draft: Edit and Delete buttons
                    if (post.status == MyPostStatus.draft) ...[
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: DraftActionButtons(
                          onEdit: controller.editPost,
                          onDelete: controller.deletePost,
                        ),
                      ),
                    ],

                    // Quoted: Bill Breakdown Section
                    if (post.status == MyPostStatus.quoted &&
                        post.billBreakdown != null) ...[
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: BillBreakdownSection(
                          billBreakdown: post.billBreakdown!,
                          onRequote: controller.requestRequote,
                          onPayAndActivate: controller.payAndActivate,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: RequoteSummaryCard(
                          billBreakdown: post.billBreakdown!,
                        ),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // Description
                    _buildDescriptionSection(post),
                    SizedBox(height: 16.h),

                    // Sellable Land Amount
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Obx(() {
                        final conversions = controller.getAllConversions(
                          post.sellableLandAmount,
                        );
                        final convertedValue = controller
                            .getConvertedLandAmount(post.sellableLandAmount);
                        final currentUnit =
                            controller.selectedLandUnit.value.label;

                        final conversionsMap = <String, double>{};
                        conversions.forEach((unit, value) {
                          if (unit.label != currentUnit) {
                            conversionsMap[unit.label] = value;
                          }
                        });

                        return PropertyDetailRowWithAction(
                          imageAsset: 'assets/Logos/Land&plotSize.png',
                          label: 'Sellable Land Amount',
                          value: convertedValue,
                          actionWidget: ChangeMetricsPopup(
                            selectedUnit: controller.selectedLandUnit.value,
                            onUnitChanged: (unit) {
                              controller.selectedLandUnit.value = unit;
                            },
                          ),
                          conversions: conversionsMap,
                          currentUnit: currentUnit,
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),

                    // Plot Size
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Obx(() {
                        final conversions = controller.getAllConversions(
                          post.plotSize,
                        );
                        final convertedValue = controller
                            .getConvertedLandAmount(post.plotSize);
                        final currentUnit =
                            controller.selectedLandUnit.value.label;

                        final conversionsMap = <String, double>{};
                        conversions.forEach((unit, value) {
                          if (unit.label != currentUnit) {
                            conversionsMap[unit.label] = value;
                          }
                        });

                        return PropertyDetailRowWithAction(
                          imageAsset: 'assets/Logos/Land&plotSize.png',
                          label: 'Plot Size',
                          value: convertedValue,
                          actionWidget: ChangeMetricsPopup(
                            selectedUnit: controller.selectedLandUnit.value,
                            onUnitChanged: (unit) {
                              controller.selectedLandUnit.value = unit;
                            },
                          ),
                          conversions: conversionsMap,
                          currentUnit: currentUnit,
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),

                    // Share Unit (only shown if property has share unit)
                    if (post.shareUnit != null && post.shareUnit!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Obx(() {
                          final conversions = controller.getAllConversions(
                            post.shareUnit!,
                          );
                          final convertedValue = controller
                              .getConvertedLandAmount(post.shareUnit!);
                          final currentUnit =
                              controller.selectedLandUnit.value.label;

                          final conversionsMap = <String, double>{};
                          conversions.forEach((unit, value) {
                            if (unit.label != currentUnit) {
                              conversionsMap[unit.label] = value;
                            }
                          });

                          return PropertyDetailRowWithAction(
                            imageAsset: 'assets/Logos/Land&plotSize.png',
                            label: 'Share Unit',
                            value: convertedValue,
                            actionWidget: ChangeMetricsPopup(
                              selectedUnit: controller.selectedLandUnit.value,
                              onUnitChanged: (unit) {
                                controller.selectedLandUnit.value = unit;
                              },
                            ),
                            conversions: conversionsMap,
                            currentUnit: currentUnit,
                          );
                        }),
                      ),
                    if (post.shareUnit != null && post.shareUnit!.isNotEmpty)
                      SizedBox(height: 16.h),

                    // Distance from Road
                    PropertyDetailRow(
                      imageAsset: 'assets/Logos/DistanceFromRoad.png',
                      label: 'Distance from Road',
                      value: post.distanceFromRoad,
                    ),
                    SizedBox(height: 16.h),

                    // Location
                    PropertyDetailRow(
                      imageAsset: 'assets/Logos/Location.png',
                      label: 'Location',
                      value: post.location,
                    ),

                    // Active: Land Shape Section
                    if (post.status == MyPostStatus.active) ...[
                      SizedBox(height: 12.h),
                      const LandShapeSection(),
                    ],

                    SizedBox(height: 12.h),

                    // Property Photos
                    PropertyPhotosSection(photos: post.propertyPhotos),
                    SizedBox(height: 12.h),

                    // Active: Other Features Section (with blue background)
                    if (post.status == MyPostStatus.active) ...[
                      Container(
                        color: AppColors.propertyDetailsBackground,
                        child: Column(
                          children: [
                            SizedBox(height: 12.h),
                            Obx(() {
                              final dueExpanded = controller.isFeatureExpanded(
                                0,
                              );
                              final videoExpanded = controller
                                  .isFeatureExpanded(1);
                              final ownershipExpanded = controller
                                  .isFeatureExpanded(2);

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: OtherFeaturesSection(
                                  dueDiligenceChecklist:
                                      post.dueDiligenceChecklist,
                                  ownershipHistory: post.ownershipHistory,
                                  servicesTaken: post.servicesTaken,
                                  dueDiligenceExpanded: dueExpanded,
                                  videoExpanded: videoExpanded,
                                  ownershipExpanded: ownershipExpanded,
                                  onToggleExpansion:
                                      controller.toggleFeatureExpansion,
                                ),
                              );
                            }),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ],

                    // Property Video
                    _buildPropertyVideoSection(),
                    SizedBox(height: 12.h),

                    // Legal Documents
                    _buildLegalDocumentsSection(post),

                    // Active: Pentagraph Map Section
                    if (post.status == MyPostStatus.active) ...[
                      SizedBox(height: 12.h),
                      Obx(() {
                        final isExpanded = controller.isFeatureExpanded(10);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: PentagraphMapSection(
                            isExpanded: isExpanded,
                            onToggle: () =>
                                controller.toggleFeatureExpansion(10),
                          ),
                        );
                      }),
                    ],

                    // Active: Services Taken Section
                    if (post.status == MyPostStatus.active &&
                        post.servicesTaken != null) ...[
                      SizedBox(height: 12.h),
                      Obx(() {
                        final isExpanded = controller.isFeatureExpanded(11);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: ServicesTakenSection(
                            services: post.servicesTaken!,
                            isExpanded: isExpanded,
                            onToggle: () =>
                                controller.toggleFeatureExpansion(11),
                          ),
                        );
                      }),
                    ],

                    // Bottom action button (Draft only, inside scroll)
                    if (post.status == MyPostStatus.draft) ...[
                      SizedBox(height: 16.h),
                      ContinueEditingButton(
                        onPressed: controller.continueEditing,
                      ),
                    ],

                    SizedBox(height: 24.h), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPropertyImage(SellPostDetails post) {
    final imagePath = post.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: imagePath != null
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/images/Properties demo/Gazipur Water Zone.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
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
      },
    );
  }

  Widget _buildTitleSection(SellPostDetails post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
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
          Text(
            post.postId,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(SellPostDetails post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          _buildTag(post.propertyType, AppColors.primary),
          _buildTag('Sell Post', AppColors.primary),
          _buildStatusTag(post.status),
          if (post.isVerified)
            _buildTag('Verified', AppColors.success, icon: Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: AppColors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(MyPostStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: status.textColor,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(SellPostDetails post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
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
      ),
    );
  }

  Widget _buildPropertyVideoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
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
      ),
    );
  }

  Widget _buildLegalDocumentsSection(SellPostDetails post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
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
      ),
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
        border: Border.all(color: AppColors.primaryLight.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(20),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
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
