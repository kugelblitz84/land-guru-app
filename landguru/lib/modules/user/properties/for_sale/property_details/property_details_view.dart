import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/metrics_conversion_row.dart';
import 'models/property_details_models.dart';
import 'property_details_controller.dart';
import 'widgets/property_details_widgets.dart';

/// Unified Property Details View (handles both locked and unlocked states)
class PropertyDetailsView extends GetView<PropertyDetailsController> {
  const PropertyDetailsView({super.key});

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
        title: Obx(
          () => Text(
            controller.pageTitle.value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final property = controller.property.value;
        if (property == null) {
          return const Center(child: Text('Property not found'));
        }

        final isLocked = controller.isLocked.value;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Image
              _buildPropertyImage(property),
              SizedBox(height: 10.h),

              // Title and Tags
              PropertyTitleSection(property: property),
              SizedBox(height: 8.h),
              PropertyTagsSection(property: property, isLocked: isLocked),
              SizedBox(height: 12.h),

              // Description
              PropertyDescriptionSection(
                description: property.description,
                isExpanded: controller.isDescriptionExpanded.value,
                onToggle: controller.toggleDescription,
              ),
              SizedBox(height: 16.h),

              // Location
              PropertyDetailRow(
                imageAsset: 'assets/Logos/Location.png',
                label: 'Location',
                value: property.location,
              ),
              SizedBox(height: 16.h),

              // Sellable Land Amount
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Obx(() {
                  final conversions = controller.getAllConversions(
                    property.sellableLandAmount,
                  );
                  final convertedValue = controller.getConvertedLandAmount(
                    property.sellableLandAmount,
                  );
                  final currentUnit = controller.selectedLandUnit.value.label;

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
                    property.plotSize,
                  );
                  final convertedValue = controller.getConvertedLandAmount(
                    property.plotSize,
                  );
                  final currentUnit = controller.selectedLandUnit.value.label;

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
              if (property.shareUnit != null && property.shareUnit!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Obx(() {
                    final conversions = controller.getAllConversions(
                      property.shareUnit!,
                    );
                    final convertedValue = controller.getConvertedLandAmount(
                      property.shareUnit!,
                    );
                    final currentUnit = controller.selectedLandUnit.value.label;

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
              if (property.shareUnit != null && property.shareUnit!.isNotEmpty)
                SizedBox(height: 16.h),

              // Distance from Road
              PropertyDetailRow(
                imageAsset: 'assets/Logos/DistanceFromRoad.png',
                label: 'Distance from Road',
                value:
                    '${property.distanceFromRoadMin} - ${property.distanceFromRoadMax}',
              ),
              SizedBox(height: 16.h),

              // Land Shape
              LandShapeSection(imageUrl: property.landShapeImageUrl),
              SizedBox(height: 12.h),

              // Property Photos
              PropertyPhotosSection(
                photos: property.propertyPhotos,
                onPhotoTap: (index) => _openPhotoViewer(property, index),
              ),
              SizedBox(height: 12.h),

              // Features Section (Locked or Unlocked based on state)
              Container(
                color: AppColors.propertyDetailsBackground,
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    isLocked
                        ? _buildLockedFeaturesSection()
                        : _buildUnlockedFeaturesSection(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),

              // How to buy section
              const HowToBuySection(),
              SizedBox(height: 12.h),

              // Posted By section
              PostedBySection(
                name: property.postedBy,
                isVerified: property.postedByVerified,
                avatarUrl: property.postedByAvatarUrl,
                postedTime: property.postedTime,
              ),

              // Info banner for offer flow (only in unlocked state)
              if (!isLocked && controller.isOfferFromExisting.value) ...[
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: const InfoBanner(
                    message:
                        'Your full location will remain private to the buyer.',
                    type: InfoBannerTypes.info,
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Bottom action button (inside scroll)
              _buildBottomActionButton(),

              SizedBox(height: 24.h), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPropertyImage(PropertyDetails property) {
    final imagePath = property.propertyPhotos.isNotEmpty
        ? property.propertyPhotos.first
        : null;

    return GestureDetector(
      onTap: property.propertyPhotos.isNotEmpty
          ? () => _openPhotoViewer(property, 0)
          : null,
      child: ClipRRect(
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
      ),
    );
  }

  void _openPhotoViewer(PropertyDetails property, int initialIndex) {
    if (property.propertyPhotos.isEmpty) {
      return;
    }
    Get.to(
      () => FullscreenImageViewerPage(
        photos: property.propertyPhotos,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
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

  // ============ LOCKED FEATURES SECTION ============

  Widget _buildLockedFeaturesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.lock, color: AppColors.primary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'Locked Features',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Feature items (non-expandable)
          ...controller.lockedFeatures.map(
            (feature) => _buildLockedFeatureItem(feature),
          ),

          SizedBox(height: 20.h),

          // Unlock button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isUnlocking.value
                  ? null
                  : controller.unlockProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    controller.isUnlocking.value
                        ? 'Processing payment...'
                        : 'Unlock All Features at ৳${controller.unlockAmountDisplay}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Info text
          Center(
            child: Text(
              'Pay one time fee to unlock the above features.\nAll post will be unlocked afterwards',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedFeatureItem(LockedFeature feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: feature.iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(feature.icon, color: feature.iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.grey500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ UNLOCKED FEATURES SECTION ============

  Widget _buildUnlockedFeaturesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.lock_open, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Unlocked Features',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Feature items (expandable)
          _buildExpandableFeature(
            index: 0,
            title: 'Risk & Due Diligence Checklist',
            subtitle: 'Get further verification about this property',
            icon: Icons.checklist_rounded,
            iconColor: AppColors.primary,
            expandedContent: _buildDueDiligenceContent(),
          ),
          _buildExpandableFeature(
            index: 1,
            title: 'Property Video',
            subtitle: 'Get a video tour of the property before buying',
            icon: Icons.videocam_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildVideoContent(),
          ),
          _buildExpandableFeature(
            index: 2,
            title: 'Ownership History',
            subtitle: 'Get to know the connected owners history',
            icon: Icons.history,
            iconColor: AppColors.grey600,
            expandedContent: _buildOwnershipHistoryContent(),
          ),
          _buildExpandableFeature(
            index: 3,
            title: 'Validated Legal Documents',
            subtitle: 'Get to see which documents will be provided',
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildLegalDocumentsContent(),
          ),
          _buildExpandableFeature(
            index: 4,
            title: 'Pentagraph Map',
            subtitle: 'Detailed Mouza map of the area',
            icon: Icons.map_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildPentagraphMapContent(),
          ),
          _buildExpandableFeature(
            index: 5,
            title: 'Services Taken',
            subtitle: 'Get to see which services was taken by the user',
            icon: Icons.miscellaneous_services_outlined,
            iconColor: AppColors.warning,
            expandedContent: _buildServicesTakenContent(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFeature({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget expandedContent,
    bool isLast = false,
  }) {
    return Obx(() {
      final isExpanded = controller.isFeatureExpanded(index);

      return Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
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
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleFeatureExpansion(index),
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 20.sp),
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
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.grey600,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
                child: expandedContent,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDueDiligenceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...controller.dueDiligenceItems.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.success,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grey700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Obx(() {
      final rawUrl = controller.propertyVideoUrl.value?.trim();
      final hasVideo = rawUrl != null && rawUrl.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.grey200),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: hasVideo ? () => _playVideo(rawUrl) : null,
            child: Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasVideo
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: hasVideo
                      ? AppColors.primary.withAlpha(40)
                      : AppColors.grey300,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: hasVideo ? AppColors.primary : AppColors.grey500,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 40.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      hasVideo ? 'Tap to play video' : 'No video available',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: hasVideo ? AppColors.primary : AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _playVideo(String? rawUrl) async {
    if (rawUrl == null || rawUrl.isEmpty) {
      return;
    }

    Uri? uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      Get.snackbar('Video', 'Invalid video URL');
      return;
    }

    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$rawUrl');
    }
    if (uri == null) {
      Get.snackbar('Video', 'Invalid video URL');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Get.snackbar('Video', 'Unable to open video');
    }
  }

  Widget _buildOwnershipHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...controller.ownershipHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final owner = entry.value;
          final isLast = index == controller.ownershipHistory.length - 1;
          final isFirst = index == 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.primary.withAlpha(20)
                          : AppColors.grey100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFirst ? AppColors.primary : AppColors.grey300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: isFirst ? AppColors.primary : AppColors.grey400,
                      size: 18.sp,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40.h, color: AppColors.grey300),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.white : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isFirst
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                          if (owner.period.isNotEmpty)
                            Text(
                              owner.period,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isFirst
                                    ? AppColors.primary
                                    : AppColors.grey500,
                              ),
                            ),
                        ],
                      ),
                      if (owner.isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegalDocumentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...controller.legalDocuments.map(
          (doc) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openDocument(doc),
                    child: Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Documents will be handed over after successful purchase',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.grey500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _openDocument(LegalDocumentItem doc) async {
    final value = doc.url.trim();
    if (value.isEmpty) {
      return;
    }

    final category = doc.category.toUpperCase();
    if (category == 'DEED' || category == 'KHATIAN') {
      Get.to(() => FullscreenImageViewerPage(photos: [value], initialIndex: 0));
      return;
    }

    Uri? uri = Uri.tryParse(value);
    if (uri == null) {
      Get.snackbar('Document', 'Invalid document URL');
      return;
    }

    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$value');
    }

    if (uri == null) {
      Get.snackbar('Document', 'Invalid document URL');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Get.snackbar('Document', 'Unable to open document link');
    }
  }

  Widget _buildPentagraphMapContent() {
    return Obx(() {
      final mapUrl = controller.pentagraphMapUrl.value?.trim();
      final hasMapUrl = mapUrl != null && mapUrl.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.grey200),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: hasMapUrl
                ? () => _openDocument(
                    LegalDocumentItem(
                      title: 'Pentagraph Map',
                      url: mapUrl,
                      category: 'PENTAGRAPH_MAP',
                    ),
                  )
                : null,
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: hasMapUrl
                    ? Image.network(
                        mapUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPentagraphMapFallback();
                        },
                      )
                    : _buildPentagraphMapFallback(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPentagraphMapFallback() {
    return Image.asset(
      'assets/images/Maps/PentaGraphMap.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48.sp, color: AppColors.grey400),
              SizedBox(height: 8.h),
              Text(
                'Pentagraph Map',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
              ),
            ],
          ),
        );
      },
    );
  }

  // Agent images for services
  static const List<String> _agentImages = [
    'assets/images/User_DP/abrar.jpg',
    'assets/images/User_DP/Farhan.jpg',
    'assets/images/User_DP/forhad.jpg',
    'assets/images/User_DP/jahangir.jpg',
    'assets/images/User_DP/rahman.jpg',
    'assets/images/User_DP/sahil.jpg',
  ];

  Widget _buildServicesTakenContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...controller.serviceVerifications.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          final isLast = index == controller.serviceVerifications.length - 1;
          final agentImage = _agentImages[index % _agentImages.length];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 100.h,
                      color: AppColors.grey300,
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.serviceName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          if (service.isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(20),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'ASSIGNED AGENT',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: AppColors.grey200,
                            backgroundImage: AssetImage(agentImage),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.assignedAgent,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                              if (service.agentRole.isNotEmpty)
                                Text(
                                  service.agentRole,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.grey500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ============ BOTTOM ACTION BUTTON ============

  Widget _buildBottomActionButton() {
    return Obx(() {
      final hasRequested = controller.hasRequestedAppointment.value;
      final isOfferFlow = controller.isOfferFromExisting.value;
      final isLocked = controller.isLocked.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasRequested
                    ? null
                    : isOfferFlow && !isLocked
                    ? () => _submitOfferDirectly()
                    : () => _showRequestAppointmentDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasRequested
                      ? AppColors.grey300
                      : AppColors.primary,
                  foregroundColor: hasRequested
                      ? AppColors.grey600
                      : AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBackgroundColor: AppColors.grey300,
                  disabledForegroundColor: AppColors.grey600,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getButtonText(hasRequested, isOfferFlow, isLocked),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!hasRequested) ...[
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 20.sp),
                    ],
                  ],
                ),
              ),
            ),
            if (hasRequested) ...[
              SizedBox(height: 8.h),
              Text(
                isOfferFlow && !isLocked
                    ? 'Your offer has been submitted.'
                    : 'Check appointment section to see the update.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    });
  }

  String _getButtonText(bool hasRequested, bool isOfferFlow, bool isLocked) {
    if (hasRequested) {
      return isOfferFlow && !isLocked
          ? 'Offer Submitted'
          : 'Request for appointment';
    }
    return isOfferFlow && !isLocked
        ? 'Submit Offer'
        : 'Request For Appointment';
  }

  Future<void> _submitOfferDirectly() async {
    final success = await controller.submitOffer();
    if (success) {
      _showOfferSubmittedDialog();
    }
  }

  void _showOfferSubmittedDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => RequestSubmittedDialog(
        property: controller.property.value!,
        onClose: () => Get.back(),
        isOfferFlow: true,
      ),
    );
  }

  void _showRequestAppointmentDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => RequestAppointmentDialog(
        property: controller.property.value!,
        userName: controller.userName.value,
        initialPhone: controller.userPhone.value,
        initialAddress: controller.userAddress.value,
        onSubmit: (phone, address) async {
          final success = await controller.submitAppointmentRequest(
            phone: phone,
            address: address,
          );
          if (success) {
            Get.back();
            _showRequestSubmittedDialog();
          }
          return success;
        },
      ),
    );
  }

  void _showRequestSubmittedDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => RequestSubmittedDialog(
        property: controller.property.value!,
        onClose: () => Get.back(),
      ),
    );
  }
}

/// Request Appointment Dialog
class RequestAppointmentDialog extends StatefulWidget {
  final PropertyDetails property;
  final String userName;
  final String initialPhone;
  final String initialAddress;
  final Future<bool> Function(String phone, String address) onSubmit;

  const RequestAppointmentDialog({
    super.key,
    required this.property,
    required this.userName,
    required this.initialPhone,
    required this.initialAddress,
    required this.onSubmit,
  });

  @override
  State<RequestAppointmentDialog> createState() =>
      _RequestAppointmentDialogState();
}

class _RequestAppointmentDialogState extends State<RequestAppointmentDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await widget.onSubmit(_phoneController.text, _addressController.text);
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildPropertyThumbnail(PropertyDetails property) {
    final imageUrl = property.propertyPhotos.isNotEmpty
        ? property.propertyPhotos.first.trim()
        : '';

    if (imageUrl.isEmpty) {
      return Container(
        width: 60.w,
        height: 60.h,
        color: AppColors.grey200,
        child: Icon(Icons.image, color: AppColors.grey400),
      );
    }

    return Image.network(
      imageUrl,
      width: 60.w,
      height: 60.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60.w,
          height: 60.h,
          color: AppColors.grey200,
          child: Icon(Icons.image, color: AppColors.grey400),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request For Appointment',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: AppColors.grey600,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              Text(
                'By requesting for appointment, you are agreeing to share your details below. You will be notified for appointment soon.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
              ),
              SizedBox(height: 16.h),

              // Property card
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: _buildPropertyThumbnail(property),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                'Price: ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                              Text(
                                '৳ ${property.price}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              _buildSmallTag(
                                property.propertyType,
                                property.propertyTypeColor,
                              ),
                              SizedBox(width: 6.w),
                              if (property.isVerified)
                                _buildSmallTag(
                                  'Verified',
                                  AppColors.success,
                                  icon: Icons.check_circle,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Full Name (read-only)
              _buildLabel('Full Name', isRequired: true),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.userName,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
                ),
              ),
              SizedBox(height: 16.h),

              // Phone Number
              _buildLabel('Phone Number', isRequired: true),
              SizedBox(height: 8.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey400,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
              ),
              SizedBox(height: 16.h),

              // Your Address
              _buildLabel('Your Address', isRequired: true),
              SizedBox(height: 8.h),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey400,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
              ),
              SizedBox(height: 24.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Request for appointment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildSmallTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10.sp, color: AppColors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Request Submitted Dialog
class RequestSubmittedDialog extends StatelessWidget {
  final PropertyDetails property;
  final VoidCallback onClose;
  final bool isOfferFlow;

  const RequestSubmittedDialog({
    super.key,
    required this.property,
    required this.onClose,
    this.isOfferFlow = false,
  });

  Widget _buildPropertyThumbnail() {
    final imageUrl = property.propertyPhotos.isNotEmpty
        ? property.propertyPhotos.first.trim()
        : '';

    if (imageUrl.isEmpty) {
      return Container(
        width: 60.w,
        height: 60.h,
        color: AppColors.grey200,
        child: Icon(Icons.image, color: AppColors.grey400),
      );
    }

    return Image.network(
      imageUrl,
      width: 60.w,
      height: 60.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60.w,
          height: 60.h,
          color: AppColors.grey200,
          child: Icon(Icons.image, color: AppColors.grey400),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: AppColors.grey600, size: 24.sp),
              ),
            ),

            // Success icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 50.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              isOfferFlow ? 'Offer Submitted' : 'Request Submitted',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              isOfferFlow
                  ? 'Your offer post will be visible to the buyer soon.'
                  : 'You will be notified for appointment soon.\nIt may take up to 1-3 business days for reviewing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),

            // Property card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: _buildPropertyThumbnail(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              'Price: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              '৳ ${property.price}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: property.propertyTypeColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                property.propertyType,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            if (property.isVerified)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 10.sp,
                                      color: AppColors.white,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Status
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Pending Admin Review',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
