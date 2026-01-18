import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/properties_widgets.dart';

/// Controller for Create Buy Post flow (2 steps)
/// Step 1: Requirements (property type, size, budget, location)
/// Step 2: Review & submit
class CreateBuyPostController extends GetxController {
  // Current step (1-2)
  final RxInt currentStep = 1.obs;
  final int totalSteps = 2;

  // Form keys
  final requirementsFormKey = GlobalKey<FormState>();

  // Step 1: Basic Info
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Reactive values for text fields (for Obx reactivity)
  final RxString titleValue = ''.obs;
  final RxString descriptionValue = ''.obs;

  // Property Type
  final Rx<PropertyType?> propertyType = Rx<PropertyType?>(null);

  // Land Size
  final minLandSizeController = TextEditingController();
  final Rx<LandUnit> landSizeUnit = LandUnit.katha.obs;
  final RxDouble landSizeValue = 0.0.obs; // Reactive value for land size
  final Rx<LandSizeRange?> landSizeRange = Rx<LandSizeRange?>(
    null,
  ); // For slider

  // Plot Size (Optional)
  final minPlotSizeController = TextEditingController();
  final Rx<LandUnit> plotSizeUnit = LandUnit.katha.obs;
  final RxDouble plotSizeValue = 0.0.obs; // Reactive value for plot size
  final Rx<LandSizeRange?> plotSizeRange = Rx<LandSizeRange?>(
    null,
  ); // For slider

  // Distance from Road
  final Rx<DistanceRange?> distanceRange = Rx<DistanceRange?>(null);

  // Budget Range
  final minBudgetController = TextEditingController();
  final maxBudgetController = TextEditingController();
  final RxInt minBudgetValue = 0.obs; // Reactive value for min budget
  final RxInt maxBudgetValue = 0.obs; // Reactive value for max budget
  final Rx<BudgetRange?> budgetRange = Rx<BudgetRange?>(null); // For slider

  // Location
  final Rx<LocationData> location = const LocationData().obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;

