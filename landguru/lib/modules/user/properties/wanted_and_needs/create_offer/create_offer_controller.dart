import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/services.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../routes/app_routes.dart';
import '../../widgets/properties_widgets.dart';

/// Controller for Create Offer flow (3 steps)
/// Step 1: Property info (title, type, location, pricing)
/// Step 2: Property photos
/// Step 3: Review offer & submit
class CreateOfferController extends GetxController {
  final BuyPostOfferService _offerService = Get.find<BuyPostOfferService>();

  // The buy post ID this offer is responding to
  String? buyPostId;
  String? buyPostTitle;
  final RxnString draftOfferId = RxnString();

  // Current step (1-3)
  final RxInt currentStep = 1.obs;
  final int totalSteps = 3;

  // Form keys
  final infoFormKey = GlobalKey<FormState>();

  // Step 1: Property Info
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final pricePerKathaController = TextEditingController();

  // Property Type
  final Rx<PropertyType?> propertyType = Rx<PropertyType?>(null);

  // Sellable Land Amount
  final landAmountController = TextEditingController();
  final Rx<LandUnit> landAmountUnit = LandUnit.katha.obs;
  final RxDouble landAmountValue = 0.0.obs; // Reactive value for land amount

  // Plot Size (Optional)
  final plotSizeController = TextEditingController();
  final Rx<LandUnit> plotSizeUnit = LandUnit.katha.obs;
  final RxDouble plotSizeValue = 0.0.obs; // Reactive value for plot size

  // Price per katha reactive
  final RxDouble pricePerKathaValue = 0.0.obs;

  // Distance from Road
  final Rx<DistanceRange?> distanceRange = Rx<DistanceRange?>(null);

  // Location
  final Rx<LocationData> location = const LocationData().obs;

  // Validation errors
  final RxString propertyTypeError = ''.obs;

