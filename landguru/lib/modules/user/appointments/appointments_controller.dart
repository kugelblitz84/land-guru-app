import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import 'models/appointment_models.dart';
import 'services/appointment_services.dart';

/// Controller for User Appointments screen.
/// Uses string constants for tabs, filters, and statuses.
class AppointmentsController extends GetxController {
  static final Map<String, List<Appointment>> _cachedUpcomingByFilter =
      <String, List<Appointment>>{};
  static final Map<String, List<Appointment>> _cachedPastByFilter =
      <String, List<Appointment>>{};
  static bool _hasLoadedUpcoming = false;
  static bool _hasLoadedPast = false;

  final RxString selectedTab = AppointmentTabs.upcoming.obs;
  final RxString upcomingFilter = UpcomingFilters.myRequests.obs;
  final RxString pastFilter = PastFilters.myVisit.obs;

  final sortOptions = ['Date'];
  final sortBy = 'Date'.obs;

  final RxBool isLoading = false.obs;
  final RxList<Appointment> allAppointments = <Appointment>[].obs;

  final AppointmentServices _appointmentServices =
      Get.find<AppointmentServices>();

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasLoadedUpcoming && _hasLoadedPast) {
      _syncAllAppointments();
      return;
    }

    isLoading.value = true;
    try {
      if (forceRefresh) {
        _cachedUpcomingByFilter.clear();
        _cachedPastByFilter.clear();
      }

      await Future.wait([
        _fetchUpcomingByFilter(
          filter: UpcomingFilters.myRequests,
          forceRefresh: forceRefresh,
        ),
        _fetchUpcomingByFilter(
          filter: UpcomingFilters.upcomingVisit,
          forceRefresh: forceRefresh,
        ),
        _fetchUpcomingByFilter(
          filter: UpcomingFilters.agentVisit,
          forceRefresh: forceRefresh,
        ),
        _fetchPastByFilter(
          filter: PastFilters.myVisit,
          forceRefresh: forceRefresh,
        ),
        _fetchPastByFilter(
          filter: PastFilters.agentVisit,
          forceRefresh: forceRefresh,
        ),
      ]);

      _syncAllAppointments();
      _hasLoadedUpcoming = true;
      _hasLoadedPast = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUpcomingByFilter({
    required String filter,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedUpcomingByFilter.containsKey(filter)) {
      return;
    }

    final result = await ApiErrorHandler.call(() {
      if (filter == UpcomingFilters.myRequests) {
        return _appointmentServices.fetchUpcomingMyRequests(page: 1, limit: 10);
      }
      if (filter == UpcomingFilters.upcomingVisit) {
        return _appointmentServices.fetchUpcomingVisits(page: 1, limit: 10);
      }
      return _appointmentServices.fetchUpcomingAgentVisits(page: 1, limit: 10);
    }, showError: false);

    if (!result.isSuccess || result.data == null) {
      return;
    }

    _cachedUpcomingByFilter[filter] = result.data!.appointments;
  }

  Future<void> _fetchPastByFilter({
    required String filter,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedPastByFilter.containsKey(filter)) {
      return;
    }

    final result = await ApiErrorHandler.call(() {
      if (filter == PastFilters.myVisit) {
        return _appointmentServices.fetchPastMyVisits(page: 1, limit: 10);
      }
      return _appointmentServices.fetchPastAgentVisits(page: 1, limit: 10);
    }, showError: false);

    if (!result.isSuccess || result.data == null) {
      return;
    }

    _cachedPastByFilter[filter] = result.data!.appointments;
  }

  void _syncAllAppointments() {
    final merged = <Appointment>[
      ...(_cachedUpcomingByFilter[UpcomingFilters.myRequests] ?? const []),
      ...(_cachedUpcomingByFilter[UpcomingFilters.upcomingVisit] ?? const []),
      ...(_cachedUpcomingByFilter[UpcomingFilters.agentVisit] ?? const []),
      ...(_cachedPastByFilter[PastFilters.myVisit] ?? const []),
      ...(_cachedPastByFilter[PastFilters.agentVisit] ?? const []),
    ];

    final uniqueById = <String, Appointment>{};
    for (final appointment in merged) {
      uniqueById[appointment.id] = appointment;
    }

    allAppointments.assignAll(uniqueById.values);
  }

  List<Appointment> get filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (selectedTab.value == AppointmentTabs.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilters.myRequests:
          return allAppointments
              .where(
                (a) =>
                    a.status == AppointmentStatuses.pendingAdminReview &&
                    a.price != null,
              )
              .toList();
        case UpcomingFilters.upcomingVisit:
          return allAppointments
              .where(
                (a) =>
                    (a.status == AppointmentStatuses.visitToday ||
                        a.status == AppointmentStatuses.upcomingVisit) &&
                    a.clientName != null &&
                    !a.appointmentDate.isBefore(today),
              )
              .toList();
        case UpcomingFilters.agentVisit:
          return allAppointments
              .where(
                (a) =>
                    (a.status == AppointmentStatuses.visitToday ||
                        a.status == AppointmentStatuses.upcomingVisit) &&
                    a.agentName != null &&
                    !a.appointmentDate.isBefore(today),
              )
              .toList();
        default:
          return const <Appointment>[];
      }
    }

    switch (pastFilter.value) {
      case PastFilters.myVisit:
        return allAppointments
            .where(
              (a) =>
                  a.status == AppointmentStatuses.visited &&
                  a.clientName != null,
            )
            .toList();
      case PastFilters.agentVisit:
        return allAppointments
            .where(
              (a) =>
                  a.status == AppointmentStatuses.visited &&
                  a.agentName != null,
            )
            .toList();
      default:
        return const <Appointment>[];
    }
  }

  int get agentVisitBadgeCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allAppointments
        .where(
          (a) =>
              (a.status == AppointmentStatuses.visitToday ||
                  a.status == AppointmentStatuses.upcomingVisit) &&
              a.agentName != null &&
              !a.appointmentDate.isBefore(today),
        )
        .length;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    if (tab == AppointmentTabs.upcoming) {
      upcomingFilter.value = UpcomingFilters.myRequests;
    } else {
      pastFilter.value = PastFilters.myVisit;
    }
  }

  void changeUpcomingFilter(String filter) {
    upcomingFilter.value = filter;
    _fetchUpcomingByFilter(filter: filter).then((_) => _syncAllAppointments());
  }

  void changePastFilter(String filter) {
    pastFilter.value = filter;
    _fetchPastByFilter(filter: filter).then((_) => _syncAllAppointments());
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    try {
      await loadAppointments(forceRefresh: true);
    } finally {
      isLoading.value = false;
    }
  }

  void goToAppointmentDetails(Appointment appointment) {
    Get.snackbar(
      'Appointment Details',
      'Opening ${appointment.propertyTitle}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String get sectionTitle {
    if (selectedTab.value == AppointmentTabs.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilters.myRequests:
          return 'My Requests';
        case UpcomingFilters.upcomingVisit:
          return 'Upcoming Visits';
        case UpcomingFilters.agentVisit:
          return 'Agent Visit';
        default:
          return '';
      }
    }
    return '';
  }

  String get sectionSubtitle {
    if (selectedTab.value == AppointmentTabs.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilters.myRequests:
          return 'These are the post you requested to visit';
        case UpcomingFilters.upcomingVisit:
          return '';
        case UpcomingFilters.agentVisit:
          return 'Check which agents are going to visit your property(s)';
        default:
          return '';
      }
    }
    return '';
  }
}
