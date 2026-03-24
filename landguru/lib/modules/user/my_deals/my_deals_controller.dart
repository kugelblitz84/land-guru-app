import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/nested_navigation_service.dart';
import 'models/payloads/my_deals_payload_models.dart';
import 'services/my_deals_service.dart';
import 'models/deal_models.dart';
import 'deal_details_view.dart';

/// Controller for User My Deals screen
/// Handles: Sold, Bought tabs with filtering
class MyDealsController extends GetxController {
  static const int _defaultPage = 1;
  static const int _defaultLimit = 10;
  static const int _loadMoreThreshold = 200;

  static DealStats _cachedStats = DealStats();
  static List<Deal> _cachedDeals = <Deal>[];
  static int _cachedSoldCurrentPage = _defaultPage;
  static int _cachedSoldTotalPages = 1;
  static bool _cachedHasMoreSold = true;
  static int _cachedBoughtCurrentPage = _defaultPage;
  static int _cachedBoughtTotalPages = 1;
  static bool _cachedHasMoreBought = true;
  static bool _hasCachedData = false;

  final MyDealsService _service = Get.find<MyDealsService>();

  // Tab state
  final RxString selectedTab = DealTabs.sold.obs;

  // Filter states
  final RxString sortBy = DealSortOptions.newest.obs;
  final RxString typeFilter = DealTypeFilters.all.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMoreSold = false.obs;
  final RxBool isLoadingMoreBought = false.obs;
  final RxBool hasMoreSold = true.obs;
  final RxBool hasMoreBought = true.obs;

  // Stats
  final Rx<DealStats> stats = DealStats().obs;

  // All deals data
  final RxList<Deal> allDeals = <Deal>[].obs;

  int _soldCurrentPage = _defaultPage;
  int _soldTotalPages = 1;
  int _boughtCurrentPage = _defaultPage;
  int _boughtTotalPages = 1;

  @override
  void onInit() {
    super.onInit();
    loadDeals();
  }

  Future<void> loadDeals({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      stats.value = _cachedStats;
      allDeals.assignAll(_cachedDeals);
      _soldCurrentPage = _cachedSoldCurrentPage;
      _soldTotalPages = _cachedSoldTotalPages;
      hasMoreSold.value = _cachedHasMoreSold;
      _boughtCurrentPage = _cachedBoughtCurrentPage;
      _boughtTotalPages = _cachedBoughtTotalPages;
      hasMoreBought.value = _cachedHasMoreBought;
      return;
    }

    final result = await ApiErrorHandler.call(() async {
      final soldSummaryFuture = _service.getMySoldSummary();
      final boughtSummaryFuture = _service.getMyBoughtSummary();
      final soldDealsFuture = _service.getMySoldDeals(
        payload: MyDealsSoldListPayload(
          page: _defaultPage,
          limit: _defaultLimit,
          propertyType: _apiPropertyTypeFilter(typeFilter.value),
          sort: _apiSort(sortBy.value),
        ),
      );
      final boughtDealsFuture = _service.getMyBoughtDeals(
        payload: const MyDealsBoughtListPayload(
          page: _defaultPage,
          limit: _defaultLimit,
        ),
      );

      final resolved = await Future.wait<dynamic>([
        soldSummaryFuture,
        boughtSummaryFuture,
        soldDealsFuture,
        boughtDealsFuture,
      ]);

      return _MyDealsBootstrapData(
        soldStats: resolved[0] as DealStats,
        boughtStats: resolved[1] as DealStats,
        soldResponse: resolved[2] as MyDealsListResponse,
        boughtResponse: resolved[3] as MyDealsListResponse,
      );
    }, fallbackMessage: 'Failed to load deals');
    if (!result.isSuccess) {
      return;
    }

    final bootstrap = result.data;
    if (bootstrap == null) {
      return;
    }

    final mergedStats = stats.value.copyWith(
      propertySold: bootstrap.soldStats.propertySold,
      totalEarned: bootstrap.soldStats.totalEarned,
      propertyBought: bootstrap.boughtStats.propertyBought,
      totalSpent: bootstrap.boughtStats.totalSpent,
    );
    stats.value = mergedStats;

    allDeals.assignAll(<Deal>[
      ...bootstrap.soldResponse.deals,
      ...bootstrap.boughtResponse.deals,
    ]);

    _soldCurrentPage = bootstrap.soldResponse.page;
    _soldTotalPages = bootstrap.soldResponse.totalPages;
    hasMoreSold.value = _soldCurrentPage < _soldTotalPages;

    _boughtCurrentPage = bootstrap.boughtResponse.page;
    _boughtTotalPages = bootstrap.boughtResponse.totalPages;
    hasMoreBought.value = _boughtCurrentPage < _boughtTotalPages;

    _cachedStats = stats.value;
    _cachedDeals = List<Deal>.from(allDeals);
    _cachedSoldCurrentPage = _soldCurrentPage;
    _cachedSoldTotalPages = _soldTotalPages;
    _cachedHasMoreSold = hasMoreSold.value;
    _cachedBoughtCurrentPage = _boughtCurrentPage;
    _cachedBoughtTotalPages = _boughtTotalPages;
    _cachedHasMoreBought = hasMoreBought.value;
    _hasCachedData = true;
  }

