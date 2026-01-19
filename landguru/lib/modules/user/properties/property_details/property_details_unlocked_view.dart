import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/info_banner.dart';
import '../widgets/metrics_conversion_row.dart';
import 'models/property_details_models.dart';
import 'property_details_controller.dart';
import 'property_details_locked_view.dart';
import 'widgets/property_details_widgets.dart';

/// Property Details - Unlocked View (after paying to unlock)
class PropertyDetailsUnlockedView extends GetView<PropertyDetailsController> {
  const PropertyDetailsUnlockedView({super.key});

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

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Image
                    _buildPropertyImage(property),

                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Title and Price
                          PropertyTitleSection(property: property),

                          SizedBox(height: 12.h),

                          // Tags
                          PropertyTagsSection(
                            property: property,
                            isLocked: false,
                          ),

                          SizedBox(height: 16.h),

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
                          Obx(() {
                            final conversions = controller.getAllConversions(
                              property.sellableLandAmount,
                            );
                            final convertedValue = controller
                                .getConvertedLandAmount(
                                  property.sellableLandAmount,
                                );
                            final currentUnit =
                                controller.selectedLandUnit.value.label;

                            // Build conversions map with labels
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

                          SizedBox(height: 16.h),

                          // Plot Size
                          Obx(() {
                            final conversions = controller.getAllConversions(
                              property.plotSize,
                            );
                            final convertedValue = controller
                                .getConvertedLandAmount(property.plotSize);
                            final currentUnit =
                                controller.selectedLandUnit.value.label;

                            // Build conversions map with labels
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

                          SizedBox(height: 16.h),

                          // Distance from Road
                          PropertyDetailRow(
                            imageAsset: 'assets/Logos/DistanceFromRoad.png',
                            label: 'Distance from Road',
                            value: property.distanceFromRoad,
                          ),

                          SizedBox(height: 20.h),

                          // Land Shape
                          const LandShapeSection(),

                          SizedBox(height: 20.h),

                          // Property Photos
                          PropertyPhotosSection(
                            photos: property.propertyPhotos,
                          ),

                          SizedBox(height: 24.h),

                          // Unlocked Features Section
                          _buildUnlockedFeaturesSection(),

                          SizedBox(height: 24.h),

                          // How to buy section
                          const HowToBuySection(),

                          SizedBox(height: 24.h),

                          // Posted By section
                          PostedBySection(
                            name: property.postedBy,
                            isVerified: property.isVerified,
                            postedTime: property.postedTime,
                          ),

                          SizedBox(height: 100.h), // Space for bottom button
                        ],
                      ),
                    ),
                    if (controller.isOfferFromExisting.value) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: const InfoBanner(
                          message:
                              'Your full location will remain private to the buyer.',
                          type: InfoBannerType.info,
                        ),
                      ),
                      //SizedBox(height: 12.h),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action button
            _buildBottomActionButton(),
          ],
        );
      }),
    );
  }

  Widget _buildPropertyImage(PropertyDetails property) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: property.propertyPhotos.isNotEmpty
            ? Image.asset(
                property.propertyPhotos.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
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

  Widget _buildUnlockedFeaturesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.lock_open, color: AppColors.success, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Unlocked Features',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey600,
                size: 24.sp,
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
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            // Header (always visible)
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

            // Expanded content
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
        ...controller.dueDiligenceItems.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
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
          );
        }),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 8.h),
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
              // Timeline indicator
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
              // Owner info card
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
        ...controller.legalDocuments.map((doc) {
          return Padding(
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
                  child: Text(
                    doc,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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

  Widget _buildPentagraphMapContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: Image.asset(
              'assets/images/Maps/PentaGraphMap.png',
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
                        'Pentagraph Map',
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

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.w,
                        height: 8.h,
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
              // Service card
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
                      // Service name and verified badge
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
                      // Assigned agent label
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
                      // Agent info with avatar
                      Row(
                        children: [
                          // Agent avatar
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: AppColors.grey200,
                            child: Icon(
                              Icons.person,
                              color: AppColors.grey500,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          // Agent name and role
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

  Widget _buildBottomActionButton() {
    return Obx(() {
      final hasRequested = controller.hasRequestedAppointment.value;
      final isOfferFlow = controller.isOfferFromExisting.value;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info banner for offer flow (shown before submit button)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasRequested
                    ? null
                    : isOfferFlow
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
                      hasRequested
                          ? (isOfferFlow
                                ? 'Offer Submitted'
                                : 'Request for appointment')
                          : (isOfferFlow
                                ? 'Submit Offer'
                                : 'Request For Appointment'),
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
                isOfferFlow
                    ? 'Your offer has been submitted.'
                    : 'Check appointment section to see the update.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Submit offer directly (for Offer from Existing flow)
  /// Skips the appointment popup and goes directly to success dialog
  Future<void> _submitOfferDirectly() async {
    final success = await controller.submitOffer();
    if (success) {
      _showOfferSubmittedDialog();
    }
  }

  /// Show offer submitted dialog (different from request submitted)
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
            Get.back(); // Close the request dialog first
            _showRequestSubmittedDialog(); // Then show success dialog
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
