import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import 'models/appointment_models.dart';

/// Controller for User Appointments screen
/// Handles: Upcoming/Past tabs with secondary filters
class AppointmentsController extends GetxController {
  static List<Appointment> _cachedAppointments = <Appointment>[];
  static bool _hasCachedData = false;

  // Primary tab state (Upcoming / Past)
  final Rx<AppointmentTab> selectedTab = AppointmentTab.upcoming.obs;

  // Secondary filter states
  final Rx<UpcomingFilter> upcomingFilter = UpcomingFilter.myRequests.obs;
  final Rx<PastFilter> pastFilter = PastFilter.myVisit.obs;

  // Sort options
  final sortOptions = ['Date'];
  final sortBy = 'Date'.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // All appointments data
  final RxList<Appointment> allAppointments = <Appointment>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      allAppointments.assignAll(_cachedAppointments);
      return;
    }

    _loadDemoData();
    _cachedAppointments = List<Appointment>.from(allAppointments);
    _hasCachedData = true;
  }

  /// Load demo data
  void _loadDemoData() {
    final now = DateTime.now();

    allAppointments.value = [
      // My Requests (Upcoming)
      Appointment(
        id: '1',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.pendingAdminReview,
        appointmentDate: now.add(const Duration(days: 5)),
        requestedAt: now.subtract(const Duration(hours: 2)),
        price: '40,00,000',
      ),
      Appointment(
        id: '2',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.pendingAdminReview,
        appointmentDate: now.add(const Duration(days: 3)),
        requestedAt: now.subtract(const Duration(hours: 2)),
        price: '4,00,00,000',
      ),

      // Upcoming Visits
      Appointment(
        id: '3',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visitToday,
        appointmentDate: now,
        clientName: 'Farhan',
        clientId: 'client_1',
      ),
      Appointment(
        id: '4',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.upcomingVisit,
        appointmentDate: now.add(const Duration(days: 1)),
        clientName: 'Farhan',
        clientId: 'client_1',
      ),

      // Agent Visits (Upcoming)
      Appointment(
        id: '5',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visitToday,
        appointmentDate: now,
        serviceType: 'Ownership History Validation',
        agentName: 'Adv. Sahil',
        agentId: 'agent_1',
      ),
      Appointment(
        id: '6',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.upcomingVisit,
        appointmentDate: now.add(const Duration(days: 1)),
        serviceType: 'Ownership History Validation',
        agentName: 'Adv. Sahil',
        agentId: 'agent_1',
      ),

      // Past - My Visits
      Appointment(
        id: '7',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visited,
        appointmentDate: DateTime(now.year, 12, 25),
        clientName: 'Farhan',
        clientId: 'client_1',
      ),
      Appointment(
        id: '8',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visited,
        appointmentDate: DateTime(now.year, 12, 21),
        clientName: 'Farhan',
        clientId: 'client_1',
      ),

      // Past - Agent Visits
      Appointment(
        id: '9',
        postId: '#POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visited,
        appointmentDate: DateTime(now.year, 1, 25),
        serviceType: 'Ownership History Validation',
        agentName: 'Adv. Sahil',
        agentId: 'agent_1',
      ),
      Appointment(
        id: '10',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AppointmentStatus.visited,
        appointmentDate: DateTime(now.year, 1, 26),
        serviceType: 'Ownership History Validation',
        agentName: 'Adv. Sahil',
        agentId: 'agent_1',
      ),
    ];
  }

  /// Get filtered appointments based on current tab and filter
  List<Appointment> get filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (selectedTab.value == AppointmentTab.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilter.myRequests:
          return allAppointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.pendingAdminReview &&
                    a.price != null,
              )
              .toList();
        case UpcomingFilter.upcomingVisit:
          return allAppointments
              .where(
                (a) =>
                    (a.status == AppointmentStatus.visitToday ||
                        a.status == AppointmentStatus.upcomingVisit) &&
                    a.clientName != null &&
                    !a.appointmentDate.isBefore(today),
              )
              .toList();
        case UpcomingFilter.agentVisit:
          return allAppointments
              .where(
                (a) =>
                    (a.status == AppointmentStatus.visitToday ||
                        a.status == AppointmentStatus.upcomingVisit) &&
                    a.agentName != null &&
                    !a.appointmentDate.isBefore(today),
              )
              .toList();
      }
    } else {
      // Past tab
      switch (pastFilter.value) {
        case PastFilter.myVisit:
          return allAppointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.visited &&
                    a.clientName != null,
              )
              .toList();
        case PastFilter.agentVisit:
          return allAppointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.visited &&
                    a.agentName != null,
              )
              .toList();
      }
    }
  }

  /// Get badge count for Agent Visit filter
  int get agentVisitBadgeCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allAppointments
        .where(
          (a) =>
              (a.status == AppointmentStatus.visitToday ||
                  a.status == AppointmentStatus.upcomingVisit) &&
              a.agentName != null &&
              !a.appointmentDate.isBefore(today),
        )
        .length;
  }

  /// Change primary tab
  void changeTab(AppointmentTab tab) {
    selectedTab.value = tab;
    // Reset filters when changing tabs
    if (tab == AppointmentTab.upcoming) {
      upcomingFilter.value = UpcomingFilter.myRequests;
    } else {
      pastFilter.value = PastFilter.myVisit;
    }
  }

  /// Change upcoming filter
  void changeUpcomingFilter(UpcomingFilter filter) {
    upcomingFilter.value = filter;
  }

  /// Change past filter
  void changePastFilter(PastFilter filter) {
    pastFilter.value = filter;
  }

  /// Refresh data
  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    await loadAppointments(forceRefresh: true);
    isLoading.value = false;
  }

  /// Navigate to appointment details
  void goToAppointmentDetails(Appointment appointment) {
    Get.snackbar(
      'Appointment Details',
      'Opening ${appointment.propertyTitle}...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to appointment details page
  }

  /// Get section title based on current filter
  String get sectionTitle {
    if (selectedTab.value == AppointmentTab.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilter.myRequests:
          return 'My Requests';
        case UpcomingFilter.upcomingVisit:
          return 'Upcoming Visits';
        case UpcomingFilter.agentVisit:
          return 'Agent Visit';
      }
    } else {
      return '';
    }
  }

  /// Get section subtitle based on current filter
  String get sectionSubtitle {
    if (selectedTab.value == AppointmentTab.upcoming) {
      switch (upcomingFilter.value) {
        case UpcomingFilter.myRequests:
          return 'These are the post you requested to visit';
        case UpcomingFilter.upcomingVisit:
          return '';
        case UpcomingFilter.agentVisit:
          return 'Check which agents are going to visit your property(s)';
      }
    }
    return '';
  }
}
