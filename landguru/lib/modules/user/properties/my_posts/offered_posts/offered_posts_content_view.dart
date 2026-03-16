import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/enums/property_type.dart';
import '../../../../../core/theme/app_colors.dart';
import 'offered_posts_controller.dart';
import 'models/offered_post_models.dart';

/// Offered Posts content view with filter chips and post cards
class OfferedPostsContentView extends StatelessWidget {
  const OfferedPostsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<OfferedPostsController>()) {
      Get.put(OfferedPostsController());
    }
    final controller = Get.find<OfferedPostsController>();

    return Column(
      children: [
        // Results header with filter dropdown
        _buildResultsHeader(controller),

        SizedBox(height: 12.h),

        // Posts list
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.filteredOfferedPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredOfferedPosts.isEmpty) {
              return _buildRefreshableEmptyState(
                onRefresh: controller.refresh,
                child: _buildEmptyState(),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount:
                    controller.filteredOfferedPosts.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredOfferedPosts.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (index == controller.filteredOfferedPosts.length - 1) {
                    controller.loadMoreIfNeeded();
                  }

                  return _buildOfferedPostCard(
                    context,
                    controller,
                    controller.filteredOfferedPosts[index],
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(OfferedPostsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Showing ${controller.filteredOfferedPosts.length} Properties',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
          ),
          // Filter dropdown (All ↓)
          Obx(
            () => PopupMenuButton<String>(
              onSelected: controller.changeFilter,
              offset: Offset(0, 30.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              itemBuilder: (context) {
                return controller.filterOptions.map((option) {
                  final isSelected = controller.currentFilter.value == option;
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey700,
                      ),
                    ),
                  );
                }).toList();
              },
              child: Row(
                children: [
                  Text(
                    controller.currentFilter.value,
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

  Widget _buildOfferedPostCard(
    BuildContext context,
    OfferedPostsController controller,
    OfferedPost post,
  ) {
    // Green border for buyer accepted offers
    final bool isAccepted = post.status == OfferedPostStatus.buyerAccepted;
    final Border? cardBorder = isAccepted
        ? Border.all(color: AppColors.success, width: 2)
        : null;

    return GestureDetector(
      onTap: () => controller.goToOfferDetails(post),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
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
        child: Row(
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildPostImage(post),
            ),
            SizedBox(width: 12.w),

            // Post details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.propertyTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),

                  // Post ID
                  Text(
                    post.postId,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                  SizedBox(height: 4.h),

                  // Asking Price
                  Row(
                    children: [
                      Text(
                        'Asking Price: ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '৳ ${post.propertyPrice}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Tags row
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      // Property type tag
                      _buildTag(
                        text: post.propertyTypeLabel,
                        backgroundColor: post.propertyTypeColor,
                        textColor: AppColors.white,
                      ),

                      // Status tag - "Buyer accepted your offer" or "Pending Buyer Review"
                      if (isAccepted)
                        _buildTag(
                          text: 'Buyer accepted your offer',
                          backgroundColor: AppColors.success,
                          textColor: AppColors.white,
                        )
                      else
                        _buildTag(
                          text: 'Pending Buyer Review',
                          backgroundColor: AppColors.grey200,
                          textColor: AppColors.grey600,
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Timestamp
                  Text(
                    '${post.timestampPrefix} ${post.timestamp}',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 24.sp),
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
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(OfferedPost post) {
    final image = post.propertyImageUrl?.trim();
    if (image == null || image.isEmpty) {
      return _buildImagePlaceholder(post.propertyType);
    }

    return Image.network(
      image,
      width: 80.w,
      height: 80.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(post.propertyType),
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
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(icon, size: 32.sp, color: AppColors.white.withAlpha(180)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Offered Posts',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Offers you make on Wanted/Needs posts\nwill appear here',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshableEmptyState({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [SizedBox(height: 260.h, child: child)],
      ),
    );
  }
}