  // Validation errors
  final RxString propertyTypeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update reactive values when text changes
    titleController.addListener(_updateTitleValue);
    descriptionController.addListener(_updateDescriptionValue);
    minLandSizeController.addListener(_updateLandSizeValue);
    minPlotSizeController.addListener(_updatePlotSizeValue);
    minBudgetController.addListener(_updateMinBudgetValue);
    maxBudgetController.addListener(_updateMaxBudgetValue);
  }

  void _updateTitleValue() {
    titleValue.value = titleController.text;
  }

  void _updateDescriptionValue() {
    descriptionValue.value = descriptionController.text;
  }

  void _updateMinBudgetValue() {
    minBudgetValue.value =
        int.tryParse(minBudgetController.text.replaceAll(',', '')) ?? 0;
  }

  void _updateMaxBudgetValue() {
    maxBudgetValue.value =
        int.tryParse(maxBudgetController.text.replaceAll(',', '')) ?? 0;
  }

  void _updateLandSizeValue() {
    landSizeValue.value = double.tryParse(minLandSizeController.text) ?? 0;
  }

  void _updatePlotSizeValue() {
    plotSizeValue.value = double.tryParse(minPlotSizeController.text) ?? 0;
  }

  /// Update budget range from slider
  void updateBudgetRange(BudgetRange range) {
    budgetRange.value = range;
    minBudgetValue.value = range.minBudget;
    maxBudgetValue.value = range.maxBudget;
  }

  /// Update land size from slider (updates text field)
  void updateLandSizeFromSlider(double value) {
    landSizeValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (minLandSizeController.text != formattedValue) {
      minLandSizeController.removeListener(_updateLandSizeValue);
      minLandSizeController.text = formattedValue;
      minLandSizeController.addListener(_updateLandSizeValue);
    }
  }

  /// Update plot size from slider (updates text field)
  void updatePlotSizeFromSlider(double value) {
    plotSizeValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (minPlotSizeController.text != formattedValue) {
      minPlotSizeController.removeListener(_updatePlotSizeValue);
      minPlotSizeController.text = formattedValue;
      minPlotSizeController.addListener(_updatePlotSizeValue);
    }
  }

  /// Update land size range from slider (kept for backwards compatibility)
  void updateLandSizeRange(LandSizeRange range) {
    landSizeRange.value = range;
  }

  /// Update plot size range from slider (kept for backwards compatibility)
  void updatePlotSizeRange(LandSizeRange range) {
    plotSizeRange.value = range;
  }

  /// Get min budget as int
  int get minBudget {
    return int.tryParse(minBudgetController.text.replaceAll(',', '')) ?? 0;
  }

  /// Get max budget as int
  int get maxBudget {
    return int.tryParse(maxBudgetController.text.replaceAll(',', '')) ?? 0;
  }

  /// Format budget for display (uses reactive values)
  String get formattedBudgetRange {
    final min = minBudgetValue.value;
    final max = maxBudgetValue.value;
    if (min == 0 && max == 0) return '';
    return '৳ ${_formatNumber(min)} - ৳ ${_formatNumber(max)}';
  }

  String _formatNumber(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} Lac';
    }
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format land size for display
  String get formattedLandSize {
    final value = landSizeValue.value;
    if (value == 0) return '';
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} ${landSizeUnit.value.label}';
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
  void validateAndNext() {
    // Clear previous errors
    propertyTypeError.value = '';

    // Validate property type
    if (propertyType.value == null) {
      propertyTypeError.value = 'Please select a property type';
      return;
    }

    // Validate form fields
    if (requirementsFormKey.currentState!.validate()) {
      // Validate location
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

  /// Change land size unit
  void changeLandSizeUnit(LandUnit unit) {
    landSizeUnit.value = unit;
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

  /// Save as draft
  Future<void> saveAsDraft() async {
    isSavingDraft.value = true;
    try {
      // TODO: Implement save draft API call
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Draft Saved',
        'Your buy post has been saved as draft',
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

  /// Submit buy post for review
  Future<void> submitPost() async {
    isLoading.value = true;
    try {
      // TODO: Implement submit post API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success dialog
      PostSubmittedDialog.showBuyPost(
        Get.context!,
        summary: BuyPostSummary(
          title: titleController.text.isNotEmpty
              ? titleController.text
              : '${propertyType.value?.label ?? ''} Needed',
          propertyType: propertyType.value,
          location: location.value.formattedAddress,
          landSize: formattedLandSize,
          plotSize: formattedPlotSize.isNotEmpty ? formattedPlotSize : null,
          distanceFromRoad: distanceRange.value?.label,
          budgetRange: formattedBudgetRange,
          description: descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
        ),
        onClose: () {
          Get.back(); // Close dialog
          Get.offNamed(AppRoutes.HOME); // Navigate to home
          //Get.offNamed(AppRoutes.MY_POSTS); // Navigate to my posts
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit post. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Go back to edit from review
  void goBackToEdit() {
    currentStep.value = 1;
  }

  /// Reset controller state
  void resetForm() {
    currentStep.value = 1;
    titleController.clear();
    titleValue.value = '';
    descriptionController.clear();
    descriptionValue.value = '';
    propertyType.value = null;
    minLandSizeController.clear();
    landSizeUnit.value = LandUnit.katha;
    landSizeValue.value = 0;
    landSizeRange.value = null;
    minPlotSizeController.clear();
    plotSizeUnit.value = LandUnit.katha;
    plotSizeValue.value = 0;
    plotSizeRange.value = null;
    distanceRange.value = null;
    budgetRange.value = null;
    minBudgetController.clear();
    minBudgetValue.value = 0;
    maxBudgetController.clear();
    maxBudgetValue.value = 0;
    location.value = const LocationData();
    propertyTypeError.value = '';
  }

  @override
  void onClose() {
    // Remove all listeners
    titleController.removeListener(_updateTitleValue);
    descriptionController.removeListener(_updateDescriptionValue);
    minLandSizeController.removeListener(_updateLandSizeValue);
    minPlotSizeController.removeListener(_updatePlotSizeValue);
    minBudgetController.removeListener(_updateMinBudgetValue);
    maxBudgetController.removeListener(_updateMaxBudgetValue);
    // Dispose controllers
    titleController.dispose();
    descriptionController.dispose();
    minLandSizeController.dispose();
    minPlotSizeController.dispose();
    minBudgetController.dispose();
    maxBudgetController.dispose();
    super.onClose();
  }
}
