import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'properties_controller.dart';

/// Properties listing screen - Full version with Scaffold
/// Use this for standalone navigation (not within shell)
class PropertiesView extends GetView<PropertiesController> {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: const PropertiesContentView()),
    );
  }
}

/// Properties content view - Content only, no Scaffold
/// Used within MainShellWrapper for tab-based navigation
class PropertiesContentView extends GetView<PropertiesController> {
  const PropertiesContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar with filter
        _buildSearchBar(),

        SizedBox(height: 12.h),

        // Tab bar
        _buildTabBar(),

        SizedBox(height: 12.h),

        // Content based on selected tab
        Expanded(child: Obx(() => _buildTabContent())),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.grey500, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location, area',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey900,
                      ),
                      onSubmitted: (_) => controller.search(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Filter button
          GestureDetector(
            onTap: controller.openFilter,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.tune, color: AppColors.grey700, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTab(0, 'For Sale')),
            Expanded(child: _buildTab(1, 'Wanted/Needs')),
            Expanded(child: _buildTab(2, 'My Posts')),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.grey600,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (controller.selectedTabIndex.value) {
      case 0:
        return _buildForSaleContent();
      case 1:
        return _buildWantedContent();
      case 2:
        return _buildMyPostsContent();
      default:
        return _buildForSaleContent();
    }
  }

  Widget _buildForSaleContent() {
    return Column(
      children: [
        // Location filter chip
        _buildLocationChip(),

        SizedBox(height: 8.h),

        // Results header with count and sort
        _buildResultsHeader(),

        SizedBox(height: 12.h),

        // Property list
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: Obx(() {
              if (controller.propertiesForSale.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.propertiesForSale.length,
                itemBuilder: (context, index) {
                  return _buildPropertyCard(
                    controller.propertiesForSale[index],
                  );
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

  Widget _buildResultsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Showing ${controller.totalProperties.value} Properties',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.toggleSort,
            child: Row(
              children: [
                Obx(
                  () => Text(
                    controller.sortBy.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(PropertyListing property) {
    return GestureDetector(
      onTap: () => controller.goToPropertyDetails(property),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image with tags
            Stack(
              children: [
                // Property image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: property.imageUrl != null
                      ? Image.asset(
                          property.imageUrl!,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(
                              property.propertyType,
                            );
                          },
                        )
                      : _buildImagePlaceholder(property.propertyType),
                ),

                // Tags
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Row(
                    children: [
                      // Property Type Tag
                      _buildTag(
                        text: property.propertyTypeLabel,
                        backgroundColor: property.propertyTypeColor,
                        textColor: AppColors.white,
                      ),
                      SizedBox(width: 6.w),

                      // Post Type Tag
                      _buildTag(
                        text: property.postTypeLabel,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.primary,
                      ),

                      if (property.isVerified) ...[
                        SizedBox(width: 6.w),
                        // Verified Tag
                        _buildTag(
                          text: 'Verified',
                          backgroundColor: AppColors.success,
                          textColor: AppColors.white,
                          icon: Icons.check_circle,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Property Details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Location
                  Row(
                    children: [
                      Image.asset(
                        'assets/Logos/Location.png',
                        width: 16.w,
                        height: 16.h,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.location_on,
                            size: 16.sp,
                            color: AppColors.primary,
                          );
                        },
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Price and View Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳ ${property.price}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey500,
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
    );
  }

  Widget _buildTag({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(PropertyType propertyType) {
    Color color1, color2;
    IconData icon;

    switch (propertyType) {
      case PropertyType.plainLand:
        color1 = const Color(0xFF8BC34A);
        color2 = const Color(0xFF689F38);
        icon = Icons.landscape;
        break;
      case PropertyType.waterLand:
        color1 = const Color(0xFF4FC3F7);
        color2 = const Color(0xFF0288D1);
        icon = Icons.water;
        break;
      case PropertyType.flat:
        color1 = const Color(0xFF90CAF9);
        color2 = const Color(0xFF42A5F5);
        icon = Icons.apartment;
        break;
    }

    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 60.sp, color: AppColors.white.withAlpha(100)),
      ),
    );
  }

  Widget _buildWantedContent() {
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
              await controller.loadWantedPosts();
            },
            child: Obx(() {
              final posts = controller.wantedSubTabIndex.value == 0
                  ? controller.allWantedPosts
                  : controller.filteredOfferedPosts;

              if (posts.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _buildWantedPostCard(posts[index]);
                },
              );
            }),
          ),
        ),
      ],
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
                  color: isSelected ? AppColors.primary : AppColors.grey200,
                  borderRadius: BorderRadius.circular(20.r),
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
                  color: isSelected ? AppColors.primary : AppColors.grey200,
                  borderRadius: BorderRadius.circular(20.r),
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
    final bool isHighlighted =
        showOfferedStatus &&
        post.offerStatus == OfferStatus.buyerAcceptedAppointment;

    return GestureDetector(
      onTap: () => controller.goToLandWantedDetails(post.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isHighlighted
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
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
            // Title and arrow
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.onIHaveThisProperty(post),
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

  Widget _buildMyPostsContent() {
    return _buildPlaceholderContent(
      'My Posts',
      'Manage your listings',
      Icons.article_outlined,
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

  Widget _buildPlaceholderContent(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
          ),
          SizedBox(height: 8.h),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.grey400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
