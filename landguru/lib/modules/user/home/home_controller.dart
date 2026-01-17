import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';

/// Model for featured property
class FeaturedProperty {
  final String id;
  final String title;
  final String location;
  final String price;
  final String propertyType;
  final String postType;
  final bool isVerified;
  final String? imageUrl;

  FeaturedProperty({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.propertyType,
    required this.postType,
    required this.isVerified,
    this.imageUrl,
  });
}

/// Controller for the User Home/Dashboard screen
class HomeController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxString userName = 'User'.obs;
  final RxString userAvatar = ''.obs;

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
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // TODO: Load user data from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for now
      userName.value = 'User';
      activePostsCount.value = 12;
      upcomingMeetingsCount.value = 5;

      // Mock featured properties
      featuredProperties.value = [
        FeaturedProperty(
          id: '1',
          title: '5 Katha Plot in Purbachal',
          location: 'Sector 4, Dhaka',
          price: '2,00,00,000',
          propertyType: 'Plain Land',
          postType: 'Sell Post',
          isVerified: true,
          imageUrl: 'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        ),
        FeaturedProperty(
          id: '2',
          title: 'Luxury 3 Bed Apartment',
          location: 'Gulshan 2, Dhaka',
          price: '80,75,000',
          propertyType: 'Flat',
          postType: 'Sell Post',
          isVerified: true,
          imageUrl: 'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
        ),
        FeaturedProperty(
          id: '3',
          title: 'Gazipur Water Zone',
          location: 'Gazipur, Dhaka',
          price: '95,12,000',
          propertyType: 'Water Land',
          postType: 'Sell Post',
          isVerified: true,
          imageUrl: 'assets/images/Properties demo/Gazipur Water Zone.jpg',
        ),
      ];
    } catch (e) {
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

  /// Navigate to my posts (Active Posts)
  void goToMyPosts() {
    Get.toNamed(AppRoutes.MY_POSTS);
  }

  /// Navigate to appointments (Upcoming Meetings)
  void goToAppointments() {
    Get.toNamed(AppRoutes.APPOINTMENTS);
  }

  /// Navigate to all featured properties
  void goToAllFeaturedProperties() {
    Get.toNamed(AppRoutes.PROPERTIES_FOR_SALE);
  }

  /// Navigate to property details
  void goToPropertyDetails(String propertyId) {
    Get.toNamed(
      AppRoutes.PROPERTY_DETAILS_LOCKED,
      arguments: {'propertyId': propertyId},
    );
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
