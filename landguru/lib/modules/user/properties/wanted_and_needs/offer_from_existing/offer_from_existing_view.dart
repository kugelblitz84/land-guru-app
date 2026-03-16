import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../properties_controller.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/properties_search_filter_bar.dart';
import 'offer_from_existing_controller.dart';

/// Offer from Existing - Select from active listings to offer
class OfferFromExistingView extends GetView<OfferFromExistingController> {
  const OfferFromExistingView({super.key});

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
        centerTitle: true,
        title: Text(
          'Offer From Existing',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // Search bar with filter
                _buildSearchBar(),

                SizedBox(height: 12.h),

                // Location text
                _buildLocationText(),

                SizedBox(height: 12.h),

                // Results header with count and sort
                _buildResultsHeader(),

                SizedBox(height: 12.h),

                // Active status chip
                _buildStatusChip(),

                SizedBox(height: 16.h),

                // Info banner
                const InfoBanner(
                  message:
                      'Your full location will remain private to the buyer.',
                  type: InfoBannerTypes.info,
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Property list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.activeProperties.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.activeProperties.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.activeProperties.length,
                  itemBuilder: (context, index) {
                    return _buildPropertyCard(
                      controller.activeProperties[index],
                    );
                  },
                ),
              );
            }),
          ),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return PropertiesSearchFilterBar(
      searchController: controller.searchController,
      onSearchChanged: controller.updateSearch,
      onSearchSubmitted: (_) => controller.search(),
      onFilterTap: controller.openFilterSheet,
      inputBackgroundColor: AppColors.grey100,
      buttonBackgroundColor: AppColors.grey100,
      showShadow: false,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildLocationText() {
    return GestureDetector(
      onTap: controller.openLocationPicker,
      child: Obx(
        () => Text(
          controller.selectedLocation.value,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.grey600,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
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
        Obx(
          () => PopupMenuButton<String>(
            onSelected: controller.changeSortBy,
            offset: Offset(0, 30.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            itemBuilder: (context) {
              return controller.sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey700,
                    ),
                  ),
                );
              }).toList();
            },
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        'Active',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(PropertyListing property) {
    return Obx(() {
      final isSelected = controller.isPropertySelected(property.id);

      return GestureDetector(
        onTap: () => controller.viewPropertyDetails(property),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
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

                  // Selection checkbox
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () =>
                          controller.togglePropertySelection(property.id),
                      child: Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 18.sp,
                              )
                            : null,
                      ),
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
    });
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'No active properties',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create a sell post first to offer',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.submitOffer,
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
                          'Submit',
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
    );
  }
}
