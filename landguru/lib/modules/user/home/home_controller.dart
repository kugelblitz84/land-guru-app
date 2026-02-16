import 'package:get/get.dart';
import '../../../core/models/property_listing.dart';
import '../../../core/services/nested_navigation_service.dart';
import '../../../core/services/services.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import '../properties/for_sale/property_details/property_details_controller.dart';
import '../properties/for_sale/property_details/property_details_view.dart';

/// Model for featured property
class FeaturedProperty {
  final String id;
  final String postId;
  final String title;
  final String location;
  final String price;
  final String propertyType;
  final String postType;
  final bool isVerified;
  final bool isLocked;
  final String? imageUrl;
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? postedBy;
  final String? postedByAvatarUrl;
  final bool postedByVerified;
  final String? postedTime;

  FeaturedProperty({
    required this.id,
    this.postId = '',
    required this.title,
    required this.location,
    required this.price,
    required this.propertyType,
    required this.postType,
    required this.isVerified,
    this.isLocked = true,
    this.imageUrl,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.postedBy,
    this.postedByAvatarUrl,
    this.postedByVerified = false,
    this.postedTime,
  });

  /// Convert to Map for navigation arguments
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'location': location,
      'price': price,
      'propertyType': propertyType,
      'postType': postType,
      'isVerified': isVerified,
      'isLocked': isLocked,
      'imageUrl': imageUrl,
      'description': description,
      'sellableLandAmount': sellableLandAmount,
      'plotSize': plotSize,
      'distanceFromRoad': distanceFromRoad,
      'postedBy': postedBy,
      'postedByAvatarUrl': postedByAvatarUrl,
      'postedByVerified': postedByVerified,
      'postedTime': postedTime,
      'propertyPhotos': imageUrl != null ? [imageUrl] : <String>[],
    };
  }
}

/// Controller for the User Home/Dashboard screen
class HomeController extends GetxController {
  final SellPostListingService _sellPostListingService =
      Get.find<SellPostListingService>();
  final MySellPostsService _mySellPostsService = Get.find<MySellPostsService>();

  static int _cachedActivePostsCount = 0;
  static int _cachedUpcomingMeetingsCount = 0;
  static List<FeaturedProperty> _cachedFeaturedProperties =
      <FeaturedProperty>[];
  static bool _hasCachedData = false;

  // State
  final RxBool isLoading = false.obs;

  // Stats
  final RxInt activePostsCount = 0.obs;
  final RxInt upcomingMeetingsCount = 0.obs;

  // Featured properties
  final RxList<FeaturedProperty> featuredProperties = <FeaturedProperty>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load dashboard data
  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    try {
      final activePostsResult = await ApiErrorHandler.call(
        () => _mySellPostsService.getMySellPosts(
          page: 1,
          limit: 10,
          tab: MySellPostsTab.active.apiValue,
        ),
      );
      final featuredResult = await ApiErrorHandler.call(
        () => _sellPostListingService.getSellPosts(page: 1, limit: 3),
      );

      if (activePostsResult.isSuccess && activePostsResult.data != null) {
        activePostsCount.value = activePostsResult.data!.total;
      } else {
        activePostsCount.value = 0;
      }

      upcomingMeetingsCount.value = 0;

      if (featuredResult.isSuccess && featuredResult.data != null) {
        featuredProperties.assignAll(
          featuredResult.data!.posts.map(_toFeaturedProperty),
        );
      } else {
        featuredProperties.clear();
      }

      _syncCache();
    } catch (e) {
      activePostsCount.value = 0;
      upcomingMeetingsCount.value = 0;
      featuredProperties.clear();
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to notifications
  void goToNotifications() {
    final navController = Get.find<UserBottomNavController>();
    navController.goToNotifications();
  }

  /// Navigate to create sell post
  void goToCreateSellPost() {
    Get.toNamed(AppRoutes.CREATE_SELL_POST_INFO);
  }

  /// Navigate to create buy post (Request to Buy)
  void goToCreateBuyPost() {
    Get.toNamed(AppRoutes.CREATE_BUY_POST_INFO);
  }

  /// Navigate to my posts (Active Posts) - goes to Properties tab
  void goToMyPosts() {
    // Navigate to Properties tab instead of placeholder route
    final navController = Get.find<UserBottomNavController>();
    navController.changeTab(1); // Properties tab
  }

  /// Navigate to appointments (Upcoming Meetings)
  void goToAppointments() {
    // Navigate to Appointments tab
    final navController = Get.find<UserBottomNavController>();
    navController.changeTab(2); // Appointments tab
  }

  /// Navigate to all featured properties - goes to Properties tab
  void goToAllFeaturedProperties() {
    // Navigate to Properties tab instead of placeholder route
    final navController = Get.find<UserBottomNavController>();
    navController.changeTab(1); // Properties tab
  }

  /// Navigate to property details (uses nested navigation to keep bottom nav visible)
  void goToPropertyDetails(FeaturedProperty property) {
    // Navigate using nested navigation with arguments
    // The unified PropertyDetailsView handles both locked and unlocked states
    NestedNavigationService.to(
      const PropertyDetailsView(),
      arguments: property.toMap(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(
          () => PropertyDetailsController(),
        );
      }),
    );
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardData(forceRefresh: true);
  }

  void _restoreFromCache() {
    activePostsCount.value = _cachedActivePostsCount;
    upcomingMeetingsCount.value = _cachedUpcomingMeetingsCount;
    featuredProperties.assignAll(_cachedFeaturedProperties);
  }

  void _syncCache() {
    _cachedActivePostsCount = activePostsCount.value;
    _cachedUpcomingMeetingsCount = upcomingMeetingsCount.value;
    _cachedFeaturedProperties = List<FeaturedProperty>.from(featuredProperties);
    _hasCachedData = true;
  }

  FeaturedProperty _toFeaturedProperty(PropertyListing property) {
    return FeaturedProperty(
      id: property.id,
      postId: property.postId,
      title: property.title,
      location: property.location,
      price: property.price,
      propertyType: property.propertyTypeLabel,
      postType: property.postTypeLabel,
      isVerified: property.isVerified,
      isLocked: true,
      imageUrl: property.imageUrl,
      description: property.description,
      sellableLandAmount: property.sellableLandAmount,
      plotSize: property.plotSize,
      distanceFromRoad: property.distanceFromRoad,
      postedBy: property.postedBy,
      postedByAvatarUrl: property.postedByAvatarUrl,
      postedByVerified: property.postedByVerified,
      postedTime: property.postedTime,
    );
  }
}
