import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../core/services/services.dart';
import '../../../../../routes/app_routes.dart';
import '../../widgets/metrics_conversion_row.dart';
import '../models/my_post_status.dart';
import 'models/sell_post_models.dart';
import 'widgets/quoted_popups.dart';

/// Controller for Sell Post Details screen
/// Handles all 4 states: Pending, Quoted, Active, Draft
class SellPostDetailsController extends GetxController {
  final SellPostDetailsService _sellPostDetailsService =
      Get.find<SellPostDetailsService>();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final Rxn<SellPostDetails> postDetails = Rxn<SellPostDetails>();
  final RxnInt draftLastCompletedStep = RxnInt();

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
    if (postId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _sellPostDetailsService.getSellPostById(postId.value),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final payload = result.data!;
      final resolvedStatus = _parseStatus(payload.statusRaw);
      postStatus.value = resolvedStatus;
      draftLastCompletedStep.value = payload.lastCompletedStep;

      final billBreakdown = payload.billBreakdown;
      final mandatoryFee = _asDouble(
        billBreakdown?['mandatoryServiceFee'] ?? billBreakdown?['mandatoryFee'],
      );
      final optionalFee = _asDouble(
        billBreakdown?['optionalServiceFee'] ?? billBreakdown?['optionalFee'],
      );
      final totalPayable = _asDouble(
        billBreakdown?['totalPayable'] ?? payload.raw['askingPrice'],
      );
      final quotationRevisions = _asInt(
        billBreakdown?['quotationRevisions'] ??
            billBreakdown?['requoteCount'] ??
            payload.raw['requoteCount'],
      );

      final normalizedServices = payload.selectedServices
          .map((service) => service.replaceAll('_', ' '))
          .map(
            (service) => service
                .split(' ')
                .where((part) => part.isNotEmpty)
                .map(
                  (part) =>
                      '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
                )
                .join(' '),
          )
          .toList();

      postDetails.value = SellPostDetails(
        id: payload.id,
        postId: payload.postId,
        title: payload.title,
        price: payload.priceFormatted,
        status: resolvedStatus,
        isVerified: payload.isVerified,
        imageUrl: payload.photos.isNotEmpty ? payload.photos.first : null,
        propertyPhotos: payload.photos,
        description: payload.description,
        propertyType: _toDisplayPropertyType(payload.propertyTypeRaw),
        sellableLandAmount: payload.sellableLandAmount,
        plotSize: payload.plotSize,
        shareUnit: payload.shareUnit,
        distanceFromRoad: payload.distanceFromRoad,
        location: payload.location,
        timestamp: payload.postedTime,
        timestampPrefix: _mapTimestampPrefix(resolvedStatus),
        billBreakdown: resolvedStatus == MyPostStatus.quoted
            ? BillBreakdown(
                mandatoryServices: [
                  ServiceFeeItem(name: 'Mandatory Services', fee: mandatoryFee),
                ],
                optionalServices: [
                  ServiceFeeItem(name: 'Optional Services', fee: optionalFee),
                ],
                totalPayable: totalPayable,
                mandatoryServiceFees: mandatoryFee,
                optionalServiceFees: optionalFee,
                quotationRevisions: quotationRevisions,
              )
            : null,
        deedDocuments: payload.deedFiles
            .map((file) => LegalDocument(name: _fileName(file), size: '-'))
            .toList(),
        khatianDocuments: payload.khatianFiles
            .map((file) => LegalDocument(name: _fileName(file), size: '-'))
            .toList(),
        servicesTaken: resolvedStatus == MyPostStatus.active
            ? normalizedServices
                  .map(
                    (service) => ServiceVerificationItem(
                      serviceName: service,
                      assignedAgent: 'Assigned Agent',
                      agentRole: '',
                      isVerified: true,
                    ),
                  )
                  .toList()
            : null,
      );
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

  String _toDisplayPropertyType(String rawType) {
    final normalized = rawType.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    switch (normalized) {
      case 'plainland':
      case 'land':
        return 'Plain Land';
      case 'waterland':
      case 'water':
        return 'Water Land';
      case 'flat':
      default:
        return 'Flat';
    }
  }

  String _mapTimestampPrefix(MyPostStatus status) {
    switch (status) {
      case MyPostStatus.pending:
        return 'Submitted:';
      case MyPostStatus.active:
        return 'Posted:';
      case MyPostStatus.draft:
        return 'Edited:';
      case MyPostStatus.quoted:
      default:
        return 'Submitted:';
    }
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final value = parts.isNotEmpty ? parts.last : path;
    return value.trim().isEmpty ? 'Document' : value;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
    final converted = LandUnitConverter.convert(
      kathaValue,
      LandUnit.katha,
      selectedLandUnit.value,
    );

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
    return LandUnitConverter.getAllConversions(kathaValue, LandUnit.katha);
  }

  // === Status-specific Actions ===

  /// Edit post (for Draft status)
  void editPost() {
    if (postStatus.value != MyPostStatus.draft || postId.value.isEmpty) {
      return;
    }

    final lastCompletedStep = draftLastCompletedStep.value ?? 1;
    final resumeStep = (lastCompletedStep + 1).clamp(1, 4);

    Get.toNamed(
      AppRoutes.CREATE_SELL_POST_INFO,
      arguments: {
        'draftPostId': postId.value,
        'lastCompletedStep': lastCompletedStep,
        'resumeStep': resumeStep,
      },
    );
  }

  /// Continue editing (for Draft status)
  void continueEditing() {
    editPost();
  }

  /// Delete post (for Draft status)
  Future<void> deletePost() async {
    if (postId.value.isEmpty) return;

    final context = Get.context;
    if (context == null) return;

    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Post'),
            content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _sellPostDetailsService.deleteSellPost(postId.value),
        errorTitle: 'Delete Failed',
      );

      if (!result.isSuccess) {
        return;
      }

      Get.snackbar(
        'Deleted',
        'Post deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      NestedNavigationService.back(result: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update post using API (PATCH /sell-posts/{postId})
  Future<bool> updatePost({required Map<String, dynamic> payload}) async {
    if (postId.value.isEmpty) return false;

    final result = await ApiErrorHandler.call(
      () => _sellPostDetailsService.updateSellPost(
        postId: postId.value,
        payload: payload,
      ),
      errorTitle: 'Update Failed',
    );

    if (!result.isSuccess) {
      return false;
    }

    await loadPostDetails();
    return true;
  }

  /// Request requote (for Quoted status)
  void requestRequote() {
    final post = postDetails.value;
    if (post == null || post.billBreakdown == null) return;

    RequoteDialog.show(
      Get.context!,
      billBreakdown: post.billBreakdown!,
      onSubmit: (mandatoryFee, optionalFee) async {
        final result = await ApiErrorHandler.call(
          () => _sellPostDetailsService.requoteSellPost(
            postId: post.id,
            proposedMandatoryFee: mandatoryFee,
            proposedOptionalFee: optionalFee,
          ),
          errorTitle: 'Requote Failed',
        );

        if (!result.isSuccess) {
          return;
        }

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        final totalRequoted = mandatoryFee + optionalFee;
        RequoteSubmittedDialog.show(
          Get.context!,
          propertyTitle: post.title,
          requotedAmount: totalRequoted,
          requotedTimes: post.billBreakdown!.quotationRevisions + 1,
          onClose: () {
            Get.back();
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
