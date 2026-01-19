import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../properties_controller.dart';

/// For Sale tab content view
/// Displays property listings that are for sale
class ForSaleContentView extends GetView<PropertiesController> {
  const ForSaleContentView({super.key});

  @override
  Widget build(BuildContext context) {
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
