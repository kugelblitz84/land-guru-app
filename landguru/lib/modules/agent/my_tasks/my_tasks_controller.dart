import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:landguru/routes/app_routes.dart';
import 'agent_task_actions_service.dart';
import 'models/task_models.dart';
import 'package:landguru/core/core.dart';

/// Controller for Agent My Tasks screen
/// Handles: New, Active, In Review, Done tabs
class AgentMyTasksController extends GetxController {
  static const int _pageLimit = 10;
  static List<AgentTask> _cachedNewTasks = <AgentTask>[];
  static List<AgentTask> _cachedActiveTasks = <AgentTask>[];
  static List<AgentTask> _cachedInReviewTasks = <AgentTask>[];
  static List<AgentTask> _cachedDoneTasks = <AgentTask>[];
  static int _cachedNewPage = 1;
  static int _cachedActivePage = 1;
  static int _cachedInReviewPage = 1;
  static int _cachedDonePage = 1;
  static int _cachedNewTotal = 0;
  static int _cachedActiveTotal = 0;
  static int _cachedInReviewTotal = 0;
  static int _cachedDoneTotal = 0;
  static bool _cachedHasMoreNew = true;
  static bool _cachedHasMoreActive = true;
  static bool _cachedHasMoreInReview = true;
  static bool _cachedHasMoreDone = true;
  static String _cachedAssignedLocation = '';
  static int _cachedSelectedTabIndex = 0;
  static String _cachedSearchQuery = '';
  static String _cachedServiceTypeFilter = ServiceTypeFilter.all;
  static bool _hasCachedData = false;

  // Tab state
  final RxInt selectedTabIndex =
      0.obs; // 0: New, 1: Active, 2: In Review, 3: Done

  // Search
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Filter
  final RxString serviceTypeFilter = ServiceTypeFilter.all.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Tasks lists by status
  final RxList<AgentTask> newTasks = <AgentTask>[].obs;
  final RxList<AgentTask> activeTasks = <AgentTask>[].obs;
  final RxList<AgentTask> inReviewTasks = <AgentTask>[].obs;
  final RxList<AgentTask> doneTasks = <AgentTask>[].obs;

  // Agent's assigned location
  final RxString assignedLocation = ''.obs;

  final Map<int, int> _currentPageByTab = <int, int>{
    0: 1,
    1: 1,
    2: 1,
    3: 1,
  };
  final Map<int, int> _totalByTab = <int, int>{
    0: 0,
    1: 0,
    2: 0,
    3: 0,
  };
  final Map<int, bool> _hasMoreByTab = <int, bool>{
    0: true,
    1: true,
    2: true,
    3: true,
  };

  final _taskActionsService = Get.find<AgentTaskActionsService>();

  /// Get current tasks based on selected tab
  List<AgentTask> get currentTasks {
    return getFilteredTasksForTab(selectedTabIndex.value);
  }

  /// Get filtered tasks for a specific tab index
  List<AgentTask> getFilteredTasksForTab(int tabIndex) {
    List<AgentTask> tasks;
    switch (tabIndex) {
      case 0:
        tasks = newTasks;
        break;
      case 1:
        tasks = activeTasks;
        break;
      case 2:
        tasks = inReviewTasks;
        break;
      case 3:
        tasks = doneTasks;
        break;
      default:
        tasks = newTasks;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      tasks = tasks.where((task) {
        return task.serviceName.toLowerCase().contains(query) ||
            task.clientName.toLowerCase().contains(query) ||
            task.serviceId.toLowerCase().contains(query);
      }).toList();
    }

    // Apply service type filter
    if (serviceTypeFilter.value != ServiceTypeFilter.all) {
      tasks = tasks.where((task) {
        return task.serviceType.shortLabel == serviceTypeFilter.value;
      }).toList();
    }

    return tasks;
  }

  /// Get count for each tab
  int get newTasksCount => newTasks.length;
  int get activeTasksCount => activeTasks.length;
  int get inReviewTasksCount => inReviewTasks.length;
  int get doneTasksCount => doneTasks.length;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadTasks();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  bool get hasMoreForSelectedTab =>
      _hasMoreByTab[selectedTabIndex.value] ?? false;

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// Update service type filter
  void updateServiceTypeFilter(String type) {
    serviceTypeFilter.value = type;
  }

