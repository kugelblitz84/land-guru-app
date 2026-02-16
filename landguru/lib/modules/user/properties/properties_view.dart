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
    return DefaultTabController(
      length: 3,
      initialIndex: controller.selectedTabIndex.value,
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: 12.h),
          _buildTabBar(),
          SizedBox(height: 12.h),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Obx(
                  () => controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : const ForSaleContentView(),
                ),
                const WantedContentView(),
                const MyPostsContentView(),
              ],
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Container(
        height: 45.h,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TabBar(
          onTap: controller.changeTab,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.grey600,
          labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'For Sale'),
            Tab(text: 'Wanted/Needs'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
    );
  }
}