  // Step 2: Photos only (simplified from sell post)
  final RxList<PhotoItem> photos = <PhotoItem>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;
  final RxBool isUploadingMedia = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update reactive values when text changes
    landAmountController.addListener(_updateLandAmountValue);
    plotSizeController.addListener(_updatePlotSizeValue);
    pricePerKathaController.addListener(_updatePricePerKathaValue);
  }

  void _updateLandAmountValue() {
    landAmountValue.value = double.tryParse(landAmountController.text) ?? 0;
  }

  void _updatePlotSizeValue() {
    plotSizeValue.value = double.tryParse(plotSizeController.text) ?? 0;
  }

  void _updatePricePerKathaValue() {
    pricePerKathaValue.value =
        double.tryParse(pricePerKathaController.text.replaceAll(',', '')) ?? 0;
  }

  /// Initialize with buy post data
  void initWithBuyPost(String postId, String postTitle) {
    buyPostId = postId;
    buyPostTitle = postTitle;
  }

  /// Calculate asking price
  double get askingPrice {
    final landInKatha = LandUnitConverter.convert(
      landAmountValue.value,
      landAmountUnit.value,
      LandUnit.katha,
    );
    return pricePerKathaValue.value * landInKatha;
  }

  /// Format asking price for display
  String get formattedAskingPrice {
    final price = askingPrice;
    if (price == 0) return '৳ 0';
    return CurrencyFormatter.formatWithSymbol(price);
  }

  /// Format land amount for display
  String get formattedLandAmount {
    final value = landAmountValue.value;
    if (value == 0) return '';
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} ${landAmountUnit.value.label}';
  }

  /// Format plot size for display
  String get formattedPlotSize {
    final value = plotSizeValue.value;
    if (value == 0) return '';
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} ${plotSizeUnit.value.label}';
  }

  /// Navigate to next step
  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  /// Validate step 1 and proceed
  Future<void> validateAndNextFromInfo() async {
    propertyTypeError.value = '';

    if (propertyType.value == null) {
      propertyTypeError.value = 'Please select a property type';
      return;
    }

    if (infoFormKey.currentState!.validate()) {
      if (!location.value.isComplete) {
        Get.snackbar(
          'Incomplete Location',
          'Please select all required location fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      await ApiErrorHandler.call(
        () => _submitStep1(advanceStep: true, showSuccessSnack: false),
      );
    }
  }

  /// Validate step 2 (photos) and proceed
  Future<void> validateAndNextFromMedia() async {
    if (photos.isEmpty) {
      Get.snackbar(
        'Photos Required',
        'Please add at least one property photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    await ApiErrorHandler.call(
      () => _submitStep2(advanceStep: true, showSuccessSnack: false),
    );
  }

  /// Change land amount unit
  void changeLandAmountUnit(LandUnit unit) {
    landAmountUnit.value = unit;
  }

  /// Change plot size unit
  void changePlotSizeUnit(LandUnit unit) {
    plotSizeUnit.value = unit;
  }

  /// Update location
  void updateLocation(LocationData newLocation) {
    location.value = newLocation;
  }

  /// Update property type
  void updatePropertyType(PropertyType type) {
    propertyType.value = type;
    propertyTypeError.value = '';
  }

  /// Update distance range
  void updateDistanceRange(DistanceRange range) {
    distanceRange.value = range;
  }

  // Photo management
  Future<void> addPhoto() async {
    if (isUploadingMedia.value) {
      return;
    }

    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (pickResult == null || pickResult.files.isEmpty) {
      return;
    }

    final path = pickResult.files.single.path;
    if (path == null) {
      return;
    }

    isUploadingMedia.value = true;
    final uploadService = Get.find<UploadService>();
    final uploadResult = await ApiErrorHandler.call(
      () => uploadService.uploadFile(
        file: File(path),
        contentType: _guessContentType(path),
        type: 'AVATAR',
      ),
    );

    if (uploadResult.isSuccess && uploadResult.data != null) {
      final newPhoto = PhotoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: uploadResult.data!,
        isLocal: false,
      );
      photos.add(newPhoto);
    }

    isUploadingMedia.value = false;
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
    }
  }

  /// Save as draft
  Future<void> saveAsDraft() async {
    isSavingDraft.value = true;
    if ((buyPostId ?? '').isEmpty) {
      Get.snackbar(
        'Missing Buy Post',
        'Unable to save draft without a buy post reference.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isSavingDraft.value = false;
      return;
    }

    if (currentStep.value == 1) {
      await ApiErrorHandler.call(
        () => _submitStep1(advanceStep: false, showSuccessSnack: true),
      );
      isSavingDraft.value = false;
      return;
    }

    if (draftOfferId.value == null || draftOfferId.value!.isEmpty) {
      Get.snackbar(
        'Missing Draft',
        'Please complete step 1 before saving media draft.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isSavingDraft.value = false;
      return;
    }

    await ApiErrorHandler.call(
      () => _submitStep2(advanceStep: false, showSuccessSnack: true),
    );
    isSavingDraft.value = false;
  }

  /// Submit offer
  Future<void> submitOffer() async {
    final id = draftOfferId.value;
    if (id == null || id.isEmpty) {
      Get.snackbar(
        'Missing Draft',
        'Please complete previous steps before submitting your offer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _offerService.submitFinalOffer(offerId: id),
      );
      if (!result.isSuccess) {
        return;
      }

      // Show success dialog
      PostSubmittedDialog.showSellPost(
        Get.context!,
        summary: SellPostSummary(
          title: titleController.text.isNotEmpty
              ? titleController.text
              : '${propertyType.value?.label ?? 'Property'}',
          askingPrice: formattedAskingPrice,
          propertyType: propertyType.value,
        ),
        onClose: () {
          Get.back(); // Close dialog
          Get.offNamed(AppRoutes.MAIN); // Navigate to home
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _submitStep1({
    required bool advanceStep,
    required bool showSuccessSnack,
  }) async {
    if (isLoading.value) {
      return;
    }

    final targetBuyPostId = buyPostId;
    if (targetBuyPostId == null || targetBuyPostId.isEmpty) {
      throw Exception('Missing buy post ID for offer creation.');
    }

    isLoading.value = true;
    try {
      final payload = _buildStep1Payload();
      final existingDraftId = draftOfferId.value;

      if (existingDraftId == null || existingDraftId.isEmpty) {
        final response = await _offerService.createDraftOfferStep1(
          buyPostId: targetBuyPostId,
          payload: payload,
        );

        final createdId =
            response['offerId']?.toString() ??
            response['id']?.toString() ??
            response['draftOfferId']?.toString();

        if (createdId == null || createdId.isEmpty) {
          throw Exception('Could not get offer draft ID from server response.');
        }
        draftOfferId.value = createdId;
      } else {
        // API supports creating step-1 draft once and then patching step-2 media.
        // Keep existing draft ID and continue flow.
      }

      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your offer draft has been saved',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      if (advanceStep) {
        nextStep();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _submitStep2({
    required bool advanceStep,
    required bool showSuccessSnack,
  }) async {
    final id = draftOfferId.value;
    if (id == null || id.isEmpty) {
      throw Exception('Please complete step 1 before uploading media.');
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final payload = _buildStep2Payload();
      await _offerService.updateDraftOfferStep2(offerId: id, payload: payload);

      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your offer media has been saved',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      if (advanceStep) {
        nextStep();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildStep1Payload() {
    final selectedPropertyType = propertyType.value;
    if (selectedPropertyType == null) {
      throw Exception('Property type is required.');
    }

    final currentLocation = location.value;
    final range = distanceRange.value;

    final payload = <String, dynamic>{
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'propertyType': selectedPropertyType.label,
      'sellableAmount': landAmountValue.value,
      'sellableUnit': landAmountUnit.value.label,
      'isShareable': false,
      'isPropertyShareable': false,
      'askingPrice': askingPrice,
      'pricePerUnit': pricePerKathaValue.value,
      'askingPricePerUnit': pricePerKathaValue.value,
      if (range != null) 'distanceFromRoad': range.label,
      if (range != null) 'roadDistanceMin': range.minMeters,
      if (range != null) 'roadDistanceMax': range.maxMeters,
      if (range != null) 'roadWidthMin': range.minMeters,
      if (range != null) 'roadWidthMax': range.maxMeters,
      if (plotSizeValue.value > 0) 'plotSize': plotSizeValue.value,
      if (plotSizeValue.value > 0) 'plotUnit': plotSizeUnit.value.label,
      if (currentLocation.division != null)
        'division': currentLocation.division,
      if (currentLocation.district != null)
        'district': currentLocation.district,
      if (currentLocation.upazila != null) 'upazila': currentLocation.upazila,
      if (currentLocation.pouroshova != null)
        'unionOrCityCorp': currentLocation.pouroshova,
      if (currentLocation.wardNo != null) 'wardNo': currentLocation.wardNo,
      if (currentLocation.postalCode != null)
        'postalCode': currentLocation.postalCode,
      if (currentLocation.fullAddress != null)
        'fullAddress': currentLocation.fullAddress,
    };

    return payload;
  }

  Map<String, dynamic> _buildStep2Payload() {
    return {'photos': photos.map((photo) => photo.path).toList()};
  }

  String _guessContentType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerPath.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  /// Reset controller state
  void resetForm() {
    currentStep.value = 1;
    titleController.clear();
    descriptionController.clear();
    pricePerKathaController.clear();
    propertyType.value = null;
    landAmountController.clear();
    landAmountUnit.value = LandUnit.katha;
    landAmountValue.value = 0;
    plotSizeController.clear();
    plotSizeUnit.value = LandUnit.katha;
    plotSizeValue.value = 0;
    pricePerKathaValue.value = 0;
    distanceRange.value = null;
    location.value = const LocationData();
    propertyTypeError.value = '';
    photos.clear();
    buyPostId = null;
    buyPostTitle = null;
    draftOfferId.value = null;
  }

  @override
  void onClose() {
    landAmountController.removeListener(_updateLandAmountValue);
    plotSizeController.removeListener(_updatePlotSizeValue);
    pricePerKathaController.removeListener(_updatePricePerKathaValue);
    titleController.dispose();
    descriptionController.dispose();
    pricePerKathaController.dispose();
    landAmountController.dispose();
    plotSizeController.dispose();
    super.onClose();
  }
}
