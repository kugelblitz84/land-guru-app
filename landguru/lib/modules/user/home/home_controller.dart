import 'package:get/get.dart';
import '../../../core/services/nested_navigation_service.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/user_bottom_nav_controller.dart';
import '../../shared/shell/main_shell_controller.dart';
import '../properties/property_details/property_details_controller.dart';
import '../properties/property_details/property_details_view.dart';

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
      'postedTime': postedTime,
      'propertyPhotos': imageUrl != null ? [imageUrl] : <String>[],
    };
  }
}

/// Controller for the User Home/Dashboard screen
class HomeController extends GetxController {
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
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // TODO: Load user data from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Update shell controller with user data
      if (Get.isRegistered<MainShellController>()) {
        final shellController = Get.find<MainShellController>();
        shellController.updateUserName('User');
      }

      // Mock data for now
      activePostsCount.value = 12;
      upcomingMeetingsCount.value = 5;

      // Mock featured properties
      featuredProperties.value = [
        FeaturedProperty(
          id: '1',
          postId: '#POST-1040',
          title: '5 Katha Plot in Purbachal',
          location:
              'Sector 4, Purbachal New Town, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          price: '2,00,00,000',
          propertyType: 'Plain Land',
          postType: 'Sell Post',
          isVerified: true,
          isLocked: true,
          imageUrl:
              'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
          description:
              'Prime residential plot in the rapidly developing Purbachal New Town. Ideal location with excellent connectivity and future growth potential.',
          sellableLandAmount: '5 Katha',
          plotSize: '5 Katha',
          distanceFromRoad: '50m-100m',
          postedBy: 'Mr. Rahman',
          postedTime: '1d ago',
        ),
        FeaturedProperty(
          id: '2',
          postId: '#POST-1041',
          title: 'Luxury 3 Bed Apartment',
          location:
              'Gulshan 2, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          price: '80,75,000',
          propertyType: 'Flat',
          postType: 'Sell Post',
          isVerified: true,
          isLocked: true,
          imageUrl: 'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
          description:
              'Luxurious 3 bedroom apartment in prime Gulshan location with modern amenities and premium finishes.',
          sellableLandAmount: '1800 sqft',
          plotSize: '1800 sqft',
          distanceFromRoad: '20m-50m',
          postedBy: 'Mr. Ahmed',
          postedTime: '3h ago',
        ),
        FeaturedProperty(
          id: '3',
          postId: '#POST-1042',
          title: 'Gazipur Water Zone',
          location:
              'Gazipur Sadar, Gazipur City Corporation, Dhaka Division, Bangladesh.',
          price: '95,12,000',
          propertyType: 'Water Land',
          postType: 'Sell Post',
          isVerified: true,
          isLocked: true,
          imageUrl: 'assets/images/Properties demo/Gazipur Water Zone.jpg',
          description:
              'Beautiful water-adjacent land perfect for agricultural or aquaculture projects. Natural water source with excellent drainage system.',
          sellableLandAmount: '10 Katha',
          plotSize: '12 Katha',
          distanceFromRoad: '200m-500m',
          postedBy: 'Mr. Karim',
          postedTime: '3d ago',
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
    await loadDashboardData();
  }
}