  /// Load tasks from API
  Future<void> loadTasks({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    try {
      final newResult = await ApiErrorHandler.call<AgentTasksListResponse>(
        () => _taskActionsService.fetchTasks(tab: 'NEW', page: 1, limit: 10),
        showError: false,
      );
      final activeResult = await ApiErrorHandler.call<AgentTasksListResponse>(
        () => _taskActionsService.fetchTasks(tab: 'ACTIVE', page: 1, limit: 10),
        showError: false,
      );
      final inReviewResult = await ApiErrorHandler.call<AgentTasksListResponse>(
        () => _taskActionsService.fetchTasks(
          tab: 'IN_REVIEW',
          page: 1,
          limit: 10,
        ),
        showError: false,
      );
      final doneResult = await ApiErrorHandler.call<AgentTasksListResponse>(
        () => _taskActionsService.fetchTasks(tab: 'DONE', page: 1, limit: 10),
        showError: false,
      );

      newTasks.assignAll(newResult.data?.tasks ?? const <AgentTask>[]);
      activeTasks.assignAll(activeResult.data?.tasks ?? const <AgentTask>[]);
      inReviewTasks.assignAll(
        inReviewResult.data?.tasks ?? const <AgentTask>[],
      );
      doneTasks.assignAll(doneResult.data?.tasks ?? const <AgentTask>[]);

      _currentPageByTab[0] = 1;
      _currentPageByTab[1] = 1;
      _currentPageByTab[2] = 1;
      _currentPageByTab[3] = 1;
      _totalByTab[0] = newResult.data?.total ?? newTasks.length;
      _totalByTab[1] = activeResult.data?.total ?? activeTasks.length;
      _totalByTab[2] = inReviewResult.data?.total ?? inReviewTasks.length;
      _totalByTab[3] = doneResult.data?.total ?? doneTasks.length;
      _hasMoreByTab[0] = newTasks.length < (_totalByTab[0] ?? 0);
      _hasMoreByTab[1] = activeTasks.length < (_totalByTab[1] ?? 0);
      _hasMoreByTab[2] = inReviewTasks.length < (_totalByTab[2] ?? 0);
      _hasMoreByTab[3] = doneTasks.length < (_totalByTab[3] ?? 0);

      final firstTask = (newTasks.isNotEmpty
          ? newTasks.first
          : activeTasks.isNotEmpty
          ? activeTasks.first
          : inReviewTasks.isNotEmpty
          ? inReviewTasks.first
          : doneTasks.isNotEmpty
          ? doneTasks.first
          : null);

      assignedLocation.value = firstTask?.location ?? '';

      _syncCache();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCurrentTabIfNeeded() async {
    final tabIndex = selectedTabIndex.value;
    if (isLoading.value || isLoadingMore.value || !(_hasMoreByTab[tabIndex] ?? false)) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final nextPage = (_currentPageByTab[tabIndex] ?? 1) + 1;
      final tab = switch (tabIndex) {
        0 => 'NEW',
        1 => 'ACTIVE',
        2 => 'IN_REVIEW',
        3 => 'DONE',
        _ => 'NEW',
      };

      final result = await ApiErrorHandler.call<AgentTasksListResponse>(
        () => _taskActionsService.fetchTasks(
          tab: tab,
          page: nextPage,
          limit: _pageLimit,
        ),
        showError: false,
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final targetList = _tasksForTab(tabIndex);
      final existingIds = targetList.map((task) => task.id).toSet();
      final newTasksForTab = result.data!.tasks
          .where((task) => !existingIds.contains(task.id))
          .toList();
      targetList.addAll(newTasksForTab);

      _currentPageByTab[tabIndex] = nextPage;
      _totalByTab[tabIndex] = result.data!.total;
      _hasMoreByTab[tabIndex] =
          targetList.length < (_totalByTab[tabIndex] ?? 0);

      _syncCache();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Navigate to task details
  /// Uses unified task details view for all task statuses
  void goToTaskDetails(AgentTask task) {
    final route = switch (task.status) {
      TaskStatus.newRequest => AppRoutes.AGENT_TASK_DETAILS_NEW,
      TaskStatus.active => AppRoutes.AGENT_TASK_DETAILS_ACTIVE,
      TaskStatus.inReview => AppRoutes.AGENT_TASK_DETAILS_IN_REVIEW,
      TaskStatus.done => AppRoutes.AGENT_TASK_DETAILS_DONE,
    };

    Get.toNamed(route, arguments: task);
  }

  /// Show service type filter bottom sheet
  void showServiceTypeFilter() {
    final maxSheetHeight = Get.height * 0.65;

    Get.bottomSheet(
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...ServiceTypeFilter.options.map((option) {
                        final isSelected = serviceTypeFilter.value == option;
                        return ListTile(
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            updateServiceTypeFilter(option);
                            Get.back();
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Refresh tasks
  Future<void> refresh() async {
    await loadTasks(forceRefresh: true);
  }

  void _restoreFromCache() {
    assignedLocation.value = _cachedAssignedLocation;
    selectedTabIndex.value = _cachedSelectedTabIndex;
    serviceTypeFilter.value = _cachedServiceTypeFilter;
    searchQuery.value = _cachedSearchQuery;
    searchController.text = _cachedSearchQuery;
    newTasks.assignAll(_cachedNewTasks);
    activeTasks.assignAll(_cachedActiveTasks);
    inReviewTasks.assignAll(_cachedInReviewTasks);
    doneTasks.assignAll(_cachedDoneTasks);
    _currentPageByTab[0] = _cachedNewPage;
    _currentPageByTab[1] = _cachedActivePage;
    _currentPageByTab[2] = _cachedInReviewPage;
    _currentPageByTab[3] = _cachedDonePage;
    _totalByTab[0] = _cachedNewTotal;
    _totalByTab[1] = _cachedActiveTotal;
    _totalByTab[2] = _cachedInReviewTotal;
    _totalByTab[3] = _cachedDoneTotal;
    _hasMoreByTab[0] = _cachedHasMoreNew;
    _hasMoreByTab[1] = _cachedHasMoreActive;
    _hasMoreByTab[2] = _cachedHasMoreInReview;
    _hasMoreByTab[3] = _cachedHasMoreDone;
  }

  void _syncCache() {
    _cachedAssignedLocation = assignedLocation.value;
    _cachedSelectedTabIndex = selectedTabIndex.value;
    _cachedSearchQuery = searchQuery.value;
    _cachedServiceTypeFilter = serviceTypeFilter.value;
    _cachedNewTasks = List<AgentTask>.from(newTasks);
    _cachedActiveTasks = List<AgentTask>.from(activeTasks);
    _cachedInReviewTasks = List<AgentTask>.from(inReviewTasks);
    _cachedDoneTasks = List<AgentTask>.from(doneTasks);
    _cachedNewPage = _currentPageByTab[0] ?? 1;
    _cachedActivePage = _currentPageByTab[1] ?? 1;
    _cachedInReviewPage = _currentPageByTab[2] ?? 1;
    _cachedDonePage = _currentPageByTab[3] ?? 1;
    _cachedNewTotal = _totalByTab[0] ?? newTasks.length;
    _cachedActiveTotal = _totalByTab[1] ?? activeTasks.length;
    _cachedInReviewTotal = _totalByTab[2] ?? inReviewTasks.length;
    _cachedDoneTotal = _totalByTab[3] ?? doneTasks.length;
    _cachedHasMoreNew = _hasMoreByTab[0] ?? false;
    _cachedHasMoreActive = _hasMoreByTab[1] ?? false;
    _cachedHasMoreInReview = _hasMoreByTab[2] ?? false;
    _cachedHasMoreDone = _hasMoreByTab[3] ?? false;
    _hasCachedData = true;
  }

  RxList<AgentTask> _tasksForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return newTasks;
      case 1:
        return activeTasks;
      case 2:
        return inReviewTasks;
      case 3:
        return doneTasks;
      default:
        return newTasks;
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
