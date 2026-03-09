import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../core/enums/property_type.dart';
import 'agent_appointments_services.dart';
import 'models/appointments_model.dart';

/// Controller for Agent Appointments screen
class AgentAppointmentsController extends GetxController {
  static const int _pageLimit = 10;
  static final Map<String, List<AgentAppointment>> _cachedAppointmentsByTab =
      <String, List<AgentAppointment>>{};
  static final Set<String> _loadedTabs = <String>{};
  static final Map<String, int> _cachedCurrentPageByTab = <String, int>{};
  static final Map<String, int> _cachedTotalByTab = <String, int>{};
  static final Map<String, bool> _cachedHasMoreByTab = <String, bool>{};

  // Tab state
  final RxString selectedTab = AgentAppointmentTabs.upcoming.obs;

  // Sort
  final RxString sortBy = 'Date'.obs;
  final List<String> sortOptions = [
    'Date (Newest First)',
    'Date (Oldest First)',
    'Visit Today',
    'Upcoming Visit',
    'Visited',
  ];

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  // All appointments
  final RxList<AgentAppointment> allAppointments = <AgentAppointment>[].obs;

  final Map<String, int> _currentPageByTab = <String, int>{};
  final Map<String, int> _totalByTab = <String, int>{};

  final _appointmentsServices = Get.find<AgentAppointmentsServices>();

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments({bool forceRefresh = false}) async {
    final currentTab = selectedTab.value;
    if (!forceRefresh && _loadedTabs.contains(currentTab)) {
      allAppointments.assignAll(
        _cachedAppointmentsByTab[currentTab] ?? const [],
      );
      hasMore.value = _cachedHasMoreByTab[currentTab] ?? false;
      return;
    }

    isLoading.value = true;
    _currentPageByTab[currentTab] = 1;
    hasMore.value = true;
    try {
      final apiTab = currentTab == AgentAppointmentTabs.upcoming
          ? 'UPCOMING'
          : 'PAST';

      final response = await ApiErrorHandler.call(
        () => _appointmentsServices.fetchAppointments(
          tab: apiTab,
          page: 1,
          limit: _pageLimit,
        ),
      );

      if (!response.isSuccess || response.data == null) {
        return;
      }

      final mapped = response.data!.data.map(_mapApiToViewModel).toList();
      allAppointments.assignAll(mapped);
      _totalByTab[currentTab] = response.data!.meta.total;
      hasMore.value = allAppointments.length < (_totalByTab[currentTab] ?? 0);
      _cachedAppointmentsByTab[currentTab] = List<AgentAppointment>.from(
        mapped,
      );
      _cachedCurrentPageByTab[currentTab] = 1;
      _cachedTotalByTab[currentTab] = _totalByTab[currentTab] ?? 0;
      _cachedHasMoreByTab[currentTab] = hasMore.value;
      _loadedTabs.add(currentTab);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreAppointmentsIfNeeded() async {
    final currentTab = selectedTab.value;
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final apiTab = currentTab == AgentAppointmentTabs.upcoming
          ? 'UPCOMING'
          : 'PAST';
      final nextPage = (_currentPageByTab[currentTab] ?? 1) + 1;

      final response = await ApiErrorHandler.call(
        () => _appointmentsServices.fetchAppointments(
          tab: apiTab,
          page: nextPage,
          limit: _pageLimit,
        ),
      );

      if (!response.isSuccess || response.data == null) {
        return;
      }

      final mapped = response.data!.data.map(_mapApiToViewModel).toList();
      final existingIds = allAppointments.map((item) => item.id).toSet();
      final newItems = mapped
          .where((item) => !existingIds.contains(item.id))
          .toList();

      allAppointments.addAll(newItems);
      _currentPageByTab[currentTab] = nextPage;
      _totalByTab[currentTab] = response.data!.meta.total;
      hasMore.value = allAppointments.length < (_totalByTab[currentTab] ?? 0);

      _cachedAppointmentsByTab[currentTab] = List<AgentAppointment>.from(
        allAppointments,
      );
      _cachedCurrentPageByTab[currentTab] = nextPage;
      _cachedTotalByTab[currentTab] = _totalByTab[currentTab] ?? 0;
      _cachedHasMoreByTab[currentTab] = hasMore.value;
      _loadedTabs.add(currentTab);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Get filtered appointments based on selected tab
  List<AgentAppointment> get filteredAppointments {
    final appointments = List<AgentAppointment>.from(allAppointments);

    switch (sortBy.value) {
      case 'Visit Today':
        appointments.retainWhere(
          (appointment) =>
              appointment.status == AgentAppointmentStatuses.visitToday,
        );
        appointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );
        break;
      case 'Upcoming Visit':
        appointments.retainWhere(
          (appointment) =>
              appointment.status == AgentAppointmentStatuses.upcomingVisit,
        );
        appointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );
        break;
      case 'Visited':
        appointments.retainWhere(
          (appointment) =>
              appointment.status == AgentAppointmentStatuses.visited,
        );
        appointments.sort(
          (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
        );
        break;
      case 'Date (Oldest First)':
        appointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );
        break;
      case 'Date (Newest First)':
      case 'Date':
      default:
        appointments.sort(
          (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
        );
        break;
    }

    return appointments;
  }

  /// Change appointments filter/sort option
  void changeSortBy(String value) {
    if (sortBy.value == value) {
      return;
    }
    sortBy.value = value;
  }

  /// Change tab
  Future<void> changeTab(String tab) async {
    if (selectedTab.value == tab) {
      return;
    }

    selectedTab.value = tab;

    if (_loadedTabs.contains(tab)) {
      allAppointments.assignAll(_cachedAppointmentsByTab[tab] ?? const []);
      _currentPageByTab[tab] = _cachedCurrentPageByTab[tab] ?? 1;
      _totalByTab[tab] = _cachedTotalByTab[tab] ?? allAppointments.length;
      hasMore.value = _cachedHasMoreByTab[tab] ?? false;
      return;
    }

    await loadAppointments(forceRefresh: true);
  }

  /// Refresh data
  Future<void> refresh() async {
    _loadedTabs.remove(selectedTab.value);
    _cachedAppointmentsByTab.remove(selectedTab.value);
    await loadAppointments(forceRefresh: true);
  }

  /// Navigate to appointment details
  Future<void> goToAppointmentDetails(AgentAppointment appointment) async {
    final response = await ApiErrorHandler.call(
      () => _appointmentsServices.fetchAppointmentDetails(
        assignmentId: appointment.id,
      ),
    );

    if (!response.isSuccess || response.data == null) {
      return;
    }

    final details = response.data!;
    final title = details.propertyTitle.isEmpty
        ? appointment.propertyTitle
        : details.propertyTitle;

    Get.snackbar(
      'Appointment Details',
      'Opened $title',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  AgentAppointment _mapApiToViewModel(AgentAppointmentApiModel item) {
    final appointmentDate = item.appointmentDate ?? DateTime.now();
    final status = _mapStatus(item.status, appointmentDate, selectedTab.value);

    return AgentAppointment(
      id: item.id,
      postId: item.postId.isEmpty ? '-' : item.postId,
      propertyTitle: item.propertyTitle,
      propertyType: _mapPropertyType(item.propertyType),
      location: item.location.isEmpty
          ? 'Location not specified'
          : item.location,
      status: status,
      appointmentDate: appointmentDate,
      serviceType: item.serviceType,
    );
  }

  String _mapStatus(String rawStatus, DateTime appointmentDate, String tab) {
    final normalized = rawStatus.trim().toLowerCase();

    if (normalized.contains('visited') || normalized.contains('past')) {
      return AgentAppointmentStatuses.visited;
    }
    if (normalized.contains('today')) {
      return AgentAppointmentStatuses.visitToday;
    }

    if (tab == AgentAppointmentTabs.past) {
      return AgentAppointmentStatuses.visited;
    }

    if (_isToday(appointmentDate)) {
      return AgentAppointmentStatuses.visitToday;
    }

    return AgentAppointmentStatuses.upcomingVisit;
  }

  PropertyType _mapPropertyType(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    if (normalized.contains('water')) {
      return PropertyType.waterLand;
    }
    if (normalized.contains('plain') || normalized.contains('land')) {
      return PropertyType.plainLand;
    }
    return PropertyType.flat;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
