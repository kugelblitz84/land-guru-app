import 'package:get/get.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../widgets/metrics_conversion_row.dart';
import '../models/my_post_status.dart';
import 'models/sell_post_models.dart';
import 'widgets/quoted_popups.dart';

/// Controller for Sell Post Details screen
/// Handles all 4 states: Pending, Quoted, Active, Draft
class SellPostDetailsController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final Rxn<SellPostDetails> postDetails = Rxn<SellPostDetails>();

  // Post info from arguments
  final RxString postId = ''.obs;
  final Rx<MyPostStatus> postStatus = MyPostStatus.pending.obs;

  // Feature expansion state (for Active status)
  final RxMap<int, bool> featureExpansionState = <int, bool>{}.obs;

  // Selected land unit for metrics conversion
  final Rx<LandUnit> selectedLandUnit = LandUnit.katha.obs;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    loadPostDetails();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      postId.value = args['postId'] ?? '';

      // Parse status
      final statusStr = args['status'] as String?;
      if (statusStr != null) {
        postStatus.value = _parseStatus(statusStr);
      }
    }
  }

  MyPostStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MyPostStatus.pending;
      case 'quoted':
        return MyPostStatus.quoted;
      case 'active':
        return MyPostStatus.active;
      case 'draft':
        return MyPostStatus.draft;
      default:
        return MyPostStatus.pending;
    }
  }

  /// Load post details based on status
  Future<void> loadPostDetails() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data based on status
      postDetails.value = _getMockPostDetails();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load post details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  SellPostDetails _getMockPostDetails() {
    // Common property photos
    final photos = [
      'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
      'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
      'assets/images/Properties Listing - For Sale Images/Gazipur Water Zone.jpg',
    ];

    // Common legal documents
    final deedDocs = [
      const LegalDocument(
        name: 'Deed document 1.pdf',
        size: '1.5MB',
        iconType: 'pdf',
      ),
      const LegalDocument(
        name: 'Deed document 2.docx',
        size: '2.2MB',
        iconType: 'docx',
      ),
    ];

    final khatianDocs = [
      const LegalDocument(
        name: 'CS Khatian.pdf',
        size: '1.5MB',
        iconType: 'pdf',
      ),
      const LegalDocument(
        name: 'SA Khatian.docx',
        size: '2.2MB',
        iconType: 'docx',
      ),
      const LegalDocument(
        name: 'RS Khatian.pdf',
        size: '3.5MB',
        iconType: 'pdf',
      ),
    ];

    switch (postStatus.value) {
      case MyPostStatus.pending:
        return SellPostDetails(
          id: '1',
          postId: '#POST-1042',
          title: '5 Katha Plot in Purbachal',
          price: '2,00,00,000',
          status: MyPostStatus.pending,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          propertyPhotos: photos,
          description:
              'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
          propertyType: 'Flat',
          sellableLandAmount: '15 Katha',
          plotSize: '15 Katha',
          distanceFromRoad: '200m-750m',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          timestamp: '2h ago',
          timestampPrefix: 'Submitted:',
          deedDocuments: deedDocs,
          khatianDocuments: khatianDocs,
        );

      case MyPostStatus.quoted:
        return SellPostDetails(
          id: '2',
          postId: '#POST-1042',
          title: 'Villa in Kurigram',
          price: '4,00,00,000',
          status: MyPostStatus.quoted,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          propertyPhotos: photos,
          description:
              'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
          propertyType: 'Flat',
          sellableLandAmount: '15 Katha',
          plotSize: '15 Katha',
          distanceFromRoad: '200m-750m',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          timestamp: '2h ago',
          timestampPrefix: 'Submitted:',
          billBreakdown: const BillBreakdown(
            mandatoryServices: [
              ServiceFeeItem(name: 'Ownership History Validation', fee: 3000),
              ServiceFeeItem(name: 'Pentagraph Map', fee: 0),
              ServiceFeeItem(
                name: 'Physical estimate & Border Demarcation',
                fee: 0,
              ),
              ServiceFeeItem(name: 'Document Organization', fee: 0),
            ],
            optionalServices: [
              ServiceFeeItem(
                name: 'Property Registration/ Deed Writing Service',
                fee: 3000,
              ),
              ServiceFeeItem(
                name: 'Namjari/ DCR/ Poura City Corp Record Update',
                fee: 0,
              ),
              ServiceFeeItem(name: 'Inheritance Dispute Analysis', fee: 0),
              ServiceFeeItem(name: 'Government Acquisition Risk', fee: 0),
              ServiceFeeItem(name: 'Court case verification', fee: 0),
            ],
            totalPayable: 6000,
            lastRequoteAmount: 0,
            mandatoryServiceFees: 0,
            optionalServiceFees: 0,
            quotationRevisions: 0,
          ),
          deedDocuments: deedDocs,
          khatianDocuments: khatianDocs,
        );

      case MyPostStatus.active:
        return SellPostDetails(
          id: '3',
          postId: '#POST-1042',
          title: 'Modern Duplex Villa',
          price: '40,00,000',
          status: MyPostStatus.active,
          isVerified: true,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          propertyPhotos: photos,
          description:
              'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
          propertyType: 'Flat',
          sellableLandAmount: '15 Katha',
          plotSize: '15 Katha',
          distanceFromRoad: '200m-750m',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          timestamp: '2h ago',
          timestampPrefix: 'Posted:',
          deedDocuments: deedDocs,
          khatianDocuments: khatianDocs,
          dueDiligenceChecklist: const [
            DueDiligenceItem(title: 'Fraud Detection Passed', isPassed: true),
            DueDiligenceItem(
              title: 'Inheritance dispute analysis checked',
              isPassed: true,
            ),
            DueDiligenceItem(
              title: 'Multiple ownership checked',
              isPassed: true,
            ),
            DueDiligenceItem(
              title: 'Government acquisition risk checked',
              isPassed: true,
            ),
            DueDiligenceItem(
              title: 'Court case verification passed',
              isPassed: true,
            ),
          ],
          ownershipHistory: const [
            OwnershipHistoryItem(
              name: 'Farhan',
              period: '2022 - Present',
              isCurrent: true,
            ),
            OwnershipHistoryItem(name: 'Mithila Akhter', period: '2010 - 2022'),
            OwnershipHistoryItem(
              name: 'Trusted Developer',
              period: '2007 - 2010',
            ),
          ],
          servicesTaken: const [
            ServiceVerificationItem(
              serviceName: 'Ownership History Validation',
              assignedAgent: 'Rahman',
              agentRole: 'Lawyer',
              isVerified: true,
            ),
            ServiceVerificationItem(
              serviceName: 'Pentagraph Map Validation',
              assignedAgent: 'Abrar',
              agentRole: 'Field Assistant',
              isVerified: true,
            ),
            ServiceVerificationItem(
              serviceName: 'Deed Writing Service',
              assignedAgent: 'Sahil',
              agentRole: 'Lawyer',
              isVerified: true,
            ),
            ServiceVerificationItem(
              serviceName: 'Document Organization',
              assignedAgent: 'Jahangir',
              agentRole: 'Lawyer',
              isVerified: true,
            ),
            ServiceVerificationItem(
              serviceName: 'Namjari/DCR Record',
              assignedAgent: 'Forhad',
              agentRole: 'Lawyer',
              isVerified: true,
            ),
          ],
        );

      case MyPostStatus.draft:
        return SellPostDetails(
          id: '4',
          postId: '#POST-1043',
          title: 'Gazipur Water Zone',
          price: '95,12,000',
          status: MyPostStatus.draft,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/Gazipur Water Zone.jpg',
          propertyPhotos: photos.sublist(0, 3),
          description:
              'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
          propertyType: 'Flat',
          sellableLandAmount: '15 Katha',
          plotSize: '15 Katha',
          distanceFromRoad: '200m-750m',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          timestamp: '2h ago',
          timestampPrefix: 'Edited:',
          deedDocuments: deedDocs,
          khatianDocuments: khatianDocs,
        );
    }
  }

  // === UI Actions ===

  /// Toggle description expansion
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  /// Toggle feature expansion (for Active status)
  void toggleFeatureExpansion(int index) {
    final current = featureExpansionState[index] ?? false;
    featureExpansionState[index] = !current;
  }

  bool isFeatureExpanded(int index) {
    return featureExpansionState[index] ?? false;
  }

  /// Get land value from string
  double _getLandValueInKatha(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[Kk]atha'), '')
        .replaceAll(RegExp(r'[Dd]ecimal'), '')
        .replaceAll(RegExp(r'[Aa]cre'), '')
        .replaceAll(RegExp(r'[Bb]igha'), '')
        .replaceAll(RegExp(r'[Ss]qft'), '')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  /// Get converted land amount based on selected unit
  String getConvertedLandAmount(String value) {
    final kathaValue = _getLandValueInKatha(value);
    final sqft = LandUnitConverter.toSqft(kathaValue, LandUnit.katha);
    final converted = LandUnitConverter.fromSqft(sqft, selectedLandUnit.value);

    String formattedNumber;
    if (converted >= 1) {
      formattedNumber = converted.toStringAsFixed(
        converted.truncateToDouble() == converted ? 0 : 2,
      );
    } else {
      formattedNumber = converted.toStringAsFixed(4);
    }
    return '$formattedNumber ${selectedLandUnit.value.label}';
  }

  /// Get all conversions for a land value
  Map<LandUnit, double> getAllConversions(String value) {
    final kathaValue = _getLandValueInKatha(value);
    final sqft = LandUnitConverter.toSqft(kathaValue, LandUnit.katha);
    return LandUnitConverter.getAllConversions(sqft, LandUnit.sqft);
  }

  // === Status-specific Actions ===

  /// Edit post (for Draft status)
  void editPost() {
    // TODO: Navigate to edit post flow
    Get.snackbar(
      'Edit',
      'Navigate to edit post',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Continue editing (for Draft status)
  void continueEditing() {
    editPost();
  }

  /// Delete post (for Draft status)
  Future<void> deletePost() async {
    // TODO: Show confirmation dialog and delete
    Get.snackbar(
      'Delete',
      'Post deletion requested',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Request requote (for Quoted status)
  void requestRequote() {
    final post = postDetails.value;
    if (post == null || post.billBreakdown == null) return;

    RequoteDialog.show(
      Get.context!,
      billBreakdown: post.billBreakdown!,
      onSubmit: (mandatoryFee, optionalFee) async {
        // Close the requote dialog
        Get.back();

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Show success dialog
        final totalRequoted = mandatoryFee + optionalFee;
        RequoteSubmittedDialog.show(
          Get.context!,
          propertyTitle: post.title,
          requotedAmount: totalRequoted,
          requotedTimes: post.billBreakdown!.quotationRevisions,
          onClose: () {
            Get.back();
            // Refresh post details to reflect changes
            loadPostDetails();
          },
        );
      },
    );
  }

  /// Pay and activate post (for Quoted status)
  Future<void> payAndActivate() async {
    final post = postDetails.value;
    if (post == null || post.billBreakdown == null) return;

    PayAndActivateDialog.show(
      Get.context!,
      totalPayable: post.billBreakdown!.totalPayable,
      quotationRevisions: post.billBreakdown!.quotationRevisions,
      onPay: (paymentMethod) async {
        // Close the payment dialog
        Get.back();

        // Simulate payment processing
        await Future.delayed(const Duration(milliseconds: 800));

        // Show payment confirmed dialog
        PaymentConfirmedDialog.show(
          Get.context!,
          amount: post.billBreakdown!.totalPayable,
          propertyTitle: post.title,
          propertyPrice: post.price,
          propertyType: post.propertyType,
          imageUrl: post.imageUrl,
          onClose: () {
            Get.back();
            // Navigate back to my posts or refresh
            loadPostDetails();
          },
        );
      },
    );
  }

  /// Navigate back (uses nested navigation if available)
  void goBack() {
    NestedNavigationService.back();
  }
}
