import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'properties_controller.dart';
import 'for_sale/for_sale_content_view.dart';
import 'my_posts/my_posts_content_view.dart';
import 'wanted_and_needs/wanted_content_view.dart';
import 'widgets/properties_search_filter_bar.dart';

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
    return PropertiesSearchFilterBar(
      searchController: controller.searchController,
      onSearchChanged: controller.updateSearch,
      onSearchSubmitted: (_) => controller.search(),
      onFilterTap: controller.openFilter,
      inputBackgroundColor: AppColors.white,
      buttonBackgroundColor: AppColors.white,
      showShadow: true,
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
