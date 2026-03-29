import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/agent_bottom_nav_controller.dart';
import 'models/dashboard_models.dart';
import 'services/agent_dashboard_service.dart';

/// Controller for the Agent Dashboard/Home screen
class AgentDashboardController extends GetxController {
  final AgentDashboardService _dashboardService =
      Get.find<AgentDashboardService>();

  static String _cachedAssignedLocation = '';
  static DashboardStats _cachedStats = DashboardStats.empty();
  static List<SchedulingTask> _cachedRequiresScheduling = <SchedulingTask>[];
  static List<ScheduleItem> _cachedTodaySchedule = <ScheduleItem>[];
  static String _cachedTodayDateLabel = '';
  static bool _hasCachedData = false;

  // State
  final RxBool isLoading = false.obs;

  // Assigned location
  final RxString assignedLocation = ''.obs;

  // Stats
  final Rx<DashboardStats> stats = DashboardStats.empty().obs;

  final Rx<AgentDashboardData> dashboardData = AgentDashboardData.empty().obs;

  // Requires scheduling list
  final RxList<SchedulingTask> requiresScheduling = <SchedulingTask>[].obs;

  // Today's schedule
  final RxList<ScheduleItem> todaySchedule = <ScheduleItem>[].obs;

  // Today's date for header
  final RxString todayDateLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setTodayDate();
    loadDashboardData();
  }

  void _setTodayDate() {
    final now = DateTime.now();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    todayDateLabel.value = '${months[now.month - 1]} ${now.day}';
  }

  /// Load dashboard data
  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    final payload = const DashboardLoadPayload();
    final result = await ApiErrorHandler.call<AgentDashboardData>(
      () => _dashboardService.fetchDashboardData(payload: payload),
      errorTitle: 'Dashboard',
      fallbackMessage: 'Failed to load dashboard data',
    );
    if (!result.isSuccess) {
      isLoading.value = false;
      return;
    }

    final data = result.data ?? AgentDashboardData.empty();
    dashboardData.value = dashboardData.value.copyWith(
      assignedLocation: data.assignedLocation,
      stats: data.stats,
      requiresScheduling: List<SchedulingTask>.from(data.requiresScheduling),
      todaySchedule: List<ScheduleItem>.from(data.todaySchedule),
    );

    assignedLocation.value = data.assignedLocation;
    stats.value = stats.value.copyWith(
      newRequests: data.stats.newRequests,
      activeJobs: data.stats.activeJobs,
      doneThisMonth: data.stats.doneThisMonth,
      currentMonth: data.stats.currentMonth,
    );
    requiresScheduling.assignAll(data.requiresScheduling);
    todaySchedule.assignAll(data.todaySchedule);

    _syncCache();
    isLoading.value = false;
  }

  /// Navigate to notifications
  void goToNotifications() {
    final navController = Get.find<AgentBottomNavController>();
    navController.goToNotifications();
  }

  /// View task details from requires scheduling
  void goToTaskDetails(SchedulingTask task) {
    Get.toNamed(
      AppRoutes.AGENT_TASK_DETAILS_NEW,
      arguments: {'taskId': task.id},
    );
  }

  /// View schedule item details
  void goToScheduleDetails(ScheduleItem item) {
    Get.toNamed(
      AppRoutes.AGENT_APPOINTMENT_DETAILS,
      arguments: {'appointmentId': item.id},
      id: 0,
    );
  }

  /// View all requires scheduling - go to My Tasks tab
  void viewAllRequiresScheduling() {
    final navController = Get.find<AgentBottomNavController>();
    navController.changeTab(1); // My Tasks tab
  }

  /// Navigate to new requests
  void goToNewRequests() {
    final navController = Get.find<AgentBottomNavController>();
    navController.changeTab(1); // My Tasks tab
  }

  /// Navigate to active jobs
  void goToActiveJobs() {
    final navController = Get.find<AgentBottomNavController>();
    navController.changeTab(1); // My Tasks tab
  }

  /// Navigate to done jobs
  void goToDoneJobs() {
    final navController = Get.find<AgentBottomNavController>();
    navController.changeTab(1); // My Tasks tab
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardData(forceRefresh: true);
  }

  void _restoreFromCache() {
    assignedLocation.value = _cachedAssignedLocation;
    stats.value = _cachedStats;
    requiresScheduling.assignAll(_cachedRequiresScheduling);
    todaySchedule.assignAll(_cachedTodaySchedule);
    dashboardData.value = dashboardData.value.copyWith(
      assignedLocation: _cachedAssignedLocation,
      stats: _cachedStats,
      requiresScheduling: List<SchedulingTask>.from(_cachedRequiresScheduling),
      todaySchedule: List<ScheduleItem>.from(_cachedTodaySchedule),
    );
    todayDateLabel.value = _cachedTodayDateLabel;
  }

  void _syncCache() {
    _cachedAssignedLocation = assignedLocation.value;
    _cachedStats = stats.value;
    _cachedRequiresScheduling = List<SchedulingTask>.from(requiresScheduling);
    _cachedTodaySchedule = List<ScheduleItem>.from(todaySchedule);
    _cachedTodayDateLabel = todayDateLabel.value;
    _hasCachedData = true;
  }
}
