import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/services/nested_navigation_service.dart';
import 'models/deal_models.dart';
import 'deal_details_view.dart';

/// Controller for User My Deals screen
/// Handles: Sold, Bought tabs with filtering
class MyDealsController extends GetxController {
  static DealStats _cachedStats = DealStats();
  static List<Deal> _cachedDeals = <Deal>[];
  static bool _hasCachedData = false;

  // Tab state
  final Rx<DealTab> selectedTab = DealTab.sold.obs;

  // Filter states
  final Rx<DealSortBy> sortBy = DealSortBy.newest.obs;
  final Rx<DealTypeFilter> typeFilter = DealTypeFilter.all.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Stats
  final Rx<DealStats> stats = DealStats().obs;

  // All deals data
  final RxList<Deal> allDeals = <Deal>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeals();
  }

  Future<void> loadDeals({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      stats.value = _cachedStats;
      allDeals.assignAll(_cachedDeals);
      return;
    }

    _loadDemoData();
    _cachedStats = stats.value;
    _cachedDeals = List<Deal>.from(allDeals);
    _hasCachedData = true;
  }

  /// Load demo data
  void _loadDemoData() {
    final now = DateTime.now();

    // Demo stats
    stats.value = DealStats(
      propertySold: 12,
      totalEarned: '9,20,00,000',
      propertyBought: 5,
      totalSpent: '4,50,00,000',
    );

    allDeals.value = [
      // Sold deals
      Deal(
        id: '1',
        postId: '#POST-1042',
        propertyTitle: '5 Katha Plot in Purbachal',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        soldPrice: '2,00,00,000',
        status: DealStatus.sold,
        dealDate: now.subtract(const Duration(hours: 2)),
        description:
            'A stunning newly renovated villa featuring an open-concept '
            "living area, chef's kitchen with top-tier appliances, and a "
            'private backyards oasis...',
        soldLandAmount: '15 Katha',
        plotSize: '15 Katha',
        distanceFromRoad: '200m-750m',
        propertyPhotos: [
          'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
          'assets/images/Properties demo/Gazipur Water Zone.jpg',
          'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
        ],
        otherPartyId: 'buyer_1',
        otherPartyName: 'Farhan',
        otherPartyVerified: true,
        hasHideDueDiligence: true,
        hasPropertyVideo: true,
        hasOwnershipHistory: true,
        deedDocuments: [
          LegalDocument(id: '1', name: 'Deed document 1.pdf', fileType: 'pdf'),
          LegalDocument(
            id: '2',
            name: 'Deed document 2.docx',
            fileType: 'docx',
          ),
        ],
        khatianDocuments: [
          LegalDocument(id: '3', name: 'CS Khatian.docx', fileType: 'docx'),
          LegalDocument(id: '4', name: 'SA Khatian.docx', fileType: 'docx'),
          LegalDocument(id: '5', name: 'RS Khatian.pdf', fileType: 'pdf'),
        ],
        servicesTaken: [
          ServiceTaken(
            id: '1',
            serviceName: 'Ownership History Validation',
            agentName: 'Farhan',
            status: 'Completed',
          ),
          ServiceTaken(
            id: '2',
            serviceName: 'Deed Writing Service',
            agentName: 'Adv',
            status: 'Completed',
          ),
        ],
      ),
      Deal(
        id: '2',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location: 'Kurigram Sadar, Kurigram',
        soldPrice: '4,00,00,000',
        status: DealStatus.sold,
        dealDate: now.subtract(const Duration(hours: 2)),
        description: 'Beautiful villa with excellent location.',
        soldLandAmount: '10 Katha',
        plotSize: '10 Katha',
        distanceFromRoad: '100m',
        otherPartyId: 'buyer_2',
        otherPartyName: 'Ahmed',
        otherPartyVerified: true,
      ),
      Deal(
        id: '3',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location: 'Block-C, Banani, Banani Thana, Dhaka North City Corporation',
        soldPrice: '40,00,000',
        status: DealStatus.sold,
        dealDate: now.subtract(const Duration(hours: 2)),
        description:
            'A stunning newly renovated villa featuring an open-concept '
            "living area, chef's kitchen with top-tier appliances, and a "
            'private backyards oasis...',
        soldLandAmount: '15 Katha',
        plotSize: '15 Katha',
        distanceFromRoad: '200m-750m',
        otherPartyId: 'buyer_3',
        otherPartyName: 'Karim',
        otherPartyVerified: false,
      ),
      Deal(
        id: '4',
        postId: '#POST-1042',
        propertyTitle: 'Gazipur Water Zone',
        propertyImageUrl:
            'assets/images/Properties demo/Gazipur Water Zone.jpg',
        propertyType: PropertyType.flat,
        location: 'Gazipur Sadar, Gazipur',
        soldPrice: '95,12,000',
        status: DealStatus.sold,
        dealDate: now.subtract(const Duration(hours: 2)),
        description: 'Beautiful water body land.',
        soldLandAmount: '8 Katha',
        plotSize: '8 Katha',
        distanceFromRoad: '50m',
        otherPartyId: 'buyer_4',
        otherPartyName: 'Rahim',
        otherPartyVerified: true,
      ),

      // Bought deals
      Deal(
        id: '5',
        postId: '#POST-1043',
        propertyTitle: 'Land in Uttara',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.plainLand,
        location: 'Uttara Sector 10, Dhaka',
        soldPrice: '1,50,00,000',
        status: DealStatus.bought,
        dealDate: now.subtract(const Duration(days: 1)),
        description:
            'Prime location land in Uttara with excellent connectivity.',
        soldLandAmount: '5 Katha',
        plotSize: '5 Katha',
        distanceFromRoad: '0m (Road adjacent)',
        propertyPhotos: [
          'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        ],
        otherPartyId: 'seller_1',
        otherPartyName: 'Seller Name',
        otherPartyVerified: true,
        hasHideDueDiligence: true,
        hasPropertyVideo: true,
        hasOwnershipHistory: true,
      ),
      Deal(
        id: '6',
        postId: '#POST-1044',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        soldPrice: '40,00,000',
        status: DealStatus.bought,
        dealDate: now.subtract(const Duration(hours: 2)),
        description:
            'A stunning newly renovated villa featuring an open-concept '
            "living area, chef's kitchen with top-tier appliances, and a "
            'private backyards oasis. The property offers modern amenities '
            'and a serene environment perfect for family living.',
        soldLandAmount: '15 Katha',
        plotSize: '15 Katha',
        distanceFromRoad: '200m-750m',
        propertyPhotos: [
          'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
          'assets/images/Properties demo/Gazipur Water Zone.jpg',
        ],
        otherPartyId: 'seller_2',
        otherPartyName: 'Farhan',
        otherPartyVerified: true,
        hasHideDueDiligence: true,
        hasPropertyVideo: true,
        hasOwnershipHistory: true,
        deedDocuments: [
          LegalDocument(id: '1', name: 'Deed document 1.pdf', fileType: 'pdf'),
          LegalDocument(
            id: '2',
            name: 'Deed document 2.docx',
            fileType: 'docx',
          ),
        ],
        khatianDocuments: [
          LegalDocument(id: '3', name: 'CS Khatian.docx', fileType: 'docx'),
          LegalDocument(id: '4', name: 'SA Khatian.docx', fileType: 'docx'),
        ],
      ),
      Deal(
        id: '7',
        postId: '#POST-1045',
        propertyTitle: 'Gazipur Water Zone Property',
        propertyImageUrl:
            'assets/images/Properties demo/Gazipur Water Zone.jpg',
        propertyType: PropertyType.waterLand,
        location: 'Gazipur Sadar, Gazipur',
        soldPrice: '75,00,000',
        status: DealStatus.bought,
        dealDate: now.subtract(const Duration(days: 3)),
        description:
            'Beautiful water body land suitable for fishery or eco-tourism development.',
        soldLandAmount: '10 Katha',
        plotSize: '10 Katha',
        distanceFromRoad: '50m',
        propertyPhotos: [
          'assets/images/Properties demo/Gazipur Water Zone.jpg',
        ],
        otherPartyId: 'seller_3',
        otherPartyName: 'Karim',
        otherPartyVerified: false,
        hasHideDueDiligence: true,
        hasPropertyVideo: false,
        hasOwnershipHistory: true,
      ),
    ];
  }

  /// Get filtered deals based on current tab and filters
  List<Deal> get filteredDeals {
    List<Deal> filtered = allDeals
        .where(
          (d) => selectedTab.value == DealTab.sold
              ? d.status == DealStatus.sold
              : d.status == DealStatus.bought,
        )
        .toList();

    // Apply type filter
    if (typeFilter.value != DealTypeFilter.all) {
      filtered = filtered.where((d) {
        switch (typeFilter.value) {
          case DealTypeFilter.flat:
            return d.propertyType == PropertyType.flat;
          case DealTypeFilter.plainLand:
            return d.propertyType == PropertyType.plainLand;
          case DealTypeFilter.waterLand:
            return d.propertyType == PropertyType.waterLand;
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case DealSortBy.newest:
        filtered.sort((a, b) => b.dealDate.compareTo(a.dealDate));
        break;
      case DealSortBy.oldest:
        filtered.sort((a, b) => a.dealDate.compareTo(b.dealDate));
        break;
      case DealSortBy.priceHighToLow:
        filtered.sort((a, b) {
          final priceA = _parsePrice(a.soldPrice);
          final priceB = _parsePrice(b.soldPrice);
          return priceB.compareTo(priceA);
        });
        break;
      case DealSortBy.priceLowToHigh:
        filtered.sort((a, b) {
          final priceA = _parsePrice(a.soldPrice);
          final priceB = _parsePrice(b.soldPrice);
          return priceA.compareTo(priceB);
        });
        break;
    }

    return filtered;
  }

  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(',', '').replaceAll(' ', '')) ?? 0;
  }

  /// Change tab
  void changeTab(DealTab tab) {
    selectedTab.value = tab;
  }

  /// Change sort by
  void changeSortBy(DealSortBy sort) {
    sortBy.value = sort;
  }

  /// Change type filter
  void changeTypeFilter(DealTypeFilter filter) {
    typeFilter.value = filter;
  }

  /// Refresh data
  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    await loadDeals(forceRefresh: true);
    isLoading.value = false;
  }

  /// Navigate to deal details (uses nested navigation to keep bottom nav visible)
  void goToDealDetails(Deal deal) {
    // Unified DealDetailsView handles both sold and bought properties
    NestedNavigationService.to(
      const DealDetailsView(),
      arguments: {'deal': deal},
    );
  }
}
