import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../widgets/properties_widgets.dart';

/// Controller for Create Offer flow (3 steps)
/// Step 1: Property info (title, type, location, pricing)
/// Step 2: Property photos
/// Step 3: Review offer & submit
class CreateOfferController extends GetxController {
  // The buy post ID this offer is responding to
  String? buyPostId;
  String? buyPostTitle;

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
    final landInKatha = LandUnitConverter.fromSqft(
      LandUnitConverter.toSqft(landAmountValue.value, landAmountUnit.value),
      LandUnit.katha,
    );
    return pricePerKathaValue.value * landInKatha;
  }

  /// Format asking price for display
  String get formattedAskingPrice {
    final price = askingPrice;
    if (price == 0) return '৳ 0';
    if (price >= 10000000) {
      return '৳ ${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '৳ ${(price / 100000).toStringAsFixed(2)} Lac';
    }
    return '৳ ${price.toStringAsFixed(0)}';
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
  void validateAndNextFromInfo() {
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

      nextStep();
    }
  }

  /// Validate step 2 (photos) and proceed
  void validateAndNextFromMedia() {
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

    nextStep();
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
    // TODO: Implement actual image picker
    final newPhoto = PhotoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: 'photo_${photos.length + 1}.jpg',
    );
    photos.add(newPhoto);
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
    }
  }

  /// Save as draft
  Future<void> saveAsDraft() async {
    isSavingDraft.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Draft Saved',
        'Your offer has been saved as draft',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save draft. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSavingDraft.value = false;
    }
  }

  /// Submit offer
  Future<void> submitOffer() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));

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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit offer. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
