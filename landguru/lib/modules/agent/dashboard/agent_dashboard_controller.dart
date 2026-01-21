import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../shared/bottom_nav/agent_bottom_nav_controller.dart';
import 'models/dashboard_models.dart';

/// Controller for the Agent Dashboard/Home screen
class AgentDashboardController extends GetxController {
  // State
  final RxBool isLoading = false.obs;

  // Assigned location
  final RxString assignedLocation = ''.obs;

  // Stats
  final Rx<DashboardStats> stats = DashboardStats(
    newRequests: 0,
    activeJobs: 0,
    doneThisMonth: 0,
    currentMonth: 'Jan',
  ).obs;

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
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // TODO: Load agent dashboard data from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      assignedLocation.value =
          'Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.';

      stats.value = DashboardStats(
        newRequests: 3,
        activeJobs: 5,
        doneThisMonth: 12,
        currentMonth: 'Jan',
      );

      // Mock requires scheduling data
      requiresScheduling.value = [
        SchedulingTask(
          id: '1',
          serviceId: '#SERV892-POST-1042',
          serviceName: 'Pentagraph Map Verification',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          acceptBefore: DateTime(2026, 1, 12, 12, 0),
          assignedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        SchedulingTask(
          id: '2',
          serviceId: '#SERV892-POST-1043',
          serviceName: 'Ownership History Verification',
          location:
              'Block-C, Banani, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          acceptBefore: DateTime(2026, 1, 12, 14, 0),
          assignedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        SchedulingTask(
          id: '3',
          serviceId: '#SERV892-POST-1044',
          serviceName: 'Document Verification',
          location:
              'Gulshan-2, Dhaka North City Corporation, Dhaka-1212, Dhaka, Bangladesh.',
          acceptBefore: DateTime(2026, 1, 13, 10, 0),
          assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      // Mock today's schedule
      todaySchedule.value = [
        ScheduleItem(
          id: '1',
          serviceId: '#SERV892-POST-1042',
          time: '10:00 AM',
          type: 'Client Meeting',
          clientName: 'Farhan',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          itemType: ScheduleItemType.clientMeeting,
        ),
        ScheduleItem(
          id: '2',
          serviceId: '#SERV892-POST-1042',
          time: '12:30 PM',
          type: 'Site Visit',
          clientName: 'Farhan',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          itemType: ScheduleItemType.siteVisit,
        ),
        ScheduleItem(
          id: '3',
          serviceId: '#SERV892-POST-1042',
          time: '4:30 PM',
          type: 'Site Visit',
          clientName: 'Farhan',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          itemType: ScheduleItemType.siteVisit,
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
    await loadDashboardData();
  }
}