  bool get isCurrentTabLoadingMore => selectedTab.value == DealTabs.sold
      ? isLoadingMoreSold.value
      : isLoadingMoreBought.value;

  void onScrollNotification(ScrollMetrics metrics) {
    final reachedThreshold =
        metrics.maxScrollExtent - metrics.pixels <= _loadMoreThreshold;
    if (!reachedThreshold) {
      return;
    }
    loadMoreForCurrentTab();
  }

  void onDealListIndexBuilt(int index, int totalItems) {
    if (totalItems <= 0) {
      return;
    }
    if (index >= totalItems - 2) {
      loadMoreForCurrentTab();
    }
  }

  Future<void> loadMoreForCurrentTab() async {
    if (isLoading.value) {
      return;
    }
    if (selectedTab.value == DealTabs.sold) {
      await _loadMoreSold();
    } else {
      await _loadMoreBought();
    }
  }

  Future<void> _loadMoreSold() async {
    if (isLoadingMoreSold.value || !hasMoreSold.value) {
      return;
    }

    isLoadingMoreSold.value = true;
    final nextPage = _soldCurrentPage + 1;

    final result = await ApiErrorHandler.call(
      () => _service.getMySoldDeals(
        payload: MyDealsSoldListPayload(
          page: nextPage,
          limit: _defaultLimit,
          propertyType: _apiPropertyTypeFilter(typeFilter.value),
          sort: _apiSort(sortBy.value),
        ),
      ),
      showError: false,
      fallbackMessage: 'Failed to load more sold deals',
    );

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final existingIds = allDeals
          .where((deal) => deal.status == DealStatuses.sold)
          .map((deal) => deal.id)
          .toSet();

      final newDeals = response.deals
          .where((deal) => !existingIds.contains(deal.id))
          .toList(growable: false);

      allDeals.addAll(newDeals);
      _soldCurrentPage = response.page;
      _soldTotalPages = response.totalPages;
      hasMoreSold.value = _soldCurrentPage < _soldTotalPages;
      _syncCache();
    }

