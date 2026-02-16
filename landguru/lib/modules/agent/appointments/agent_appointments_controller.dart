import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/theme/app_colors.dart';
import 'agent_appointments_services.dart';
import 'models/appointments_model.dart';

/// Tab enum for Agent Appointments
enum AgentAppointmentTab { upcoming, past }

/// Status enum for agent appointments
enum AgentAppointmentStatus { visitToday, upcomingVisit, visited }

extension AgentAppointmentStatusExtension on AgentAppointmentStatus {
  String get label {
    switch (this) {
      case AgentAppointmentStatus.visitToday:
        return 'Visit Today';
      case AgentAppointmentStatus.upcomingVisit:
        return 'Upcoming Visit';
      case AgentAppointmentStatus.visited:
        return 'Visited';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AgentAppointmentStatus.visitToday:
        return AppColors.success;
      case AgentAppointmentStatus.upcomingVisit:
        return AppColors.primary;
      case AgentAppointmentStatus.visited:
        return AppColors.grey400;
    }
  }

  Color get textColor => AppColors.white;
}

/// Agent Appointment model
class AgentAppointment {
  final String id;
  final String postId;
  final String propertyTitle;
  final PropertyType propertyType;
  final String location;
  final AgentAppointmentStatus status;
  final DateTime appointmentDate;
  final String serviceType;

  AgentAppointment({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.propertyType,
    required this.location,
    required this.status,
    required this.appointmentDate,
    required this.serviceType,
  });

  /// Get property type label
  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  /// Get property type color
  Color get propertyTypeColor {
    switch (propertyType) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32);
      case PropertyType.waterLand:
        return const Color(0xFF0288D1);
      case PropertyType.flat:
        return AppColors.primary;
    }
  }

  /// Format date as month abbreviation
  String get formattedMonth {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[appointmentDate.month - 1];
  }

  /// Format date as day number
  String get formattedDay => appointmentDate.day.toString();

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }
}

/// Controller for Agent Appointments screen
class AgentAppointmentsController extends GetxController {
  static const int _pageLimit = 10;
  static final Map<AgentAppointmentTab, List<AgentAppointment>>
  _cachedAppointmentsByTab = <AgentAppointmentTab, List<AgentAppointment>>{};
  static final Set<AgentAppointmentTab> _loadedTabs = <AgentAppointmentTab>{};
  static final Map<AgentAppointmentTab, int> _cachedCurrentPageByTab =
      <AgentAppointmentTab, int>{};
  static final Map<AgentAppointmentTab, int> _cachedTotalByTab =
      <AgentAppointmentTab, int>{};
  static final Map<AgentAppointmentTab, bool> _cachedHasMoreByTab =
      <AgentAppointmentTab, bool>{};

  // Tab state
  final Rx<AgentAppointmentTab> selectedTab = AgentAppointmentTab.upcoming.obs;

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

  final Map<AgentAppointmentTab, int> _currentPageByTab =
      <AgentAppointmentTab, int>{};
  final Map<AgentAppointmentTab, int> _totalByTab =
      <AgentAppointmentTab, int>{};

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
      final apiTab = currentTab == AgentAppointmentTab.upcoming
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
      final apiTab = currentTab == AgentAppointmentTab.upcoming
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
              appointment.status == AgentAppointmentStatus.visitToday,
        );
        appointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );
        break;
      case 'Upcoming Visit':
        appointments.retainWhere(
          (appointment) =>
              appointment.status == AgentAppointmentStatus.upcomingVisit,
        );
        appointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );
        break;
      case 'Visited':
        appointments.retainWhere(
          (appointment) => appointment.status == AgentAppointmentStatus.visited,
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
  Future<void> changeTab(AgentAppointmentTab tab) async {
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

  AgentAppointmentStatus _mapStatus(
    String rawStatus,
    DateTime appointmentDate,
    AgentAppointmentTab tab,
  ) {
    final normalized = rawStatus.trim().toLowerCase();

    if (normalized.contains('visited') || normalized.contains('past')) {
      return AgentAppointmentStatus.visited;
    }
    if (normalized.contains('today')) {
      return AgentAppointmentStatus.visitToday;
    }

    if (tab == AgentAppointmentTab.past) {
      return AgentAppointmentStatus.visited;
    }

    if (_isToday(appointmentDate)) {
      return AgentAppointmentStatus.visitToday;
    }

    return AgentAppointmentStatus.upcomingVisit;
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
