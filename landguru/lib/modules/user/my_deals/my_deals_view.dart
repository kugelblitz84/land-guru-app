import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/theme/app_colors.dart';
import 'my_deals_controller.dart';
import 'models/deal_models.dart';

/// User My Deals screen with tabs - Full version with Scaffold
class MyDealsView extends GetView<MyDealsController> {
  const MyDealsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: MyDealsContentView()),
    );
  }
}

/// My Deals content view - Content only, no Scaffold
/// Used within MainShellWrapper for tab-based navigation
class MyDealsContentView extends StatelessWidget {
  const MyDealsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<MyDealsController>()) {
      Get.put(MyDealsController());
    }
    final controller = Get.find<MyDealsController>();

    return Column(
      children: [
        SizedBox(height: 8.h),

        // Stats cards
        _buildStatsCards(controller),

        SizedBox(height: 16.h),

        // Primary tabs (Sold / Bought)
        _buildPrimaryTabs(controller),

        SizedBox(height: 12.h),

        // Filter dropdowns
        _buildFilterRow(controller),

        SizedBox(height: 12.h),

        // Deals list
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final deals = controller.filteredDeals;

            if (deals.isEmpty) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  return _buildDealCard(controller, deals[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatsCards(MyDealsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final isSold = controller.selectedTab.value == DealTab.sold;
        return Row(
          children: [
            // Property Sold / Bought count
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      isSold ? Icons.sell : Icons.shopping_bag,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isSold ? 'Property Sold' : 'Property Bought',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isSold
                          ? '${controller.stats.value.propertySold}'
                          : '${controller.stats.value.propertyBought}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Earned / Spent amount
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.success,
                      size: 24.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isSold ? 'Earned' : 'Spent',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '৳ ${isSold ? controller.stats.value.totalEarned : controller.stats.value.totalSpent}',
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
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPrimaryTabs(MyDealsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Obx(
          () => Row(
            children: [
              // Sold tab
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.changeTab(DealTab.sold),
                  child: Container(
                    margin: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == DealTab.sold
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'Sold',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTab.value == DealTab.sold
                              ? AppColors.white
                              : AppColors.grey600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bought tab
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.changeTab(DealTab.bought),
                  child: Container(
                    margin: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == DealTab.bought
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'Bought',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTab.value == DealTab.bought
                              ? AppColors.white
                              : AppColors.grey600,
                        ),
                      ),
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

  Widget _buildFilterRow(MyDealsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Sort by dropdown
          Obx(
            () => _buildFilterDropdown(
              label: 'Sort by:',
              value: controller.sortBy.value.label,
              onTap: () => _showSortByMenu(controller),
            ),
          ),
          SizedBox(width: 12.w),
          // Type filter dropdown
          Obx(
            () => _buildFilterDropdown(
              label: 'Type:',
              value: controller.typeFilter.value.label,
              onTap: () => _showTypeFilterMenu(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ',
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_downward, size: 14.sp, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showSortByMenu(MyDealsController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 12.h),
            ...DealSortBy.values.map((option) {
              final isSelected = controller.sortBy.value == option;
              return ListTile(
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.grey700,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary, size: 20.sp)
                    : null,
                onTap: () {
                  controller.changeSortBy(option);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showTypeFilterMenu(MyDealsController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Type',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 12.h),
            ...DealTypeFilter.values.map((option) {
              final isSelected = controller.typeFilter.value == option;
              return ListTile(
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.grey700,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary, size: 20.sp)
                    : null,
                onTap: () {
                  controller.changeTypeFilter(option);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDealCard(MyDealsController controller, Deal deal) {
    return GestureDetector(
      onTap: () => controller.goToDealDetails(deal),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: deal.propertyImageUrl != null
                  ? Image.asset(
                      deal.propertyImageUrl!,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(deal.propertyType);
                      },
                    )
                  : _buildImagePlaceholder(deal.propertyType),
            ),
            SizedBox(width: 10.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.propertyTitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    deal.postId,
                    style: TextStyle(fontSize: 10.sp, color: AppColors.grey500),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'Sold At: ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '৳ ${deal.soldPrice}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 3.h,
                    children: [
                      _buildTag(
                        text: deal.propertyTypeLabel,
                        backgroundColor: deal.propertyTypeColor,
                        textColor: AppColors.white,
                      ),
                      _buildTag(
                        text: deal.status.label,
                        backgroundColor: deal.status.backgroundColor,
                        textColor: deal.status.textColor,
                        showCheckIcon: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Sold: ${deal.dealTimeAgo}',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    bool showCheckIcon = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCheckIcon) ...[
            Icon(Icons.check_circle, size: 10.sp, color: textColor),
            SizedBox(width: 3.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9.sp,
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
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Icon(icon, size: 28.sp, color: AppColors.white.withAlpha(180)),
      ),
    );
  }

  Widget _buildEmptyState(MyDealsController controller) {
    final isSold = controller.selectedTab.value == DealTab.sold;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSold ? Icons.sell_outlined : Icons.shopping_bag_outlined,
            size: 64.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            isSold ? 'No Sold Properties' : 'No Bought Properties',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSold
                ? 'Properties you sell will appear here'
                : 'Properties you buy will appear here',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