    isLoadingMoreSold.value = false;
  }

  Future<void> _loadMoreBought() async {
    if (isLoadingMoreBought.value || !hasMoreBought.value) {
      return;
    }

    isLoadingMoreBought.value = true;
    final nextPage = _boughtCurrentPage + 1;

    final result = await ApiErrorHandler.call(
      () => _service.getMyBoughtDeals(
        payload: MyDealsBoughtListPayload(page: nextPage, limit: _defaultLimit),
      ),
      showError: false,
      fallbackMessage: 'Failed to load more bought deals',
    );

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final existingIds = allDeals
          .where((deal) => deal.status == DealStatuses.bought)
          .map((deal) => deal.id)
          .toSet();

      final newDeals = response.deals
          .where((deal) => !existingIds.contains(deal.id))
          .toList(growable: false);

      allDeals.addAll(newDeals);
      _boughtCurrentPage = response.page;
      _boughtTotalPages = response.totalPages;
      hasMoreBought.value = _boughtCurrentPage < _boughtTotalPages;
      _syncCache();
    }

    isLoadingMoreBought.value = false;
  }

  /// Get filtered deals based on current tab and filters
  List<Deal> get filteredDeals {
    List<Deal> filtered = allDeals
        .where(
          (d) => selectedTab.value == DealTabs.sold
              ? d.status == DealStatuses.sold
              : d.status == DealStatuses.bought,
        )
        .toList();

    // Apply type filter
    if (typeFilter.value != DealTypeFilters.all) {
      filtered = filtered.where((d) {
        switch (typeFilter.value) {
          case DealTypeFilters.flat:
            return d.propertyType == PropertyType.flat;
          case DealTypeFilters.plainLand:
            return d.propertyType == PropertyType.plainLand;
          case DealTypeFilters.waterLand:
            return d.propertyType == PropertyType.waterLand;
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case DealSortOptions.newest:
        filtered.sort((a, b) => b.dealDate.compareTo(a.dealDate));
        break;
      case DealSortOptions.oldest:
        filtered.sort((a, b) => a.dealDate.compareTo(b.dealDate));
        break;
      case DealSortOptions.priceHighToLow:
        filtered.sort((a, b) {
          final priceA = _parsePrice(a.soldPrice);
          final priceB = _parsePrice(b.soldPrice);
          return priceB.compareTo(priceA);
        });
        break;
      case DealSortOptions.priceLowToHigh:
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
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  /// Change sort by
  void changeSortBy(String sort) {
    sortBy.value = sort;
    loadDeals(forceRefresh: true);
  }

  /// Change type filter
  void changeTypeFilter(String filter) {
    typeFilter.value = filter;
    loadDeals(forceRefresh: true);
  }

  /// Refresh data
  Future<void> refresh() async {
    isLoading.value = true;
    await loadDeals(forceRefresh: true);
    isLoading.value = false;
  }

  void _syncCache() {
    _cachedStats = stats.value;
    _cachedDeals = List<Deal>.from(allDeals);
    _cachedSoldCurrentPage = _soldCurrentPage;
    _cachedSoldTotalPages = _soldTotalPages;
    _cachedHasMoreSold = hasMoreSold.value;
    _cachedBoughtCurrentPage = _boughtCurrentPage;
    _cachedBoughtTotalPages = _boughtTotalPages;
    _cachedHasMoreBought = hasMoreBought.value;
    _hasCachedData = true;
  }

  /// Navigate to deal details (uses nested navigation to keep bottom nav visible)
  Future<void> goToDealDetails(Deal deal) async {
    if (deal.status == DealStatuses.sold) {
      final result = await ApiErrorHandler.call(
        () => _service.getMySoldDealDetails(
          payload: MySoldDealDetailsPayload(soldPostId: deal.id),
        ),
        fallbackMessage: 'Failed to load sold deal details',
      );

      if (result.isSuccess && result.data != null) {
        final enriched = deal.copyWith(
          description: result.data!.description ?? deal.description,
          propertyImageUrl:
              result.data!.propertyImageUrl ?? deal.propertyImageUrl,
          location: result.data!.location,
          soldPrice: result.data!.soldPrice,
          soldLandAmount: result.data!.soldLandAmount,
          plotSize: result.data!.plotSize,
          distanceFromRoad: result.data!.distanceFromRoad,
          propertyPhotos: result.data!.propertyPhotos,
          buyersCount: result.data!.buyersCount,
          buyers: result.data!.buyers,
          otherPartyId: result.data!.otherPartyId,
          otherPartyName: result.data!.otherPartyName,
          otherPartyAvatar: result.data!.otherPartyAvatar,
          otherPartyVerified: result.data!.otherPartyVerified,
          hasHideDueDiligence: result.data!.hasHideDueDiligence,
          hasPropertyVideo: result.data!.hasPropertyVideo,
          hasOwnershipHistory: result.data!.hasOwnershipHistory,
          propertyVideoUrl: result.data!.propertyVideoUrl,
          riskChecklist: result.data!.riskChecklist,
          ownershipHistory: result.data!.ownershipHistory,
          deedDocuments: result.data!.deedDocuments,
          khatianDocuments: result.data!.khatianDocuments,
          porchagophMapDocuments: result.data!.porchagophMapDocuments,
          otherDocuments: result.data!.otherDocuments,
          servicesTaken: result.data!.servicesTaken,
        );

        final index = allDeals.indexWhere((item) => item.id == deal.id);
        if (index >= 0) {
          allDeals[index] = enriched;
          _cachedDeals = List<Deal>.from(allDeals);
        }

        NestedNavigationService.to(
          const DealDetailsView(),
          arguments: {'deal': enriched},
        );
        return;
      }
    }

    if (deal.status == DealStatuses.bought) {
      final result = await ApiErrorHandler.call(
        () => _service.getMyBoughtDealDetails(
          payload: MyBoughtDealDetailsPayload(dealId: deal.id),
        ),
        fallbackMessage: 'Failed to load bought deal details',
      );

      if (result.isSuccess && result.data != null) {
        final enriched = deal.copyWith(
          description: result.data!.description ?? deal.description,
          propertyImageUrl:
              result.data!.propertyImageUrl ?? deal.propertyImageUrl,
          location: result.data!.location,
          soldPrice: result.data!.soldPrice,
          soldLandAmount: result.data!.soldLandAmount,
          plotSize: result.data!.plotSize,
          distanceFromRoad: result.data!.distanceFromRoad,
          propertyPhotos: result.data!.propertyPhotos,
          otherPartyId: result.data!.otherPartyId,
          otherPartyName: result.data!.otherPartyName,
          otherPartyAvatar: result.data!.otherPartyAvatar,
          otherPartyVerified: result.data!.otherPartyVerified,
          hasHideDueDiligence: result.data!.hasHideDueDiligence,
          hasPropertyVideo: result.data!.hasPropertyVideo,
          hasOwnershipHistory: result.data!.hasOwnershipHistory,
          propertyVideoUrl: result.data!.propertyVideoUrl,
          riskChecklist: result.data!.riskChecklist,
          ownershipHistory: result.data!.ownershipHistory,
          deedDocuments: result.data!.deedDocuments,
          khatianDocuments: result.data!.khatianDocuments,
          porchagophMapDocuments: result.data!.porchagophMapDocuments,
          otherDocuments: result.data!.otherDocuments,
          servicesTaken: result.data!.servicesTaken,
        );

        final index = allDeals.indexWhere((item) => item.id == deal.id);
        if (index >= 0) {
          allDeals[index] = enriched;
          _cachedDeals = List<Deal>.from(allDeals);
        }

        NestedNavigationService.to(
          const DealDetailsView(),
          arguments: {'deal': enriched},
        );
        return;
      }
    }

    // Unified DealDetailsView handles both sold and bought properties
    NestedNavigationService.to(
      const DealDetailsView(),
      arguments: {'deal': deal},
    );
  }

  String? _apiPropertyTypeFilter(String value) {
    switch (value) {
      case DealTypeFilters.flat:
        return 'Flat';
      case DealTypeFilters.plainLand:
        return 'Land';
      case DealTypeFilters.waterLand:
        return 'Water Land';
      default:
        return null;
    }
  }

  String _apiSort(String value) {
    switch (value) {
      case DealSortOptions.oldest:
      case DealSortOptions.priceLowToHigh:
        return 'ASC';
      case DealSortOptions.newest:
      case DealSortOptions.priceHighToLow:
      default:
        return 'DESC';
    }
  }
}

class _MyDealsBootstrapData {
  const _MyDealsBootstrapData({
    required this.soldStats,
    required this.boughtStats,
    required this.soldResponse,
    required this.boughtResponse,
  });

  final DealStats soldStats;
  final DealStats boughtStats;
  final MyDealsListResponse soldResponse;
  final MyDealsListResponse boughtResponse;
}
