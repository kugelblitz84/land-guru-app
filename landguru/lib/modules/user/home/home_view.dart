import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'home_controller.dart';

/// User Home/Dashboard screen
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Header Section
                          _buildHeader(),

                          SizedBox(height: 24.h),

                          // Quick Action Cards
                          _buildQuickActionCards(),

                          SizedBox(height: 16.h),

                          // Stats Cards
                          _buildStatsCards(),

                          SizedBox(height: 24.h),

                          // Featured Properties Section
                          _buildFeaturedPropertiesSection(),

                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Header with user avatar, welcome text, and notification icon
  Widget _buildHeader() {
    return Row(
      children: [
        // User Avatar with online indicator
        Stack(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withAlpha(150),
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: Icon(Icons.person, color: AppColors.white, size: 28.sp),
            ),
            // Online indicator
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 14.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),

        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
              ),
              Obx(
                () => Text(
                  '${controller.userName.value}!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notification icon
        GestureDetector(
          onTap: controller.goToNotifications,
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.grey900,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  /// Quick action cards - Sell Property and Request To Buy
  Widget _buildQuickActionCards() {
    return Row(
      children: [
        // Sell Property Card
        Expanded(
          child: _buildActionCard(
            title: 'Sell Property',
            subtitle: 'List your asset today',
            icon: Icons.sell_outlined,
            gradientColors: [const Color(0xFF4A7BF7), const Color(0xFF3B6CF5)],
            onTap: controller.goToCreateSellPost,
          ),
        ),
        SizedBox(width: 12.w),

        // Request To Buy Card
        Expanded(
          child: _buildActionCard(
            title: 'Request To Buy',
            subtitle: 'Find your dream space',
            icon: Icons.location_on_outlined,
            gradientColors: [const Color(0xFF4CD964), const Color(0xFF34C759)],
            onTap: controller.goToCreateBuyPost,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.white, size: 22.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.white.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stats cards - Active Posts and Upcoming Meetings
  Widget _buildStatsCards() {
    return Row(
      children: [
        // Active Posts
        Expanded(
          child: _buildStatsCard(
            icon: Icons.article_outlined,
            label: 'Active Posts',
            count: controller.activePostsCount,
            onTap: controller.goToMyPosts,
          ),
        ),
        SizedBox(width: 12.w),

        // Upcoming Meetings
        Expanded(
          child: _buildStatsCard(
            icon: Icons.schedule_outlined,
            label: 'Upcoming Meetings',
            count: controller.upcomingMeetingsCount,
            iconColor: AppColors.error,
            onTap: controller.goToAppointments,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String label,
    required RxInt count,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      '${count.value}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 20.sp),
          ],
        ),
      ),
    );
  }

  /// Featured Properties Section
  Widget _buildFeaturedPropertiesSection() {
    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Properties',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            GestureDetector(
              onTap: controller.goToAllFeaturedProperties,
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Property cards
        Obx(
          () => Column(
            children: controller.featuredProperties
                .map((property) => _buildPropertyCard(property))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(FeaturedProperty property) {
    return GestureDetector(
      onTap: () => controller.goToPropertyDetails(property.id),
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
                // Property image or gradient placeholder
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
                        text: property.propertyType,
                        backgroundColor: _getPropertyTypeColor(
                          property.propertyType,
                        ),
                        textColor: AppColors.white,
                      ),
                      SizedBox(width: 8.w),

                      // Post Type Tag
                      _buildTag(
                        text: property.postType,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.primary,
                      ),

                      if (property.isVerified) ...[
                        SizedBox(width: 8.w),
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
                  SizedBox(height: 8.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        property.location,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.grey600,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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

  /// Build gradient placeholder when image is not available
  Widget _buildImagePlaceholder(String propertyType) {
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(gradient: _getPropertyGradient(propertyType)),
      child: Center(
        child: Icon(
          _getPropertyIcon(propertyType),
          size: 60.sp,
          color: AppColors.white.withAlpha(100),
        ),
      ),
    );
  }

  LinearGradient _getPropertyGradient(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'plain land':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF8BC34A), const Color(0xFF689F38)],
        );
      case 'flat':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF90CAF9), const Color(0xFF42A5F5)],
        );
      case 'water land':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF4FC3F7), const Color(0xFF0288D1)],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        );
    }
  }

  IconData _getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'plain land':
        return Icons.landscape;
      case 'flat':
        return Icons.apartment;
      case 'water land':
        return Icons.water;
      default:
        return Icons.home;
    }
  }

  Color _getPropertyTypeColor(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'plain land':
        return const Color(0xFF2E7D32);
      case 'flat':
        return AppColors.primary;
      case 'water land':
        return const Color(0xFF0288D1);
      default:
        return AppColors.primary;
    }
  }
}
