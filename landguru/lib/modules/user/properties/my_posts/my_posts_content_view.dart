import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/property_type.dart';
import 'models/my_post.dart';
import 'my_posts_controller.dart';
import 'buy_posts/buy_posts_content_view.dart';
import 'offered_posts/offered_posts_content_view.dart';

/// My Posts content view with sub-tabs, filters, and post cards
class MyPostsContentView extends StatelessWidget {
  const MyPostsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<MyPostsController>()) {
      Get.put(MyPostsController());
    }
    final controller = Get.find<MyPostsController>();

    return Column(
      children: [
        // Sub-tabs: Sell Posts, Buy Posts, Offered Posts
        _buildSubTabs(controller),

        SizedBox(height: 12.h),

        // Content based on selected sub-tab
        Expanded(
          child: Obx(() {
            switch (controller.subTabIndex.value) {
              case 0:
                // Sell Posts - use existing content
                return _buildSellPostsContent(controller);
              case 1:
                // Buy Posts - use dedicated view
                return const BuyPostsContentView();
              case 2:
                // Offered Posts - use dedicated view
                return const OfferedPostsContentView();
              default:
                return _buildSellPostsContent(controller);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildSubTabs(MyPostsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Obx(
          () => Row(
            children: [
              // Sell Posts tab
              Expanded(
                child: _buildSubTab(
                  controller: controller,
                  label: 'Sell Posts',
                  index: 0,
                  isSelected: controller.subTabIndex.value == 0,
                ),
              ),

              // Buy Posts tab with badge
              Expanded(
                child: _buildSubTab(
                  controller: controller,
                  label: 'Buy Posts',
                  index: 1,
                  isSelected: controller.subTabIndex.value == 1,
                  badgeCount: controller.buyPostsBadgeCount.value,
                ),
              ),

              // Offered Posts tab
              Expanded(
                child: _buildSubTab(
                  controller: controller,
                  label: 'Offered Posts',
                  index: 2,
                  isSelected: controller.subTabIndex.value == 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab({
    required MyPostsController controller,
    required String label,
    required int index,
    required bool isSelected,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: () => controller.changeSubTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.grey600,
                ),
              ),
              if (badgeCount > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : AppColors.error,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build Sell Posts content (existing implementation)
  Widget _buildSellPostsContent(MyPostsController controller) {
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
            if (controller.isLoading.value && controller.currentPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.currentPosts.isEmpty) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount:
                    controller.currentPosts.length +
                    (controller.isLoadingMoreSellPosts.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.currentPosts.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (index == controller.currentPosts.length - 1) {
                    controller.loadMoreSellPostsIfNeeded();
                  }

                  return _buildPostCard(
                    controller,
                    controller.currentPosts[index],
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChips(MyPostsController controller) {
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

  Widget _buildResultsHeader(MyPostsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Showing ${controller.currentTotalCount} Properties',
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

  Widget _buildPostCard(MyPostsController controller, MyPost post) {
    return GestureDetector(
      onTap: () => controller.goToPostDetails(post),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
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
                    post.title,
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

                  // Price
                  Row(
                    children: [
                      Text(
                        'Price: ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '৳ ${post.price}',
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

                      // Status tag
                      _buildTag(
                        text: post.statusLabel,
                        backgroundColor: post.statusBackgroundColor,
                        textColor: post.statusTextColor,
                      ),

                      // Verified tag
                      if (post.isVerified)
                        _buildTag(
                          text: 'Verified',
                          backgroundColor: AppColors.success,
                          textColor: AppColors.white,
                          icon: Icons.check_circle,
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

  Widget _buildPostImage(MyPost post) {
    final imageUrl = post.imageUrl;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _buildImagePlaceholder(post.propertyType);
    }

    final isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        width: 80.w,
        height: 80.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(post.propertyType);
        },
      );
    }

    return Image.asset(
      imageUrl,
      width: 80.w,
      height: 80.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(post.propertyType);
      },
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

  Widget _buildEmptyState(MyPostsController controller) {
    String title;
    String subtitle;
    IconData icon;

    switch (controller.subTabIndex.value) {
      case 0:
        title = 'No Sell Posts';
        subtitle = 'Create your first sell post to get started';
        icon = Icons.sell_outlined;
        break;
      case 1:
        title = 'No Buy Posts';
        subtitle = 'Create a buy post to find properties';
        icon = Icons.shopping_cart_outlined;
        break;
      case 2:
        title = 'No Offered Posts';
        subtitle = 'Your offered posts will appear here';
        icon = Icons.local_offer_outlined;
        break;
      default:
        title = 'No Posts';
        subtitle = 'Create a post to get started';
        icon = Icons.article_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (controller.subTabIndex.value < 2)
            ElevatedButton.icon(
              onPressed: controller.goToCreatePost,
              icon: const Icon(Icons.add),
              label: Text(
                controller.subTabIndex.value == 0
                    ? 'Create Sell Post'
                    : 'Create Buy Post',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
