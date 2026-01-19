import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'properties_controller.dart';
import 'for_sale/for_sale_content_view.dart';
import 'my_posts/my_posts_content_view.dart';
import 'wanted_and_needs/wanted_content_view.dart';

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
        return const ForSaleContentView();
      case 1:
        return const WantedContentView();
      case 2:
        return _buildMyPostsContent();
      default:
        return const ForSaleContentView();
    }
  }

  Widget _buildMyPostsContent() {
    return const MyPostsContentView();
  }
}
