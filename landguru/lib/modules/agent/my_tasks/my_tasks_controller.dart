import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/task_models.dart';

/// Controller for Agent My Tasks screen
/// Handles: New, Active, In Review, Done tabs
class AgentMyTasksController extends GetxController {
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

  // Tasks lists by status
  final RxList<AgentTask> newTasks = <AgentTask>[].obs;
  final RxList<AgentTask> activeTasks = <AgentTask>[].obs;
  final RxList<AgentTask> inReviewTasks = <AgentTask>[].obs;
  final RxList<AgentTask> doneTasks = <AgentTask>[].obs;

  // Agent's assigned location
  final RxString assignedLocation = ''.obs;

  /// Get current tasks based on selected tab
  List<AgentTask> get currentTasks {
    List<AgentTask> tasks;
    switch (selectedTabIndex.value) {
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
  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      // TODO: Load tasks from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Set assigned location
      assignedLocation.value =
          'Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.';

      // Mock data for new tasks
      newTasks.value = _generateMockNewTasks();
      activeTasks.value = _generateMockActiveTasks();
      inReviewTasks.value = _generateMockInReviewTasks();
      doneTasks.value = _generateMockDoneTasks();
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

  /// Generate mock new tasks
  List<AgentTask> _generateMockNewTasks() {
    final now = DateTime.now();
    final acceptBefore = DateTime(2026, 1, 12, 0, 0);

    // Common property photos
    const photos = [
      'assets/images/Properties demo/06dbc3d9ecaf49c8d2530fa47d00ffc27b015e09.jpg',
      'assets/images/Properties demo/2f5cdf5df8bac3e6a2f6f5530709720e85f6e282.jpg',
      'assets/images/Properties demo/e303744879b902818e5aaac7a0ba36105209ee73.jpg',
      'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
    ];

    // Common documents
    const documents = [
      TaskDocument(id: 'doc1', name: 'Deed document 1.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc2', name: 'Deed document 2.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc3', name: 'Deed document', size: '1.5MB'),
    ];

    return [
      AgentTask(
        id: '1',
        serviceId: '#SERV892-POST-1042',
        serviceType: ServiceType.ownershipHistoryValidation,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 10)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 15,
        sellableLandUnit: 'Katha',
        plotSize: 15,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '200m-750m',
        serviceFee: 40000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '2',
        serviceId: '#SERV893-POST-1042',
        serviceType: ServiceType.pentagraphMapVerification,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 15)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 20,
        sellableLandUnit: 'Katha',
        plotSize: 20,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '100m-200m',
        serviceFee: 35000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '3',
        serviceId: '#SERV894-POST-1042',
        serviceType: ServiceType.physicalEstimateBorderDemarcation,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.plot,
        sellableLandAmount: 10,
        sellableLandUnit: 'Katha',
        plotSize: 10,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '50m-100m',
        serviceFee: 45000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '4',
        serviceId: '#SERV895-POST-1042',
        serviceType: ServiceType.deedWritingService,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 8,
        sellableLandUnit: 'Katha',
        plotSize: 8,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '0m-50m',
        serviceFee: 30000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '5',
        serviceId: '#SERV896-POST-1042',
        serviceType: ServiceType.documentOrganization,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.building,
        sellableLandAmount: 25,
        sellableLandUnit: 'Katha',
        plotSize: 25,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '100m-200m',
        serviceFee: 25000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '6',
        serviceId: '#SERV897-POST-1042',
        serviceType: ServiceType.namjariDcrUpdate,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 30,
        sellableLandUnit: 'Katha',
        plotSize: 30,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '200m-500m',
        serviceFee: 50000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '7',
        serviceId: '#SERV898-POST-1042',
        serviceType: ServiceType.inheritanceDisputeAnalysis,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 12,
        sellableLandUnit: 'Katha',
        plotSize: 12,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '100m-150m',
        serviceFee: 55000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '8',
        serviceId: '#SERV899-POST-1042',
        serviceType: ServiceType.governmentAcquisitionRisk,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.plot,
        sellableLandAmount: 18,
        sellableLandUnit: 'Katha',
        plotSize: 18,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '150m-300m',
        serviceFee: 60000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
      AgentTask(
        id: '9',
        serviceId: '#SERV900-POST-1042',
        serviceType: ServiceType.courtCaseVerification,
        status: TaskStatus.newRequest,
        acceptanceStatus: TaskAcceptanceStatus.pendingAccepting,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        acceptBefore: acceptBefore,
        assignedAt: now.subtract(const Duration(minutes: 18)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 22,
        sellableLandUnit: 'Katha',
        plotSize: 22,
        plotSizeUnit: 'Katha',
        distanceFromRoad: '50m-100m',
        serviceFee: 48000,
        propertyPhotos: photos,
        rawDocuments: documents,
      ),
    ];
  }

  /// Generate mock active tasks
  List<AgentTask> _generateMockActiveTasks() {
    final now = DateTime.now();

    // Common photos and documents
    const photos = [
      'assets/images/Properties demo/06dbc3d9ecaf49c8d2530fa47d00ffc27b015e09.jpg',
      'assets/images/Properties demo/2f5cdf5df8bac3e6a2f6f5530709720e85f6e282.jpg',
      'assets/images/Properties demo/e303744879b902818e5aaac7a0ba36105209ee73.jpg',
      'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
    ];

    const documents = [
      TaskDocument(id: 'doc1', name: 'Deed document 1.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc2', name: 'Deed document 2.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc3', name: 'Deed document', size: '1.5MB'),
    ];

    // Work log with document upload
    final workLogWithDocument = [
      WorkLogEntry(
        id: 'wl1',
        description: 'Uploaded new verified document',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: WorkLogEntryType.documentUpload,
        attachment: const TaskDocument(
          id: 'verified_doc1',
          name: 'Verified document 1 .pdf',
          size: '1.5MB',
        ),
      ),
      WorkLogEntry(
        id: 'wl2',
        description: 'You accepted the task',
        timestamp: now.subtract(const Duration(days: 1)),
        type: WorkLogEntryType.taskAccepted,
      ),
    ];

    // Work log with appointment scheduled
    final workLogWithAppointment = [
      WorkLogEntry(
        id: 'wl3',
        description: 'Site Visit Scheduled for 12 Jan 2026, 10:00AM',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: WorkLogEntryType.appointmentScheduled,
      ),
      WorkLogEntry(
        id: 'wl4',
        description: 'Uploaded new verified document',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: WorkLogEntryType.documentUpload,
        attachment: const TaskDocument(
          id: 'verified_doc2',
          name: 'Verified document 1 .pdf',
          size: '1.5MB',
        ),
      ),
      WorkLogEntry(
        id: 'wl5',
        description: 'You accepted the task',
        timestamp: now.subtract(const Duration(days: 1)),
        type: WorkLogEntryType.taskAccepted,
      ),
    ];

    // Upcoming appointment
    final upcomingAppointment = TaskAppointment(
      id: 'apt1',
      type: 'Site Visit',
      dateTime: DateTime(2026, 1, 12, 10, 0),
      status: AppointmentStatus.upcoming,
    );

    // Visited appointment
    final visitedAppointment = TaskAppointment(
      id: 'apt2',
      type: 'Site Visit',
      dateTime: DateTime(2026, 1, 10, 10, 0),
      status: AppointmentStatus.visited,
    );

    return [
      // Active task with appointment scheduled (UPCOMING)
      AgentTask(
        id: '10',
        serviceId: '#SERV892-POST-1042',
        serviceType: ServiceType.ownershipHistoryValidation,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.processing,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 1)),
        lastUpdate: 'Fixed Appointment',
        lastUpdateAt: now.subtract(const Duration(hours: 1)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 15,
        plotSize: 15,
        distanceFromRoad: '200m-750m',
        serviceFee: 40000,
        propertyPhotos: photos,
        rawDocuments: documents,
        appointment: upcomingAppointment,
        workLog: workLogWithAppointment,
      ),
      // Active task with visited appointment
      AgentTask(
        id: '11',
        serviceId: '#SERV893-POST-1042',
        serviceType: ServiceType.pentagraphMapVerification,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.processing,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-D, Dhanmondi, Dhaka South City Corporation, Dhaka-1205, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 2)),
        lastUpdate: 'Uploaded Document',
        lastUpdateAt: now.subtract(const Duration(hours: 2)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 20,
        plotSize: 20,
        distanceFromRoad: '100m-200m',
        serviceFee: 35000,
        propertyPhotos: photos,
        rawDocuments: documents,
        appointment: visitedAppointment,
        workLog: workLogWithDocument,
      ),
      // Active task without appointment (just accepted)
      AgentTask(
        id: '12',
        serviceId: '#SERV894-POST-1042',
        serviceType: ServiceType.physicalEstimateBorderDemarcation,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.accepted,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Sector-10, Uttara, Dhaka North City Corporation, Dhaka-1230, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(hours: 5)),
        lastUpdate: 'Accepted task',
        lastUpdateAt: now.subtract(const Duration(hours: 5)),
        propertyType: TaskPropertyType.plot,
        sellableLandAmount: 10,
        plotSize: 10,
        distanceFromRoad: '50m-100m',
        serviceFee: 45000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: [
          WorkLogEntry(
            id: 'wl6',
            description: 'You accepted the task',
            timestamp: now.subtract(const Duration(hours: 5)),
            type: WorkLogEntryType.taskAccepted,
          ),
        ],
      ),
      // More active tasks with varying states
      AgentTask(
        id: '13',
        serviceId: '#SERV895-POST-1042',
        serviceType: ServiceType.deedWritingService,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.processing,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Section-12, Mirpur, Dhaka North City Corporation, Dhaka-1216, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 3)),
        lastUpdate: 'Uploaded Document',
        lastUpdateAt: now.subtract(const Duration(hours: 4)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 8,
        plotSize: 8,
        distanceFromRoad: '0m-50m',
        serviceFee: 30000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: workLogWithDocument,
      ),
      AgentTask(
        id: '14',
        serviceId: '#SERV896-POST-1042',
        serviceType: ServiceType.documentOrganization,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.processing,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-E, Banani, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 2)),
        lastUpdate: 'Uploaded Document',
        lastUpdateAt: now.subtract(const Duration(hours: 6)),
        propertyType: TaskPropertyType.building,
        sellableLandAmount: 25,
        plotSize: 25,
        distanceFromRoad: '100m-200m',
        serviceFee: 25000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: workLogWithDocument,
      ),
      AgentTask(
        id: '15',
        serviceId: '#SERV897-POST-1042',
        serviceType: ServiceType.namjariDcrUpdate,
        status: TaskStatus.active,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.processing,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-A, Mohammadpur, Dhaka South City Corporation, Dhaka-1207, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 4)),
        lastUpdate: 'Uploaded Document',
        lastUpdateAt: now.subtract(const Duration(hours: 8)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 30,
        plotSize: 30,
        distanceFromRoad: '200m-500m',
        serviceFee: 50000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: workLogWithDocument,
      ),
    ];
  }

  /// Generate mock in review tasks
  List<AgentTask> _generateMockInReviewTasks() {
    final now = DateTime.now();

    // Common photos and documents
    const photos = [
      'assets/images/Properties demo/06dbc3d9ecaf49c8d2530fa47d00ffc27b015e09.jpg',
      'assets/images/Properties demo/2f5cdf5df8bac3e6a2f6f5530709720e85f6e282.jpg',
    ];

    const documents = [
      TaskDocument(id: 'doc1', name: 'Deed document 1.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc2', name: 'Deed document 2.pdf', size: '1.5MB'),
    ];

    // Work log for in-review tasks
    final inReviewWorkLog = [
      WorkLogEntry(
        id: 'wl_submitted',
        description: 'Submitted for review',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: WorkLogEntryType.submitted,
      ),
      WorkLogEntry(
        id: 'wl_doc',
        description: 'Uploaded new verified document',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: WorkLogEntryType.documentUpload,
        attachment: const TaskDocument(
          id: 'verified_doc',
          name: 'Verified document 1 .pdf',
          size: '1.5MB',
        ),
      ),
      WorkLogEntry(
        id: 'wl_accepted',
        description: 'You accepted the task',
        timestamp: now.subtract(const Duration(days: 3)),
        type: WorkLogEntryType.taskAccepted,
      ),
    ];

    return [
      AgentTask(
        id: '20',
        serviceId: '#SERV892-POST-1042',
        serviceType: ServiceType.ownershipHistoryValidation,
        status: TaskStatus.inReview,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.inReview,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 3)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 15,
        plotSize: 15,
        distanceFromRoad: '200m-750m',
        serviceFee: 40000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: inReviewWorkLog,
      ),
      AgentTask(
        id: '21',
        serviceId: '#SERV893-POST-1042',
        serviceType: ServiceType.pentagraphMapVerification,
        status: TaskStatus.inReview,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.inReview,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Sector-10, Uttara, Dhaka North City Corporation, Dhaka-1230, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 4)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 20,
        plotSize: 20,
        distanceFromRoad: '100m-200m',
        serviceFee: 35000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: inReviewWorkLog,
      ),
      AgentTask(
        id: '22',
        serviceId: '#SERV894-POST-1042',
        serviceType: ServiceType.physicalEstimateBorderDemarcation,
        status: TaskStatus.inReview,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.inReview,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-A, Gulshan, Dhaka North City Corporation, Dhaka-1212, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 5)),
        propertyType: TaskPropertyType.plot,
        sellableLandAmount: 12,
        plotSize: 12,
        distanceFromRoad: '50m-100m',
        serviceFee: 45000,
        propertyPhotos: photos,
        rawDocuments: documents,
        workLog: inReviewWorkLog,
      ),
    ];
  }

  /// Generate mock done tasks
  List<AgentTask> _generateMockDoneTasks() {
    final now = DateTime.now();

    // Common photos and documents
    const photos = [
      'assets/images/Properties demo/06dbc3d9ecaf49c8d2530fa47d00ffc27b015e09.jpg',
      'assets/images/Properties demo/2f5cdf5df8bac3e6a2f6f5530709720e85f6e282.jpg',
    ];

    const documents = [
      TaskDocument(id: 'doc1', name: 'Deed document 1.pdf', size: '1.5MB'),
      TaskDocument(id: 'doc2', name: 'Deed document 2.pdf', size: '1.5MB'),
    ];

    // Visited appointment for done tasks
    final visitedAppointment = TaskAppointment(
      id: 'apt_done',
      type: 'Site Visit',
      dateTime: DateTime(2026, 1, 12, 10, 0),
      status: AppointmentStatus.visited,
    );

    // Work log for done tasks
    final doneWorkLog = [
      WorkLogEntry(
        id: 'wl_completed',
        description: 'Review completed - Task approved',
        timestamp: now.subtract(const Duration(days: 1)),
        type: WorkLogEntryType.remark,
      ),
      WorkLogEntry(
        id: 'wl_submitted',
        description: 'Submitted for review',
        timestamp: now.subtract(const Duration(days: 3)),
        type: WorkLogEntryType.submitted,
      ),
      WorkLogEntry(
        id: 'wl_visit',
        description: 'Site Visit Scheduled for 12 Jan 2026, 10:00AM',
        timestamp: now.subtract(const Duration(days: 4)),
        type: WorkLogEntryType.appointmentScheduled,
      ),
      WorkLogEntry(
        id: 'wl_doc',
        description: 'Uploaded new verified document',
        timestamp: now.subtract(const Duration(days: 5)),
        type: WorkLogEntryType.documentUpload,
        attachment: const TaskDocument(
          id: 'verified_doc',
          name: 'Verified document 1 .pdf',
          size: '1.5MB',
        ),
      ),
      WorkLogEntry(
        id: 'wl_accepted',
        description: 'You accepted the task',
        timestamp: now.subtract(const Duration(days: 7)),
        type: WorkLogEntryType.taskAccepted,
      ),
    ];

    return [
      AgentTask(
        id: '30',
        serviceId: '#SERV892-POST-1042',
        serviceType: ServiceType.ownershipHistoryValidation,
        status: TaskStatus.done,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.done,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 7)),
        completedAt: now.subtract(const Duration(days: 1)),
        propertyType: TaskPropertyType.flat,
        sellableLandAmount: 15,
        plotSize: 15,
        distanceFromRoad: '200m-750m',
        serviceFee: 40000,
        propertyPhotos: photos,
        rawDocuments: documents,
        appointment: visitedAppointment,
        workLog: doneWorkLog,
      ),
      AgentTask(
        id: '31',
        serviceId: '#SERV893-POST-1042',
        serviceType: ServiceType.pentagraphMapVerification,
        status: TaskStatus.done,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.done,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Sector-10, Uttara, Dhaka North City Corporation, Dhaka-1230, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 10)),
        completedAt: now.subtract(const Duration(days: 2)),
        propertyType: TaskPropertyType.land,
        sellableLandAmount: 20,
        plotSize: 20,
        distanceFromRoad: '100m-200m',
        serviceFee: 35000,
        propertyPhotos: photos,
        rawDocuments: documents,
        appointment: visitedAppointment,
        workLog: doneWorkLog,
      ),
      AgentTask(
        id: '32',
        serviceId: '#SERV894-POST-1042',
        serviceType: ServiceType.physicalEstimateBorderDemarcation,
        status: TaskStatus.done,
        acceptanceStatus: TaskAcceptanceStatus.accepted,
        processingStatus: TaskProcessingStatus.done,
        clientName: 'Farhan',
        clientImageUrl: 'assets/images/User_DP/Farhan.jpg',
        isClientVerified: true,
        location:
            'Block-A, Gulshan, Dhaka North City Corporation, Dhaka-1212, Dhaka, Bangladesh.',
        assignedAt: now.subtract(const Duration(days: 14)),
        completedAt: now.subtract(const Duration(days: 3)),
        propertyType: TaskPropertyType.plot,
        sellableLandAmount: 12,
        plotSize: 12,
        distanceFromRoad: '50m-100m',
        serviceFee: 45000,
        propertyPhotos: photos,
        rawDocuments: documents,
        appointment: visitedAppointment,
        workLog: doneWorkLog,
      ),
    ];
  }

  /// Navigate to task details
  /// Uses unified task details view for all task statuses
  void goToTaskDetails(AgentTask task) {
    // Use unified route for all task statuses
    Get.toNamed('/agent/my-tasks/details/new', arguments: task);
  }

  /// Show service type filter bottom sheet
  void showServiceTypeFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
    );
  }

  /// Refresh tasks
  Future<void> refresh() async {
    await loadTasks();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
