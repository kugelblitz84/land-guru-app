import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import 'buy_posts_controller.dart';
import 'models/buy_post_models.dart';
import 'widgets/buy_post_offers_popup.dart';

/// Buy Posts content view with filter chips and post cards
class BuyPostsContentView extends StatelessWidget {
  const BuyPostsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<BuyPostsController>()) {
      Get.put(BuyPostsController());
    }
    final controller = Get.find<BuyPostsController>();

    return Column(
      children: [
        // Filter chips
        _buildFilterChips(controller),

        SizedBox(height: 12.h),

        // Results header
        _buildResultsHeader(controller),

        SizedBox(height: 12.h),

        // Posts list
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.filteredBuyPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredBuyPosts.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.filteredBuyPosts.length,
                itemBuilder: (context, index) {
                  return _buildBuyPostCard(
                    context,
                    controller,
                    controller.filteredBuyPosts[index],
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuyPostsController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: controller.filterOptions.map((filter) {
            final isSelected = controller.currentFilter.value == filter;
            final badgeCount = controller.getBadgeCount(filter);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: GestureDetector(
                onTap: () => controller.changeFilter(filter),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.grey600,
                        ),
                      ),
                      if (badgeCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(BuyPostsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Showing ${controller.filteredBuyPosts.length} Properties',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
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
      ),
    );
  }

  Widget _buildBuyPostCard(
    BuildContext context,
    BuyPostsController controller,
    BuyPost post,
  ) {
    // Determine border color based on status and offers
    Border? cardBorder;
    if (post.cardBorderColor != null) {
      cardBorder = Border.all(color: post.cardBorderColor!, width: 2);
    }

    return GestureDetector(
      onTap: () {
        if (post.hasOffers) {
          BuyPostOffersPopup.show(context, controller, post);
        }
      },
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

            // Post ID and Posted time
            Text(
              post.postId,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
            Text(
              '${post.timestampPrefix} ${post.timestamp}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),

            SizedBox(height: 12.h),

            // Property details
            _buildDetailRow(
              imageAsset: 'assets/Logos/Location.png',
              label: 'Preferred Location',
              value: post.preferredLocation,
              isMultiLine: true,
            ),

            SizedBox(height: 10.h),

            _buildDetailRow(
              imageAsset: 'assets/Logos/flat.png',
              label: 'Property Type',
              value: post.propertyTypeLabel,
            ),

            SizedBox(height: 10.h),

            _buildDetailRow(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Required Land Size',
              value: post.requiredLandSize,
            ),

            SizedBox(height: 10.h),

            _buildDetailRow(
              imageAsset: 'assets/Logos/Land&plotSize.png',
              label: 'Required Plot Size',
              value: post.requiredPlotSize,
            ),

            SizedBox(height: 10.h),

            _buildDetailRow(
              imageAsset: 'assets/Logos/DistanceFromRoad.png',
              label: 'Distance from Road',
              value: post.distanceFromRoad,
            ),

            SizedBox(height: 10.h),

            _buildDetailRow(
              imageAsset: 'assets/Logos/Budget Range.png',
              label: 'Budget Range',
              value: post.budgetRange,
            ),

            SizedBox(height: 16.h),

            // Status section
            _buildStatusSection(controller, post),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    String? imageAsset,
    IconData? fallbackIcon,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                fallbackIcon ?? Icons.info,
                size: 18.sp,
                color: AppColors.primary,
              );
            },
          )
        else
          Icon(
            fallbackIcon ?? Icons.info,
            size: 18.sp,
            color: AppColors.primary,
          ),
        SizedBox(width: 10.w),
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

  Widget _buildStatusSection(BuyPostsController controller, BuyPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: post.statusColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                post.statusLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),

            // Offers received / View Appointment / Pending Admin Review
            if (post.showViewAppointment)
              GestureDetector(
                onTap: () => controller.viewAppointment(post),
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
              )
            else if (post.showPendingAdminReview)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
              )
            else
              // Offers Received button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: post.hasOffers
                      ? AppColors.error.withAlpha(20)
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: post.hasOffers ? AppColors.error : AppColors.grey300,
                  ),
                ),
                child: Text(
                  '${post.offersCount} Offers Received',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: post.hasOffers ? AppColors.error : AppColors.grey500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Buy Posts',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create a buy post to find properties',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
