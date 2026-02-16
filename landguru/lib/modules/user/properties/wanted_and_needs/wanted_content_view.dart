import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../properties_controller.dart';
import 'land_wanted_offer_popup.dart';
import 'offered_by_you_popup.dart';

/// Wanted/Needs tab content view
/// Displays land wanted/needs posts from buyers
class WantedContentView extends GetView<PropertiesController> {
  const WantedContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Location filter chip
        _buildLocationChip(),

        SizedBox(height: 8.h),

        // Sub-tabs: All / Offered by you
        _buildWantedSubTabs(),

        SizedBox(height: 8.h),

        // Results header
        _buildWantedResultsHeader(),

        SizedBox(height: 12.h),

        // Wanted posts list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.loadWantedPosts(forceRefresh: true);
            },
            child: Obx(() {
              final isAllTab = controller.wantedSubTabIndex.value == 0;
              final posts = isAllTab
                  ? controller.allWantedPosts
                  : controller.filteredOfferedPosts;

              if (posts.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount:
                    posts.length +
                    (isAllTab && controller.isLoadingMoreWanted.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (isAllTab && index == posts.length - 1) {
                    controller.loadMoreWantedIfNeeded();
                  }

                  return _buildWantedPostCard(posts[index]);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: controller.openLocationPicker,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(
            () => Text(
              controller.selectedLocation.value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.grey600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWantedSubTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // All tab
          Obx(() {
            final isSelected = controller.wantedSubTabIndex.value == 0;
            return GestureDetector(
              onTap: () => controller.changeWantedSubTab(0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ),
            );
          }),

          SizedBox(width: 8.w),

          // Offered by you tab with badge
          Obx(() {
            final isSelected = controller.wantedSubTabIndex.value == 1;
            return GestureDetector(
              onTap: () => controller.changeWantedSubTab(1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Offered by you',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.grey700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    // Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white.withAlpha(200)
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Obx(
                        () => Text(
                          '${controller.offeredByYouCount.value}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWantedResultsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Showing ${controller.wantedSubTabIndex.value == 0 ? controller.totalWantedPosts.value : controller.filteredOfferedPosts.length} Properties',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Obx(() {
            // Different behavior for All tab vs Offered by you tab
            if (controller.wantedSubTabIndex.value == 0) {
              // All tab - regular sort toggle
              return GestureDetector(
                onTap: controller.toggleSort,
                child: Row(
                  children: [
                    Text(
                      controller.sortBy.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_downward,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            } else {
              // Offered by you tab - filter popup menu
              return PopupMenuButton<String>(
                onSelected: controller.changeOfferedFilter,
                offset: Offset(0, 30.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                itemBuilder: (context) {
                  return controller.offeredFilterOptions.map((option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  children: [
                    Text(
                      controller.offeredFilterBy.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_downward,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildWantedPostCard(LandWantedPost post) {
    final bool showOfferedStatus =
        controller.wantedSubTabIndex.value == 1 && post.hasOffered;

    // Determine border color based on offer status
    Border? cardBorder;
    if (showOfferedStatus) {
      if (post.offerStatus == OfferStatus.buyerAcceptedAppointment) {
        // Red border - buyer and admin accepted (view appointment showing)
        cardBorder = Border.all(color: AppColors.error, width: 2);
      } else if (post.offerStatus == OfferStatus.buyerAcceptedPendingAdmin) {
        // Green border - buyer accepted, pending admin approval
        cardBorder = Border.all(color: AppColors.success, width: 2);
      }
    }

    return GestureDetector(
      onTap: showOfferedStatus
          ? () => OfferedByYouPopup.show(Get.context!, post)
          : null, // Disabled for All tab - use "I have this property" button instead
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: cardBorder,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and arrow (only show arrow for Offered by you tab)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
                if (showOfferedStatus)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.grey400,
                    size: 24.sp,
                  ),
              ],
            ),

            SizedBox(height: 4.h),

            // Posted by info
            Text(
              post.postedBy,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
            Text(
              'Posted: ${post.postedTime}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
            Text(
              post.postId,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),

            SizedBox(height: 12.h),

            // Property details
            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/Location.png',
              label: 'Preferred Location',
              value: post.preferredLocation,
              isMultiLine: true,
            ),

            SizedBox(height: 10.h),

            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/flat.png',
              label: 'Property Type',
              value: post.propertyType,
            ),

            SizedBox(height: 10.h),

            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Required Land Size',
              value: post.requiredLandSize,
            ),

            SizedBox(height: 10.h),

            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Required Plot Size',
              value: post.requiredPlotSize,
            ),

            SizedBox(height: 10.h),

            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/DistanceFromRoad.png',
              label: 'Distance from Road',
              value: post.distanceFromRoad,
            ),

            SizedBox(height: 10.h),

            _buildWantedDetailRow(
              imageAsset: 'assets/Logos/Budget Range.png',
              label: 'Budget Range',
              value: post.budgetRange,
            ),

            // Status section (only for Offered by you tab)
            if (showOfferedStatus) ...[
              SizedBox(height: 16.h),
              Divider(color: AppColors.grey200, height: 1),
              SizedBox(height: 12.h),

              // Status label
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 8.h),

              // Status badges - row with space between
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Primary status badge (left side)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: post.offerStatusColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      post.offerStatusLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  // Secondary action (right side)
                  // View Appointment button (buyer accepted + appointment)
                  if (post.showViewAppointment)
                    GestureDetector(
                      onTap: () => controller.onViewAppointment(post),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'View Appointment',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),

                  // Pending Admin Review (buyer accepted + pending admin)
                  if (post.showPendingAdminReview)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: AppColors.grey400),
                      ),
                      child: Text(
                        'Pending Admin Review',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
              // "I have this property" button (only for All tab)
              SizedBox(height: 16.h),
              Builder(
                builder: (context) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => LandWantedOfferPopup.show(context, post),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'I have this property',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWantedDetailRow({
    IconData? icon,
    Color? iconColor,
    required String label,
    required String value,
    bool isMultiLine = false,
    String? labelPrefix,
    String? imageAsset,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // Icon with optional prefix or image asset
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                icon ?? Icons.info,
                size: 18.sp,
                color: iconColor ?? AppColors.primary,
              );
            },
          )
        else if (labelPrefix != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withAlpha(30),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labelPrefix,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
          )
        else
          Icon(
            icon ?? Icons.info,
            size: 18.sp,
            color: iconColor ?? AppColors.primary,
          ),

        SizedBox(width: 10.w),

        // Label and value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
                maxLines: isMultiLine ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'No properties found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
