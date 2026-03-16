import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'models/buy_post_details_payload.dart';
import 'models/create_buy_post_payload_model.dart';
import 'services/buy_post_service.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/properties_widgets.dart';

/// Controller for Create Buy Post flow (2 steps)
/// Step 1: Requirements (property type, size, budget, location)
/// Step 2: Review & submit
class CreateBuyPostController extends GetxController {
  CreateBuyPostController(this.service);

  static const int minBudgetLimit = 0;
  static const int maxBudgetLimit = 9999999;

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
  final RxInt minBudgetValue =
      minBudgetLimit.obs; // Reactive value for min budget
  final RxInt maxBudgetValue =
      maxBudgetLimit.obs; // Reactive value for max budget
  final Rx<BudgetRange?> budgetRange = Rx<BudgetRange?>(
    const BudgetRange(minBudget: minBudgetLimit, maxBudget: maxBudgetLimit),
  ); // For slider

  // Location
  final Rx<LocationData> location = const LocationData().obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;
  final RxnString draftPostId = RxnString();

  final BuyPostService service;

  // Validation errors
  final RxString propertyTypeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    minBudgetController.text = minBudgetLimit.toString();
    maxBudgetController.text = maxBudgetLimit.toString();
    // Add listeners to update reactive values when text changes
    titleController.addListener(_updateTitleValue);
    descriptionController.addListener(_updateDescriptionValue);
    minLandSizeController.addListener(_updateLandSizeValue);
    minPlotSizeController.addListener(_updatePlotSizeValue);
    minBudgetController.addListener(_updateMinBudgetValue);
    maxBudgetController.addListener(_updateMaxBudgetValue);
    _initializeFromArguments();
  }

  void _initializeFromArguments() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }

    final map = Map<String, dynamic>.from(args);
    final draftId = (map['draftPostId'] ?? map['postId'])?.toString();
    final resumeStep = _toInt(map['resumeStep']);
    final lastCompletedStep = _toInt(map['lastCompletedStep']);

    if (draftId != null && draftId.trim().isNotEmpty) {
      draftPostId.value = draftId;
      _loadDraftPost(
        draftId,
        preferredStep: resumeStep ?? _getResumeStep(lastCompletedStep),
      );
      return;
    }

    if (resumeStep != null) {
      goToStep(resumeStep.clamp(1, totalSteps));
    }
  }

  Future<void> _loadDraftPost(
    String postId, {
    required int preferredStep,
  }) async {
    isLoading.value = true;
    try {
      final payload = await service.getBuyPostById(postId);
      _applyDraftPayload(payload);
      goToStep(preferredStep.clamp(1, totalSteps));
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load draft post for editing',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  int _getResumeStep(int? lastCompletedStep) {
    final step = (lastCompletedStep ?? 1) + 1;
    return step.clamp(1, totalSteps);
  }

  void _applyDraftPayload(BuyPostDetailsPayload payload) {
    final raw = payload.raw;
    final address = raw['address'] is Map
        ? Map<String, dynamic>.from(raw['address'] as Map)
        : <String, dynamic>{};

    titleController.text = raw['title']?.toString() ?? '';
    descriptionController.text = raw['description']?.toString() ?? '';

    propertyType.value = _mapPropertyType(raw['propertyType']?.toString());
    propertyTypeError.value = '';

    final landSize = _toDouble(raw['landSizeMin']);
    final landUnit = _mapLandUnit(raw['landSizeUnit']);
    if (landUnit != null) {
      landSizeUnit.value = landUnit;
    }
    landSizeValue.value = landSize;
    _setMetricControllerText(
      minLandSizeController,
      _updateLandSizeValue,
      landSize,
    );

    final plotSize = _toDouble(raw['plotSizeMin']);
    final plotUnit = _mapLandUnit(raw['plotSizeUnit']);
    if (plotUnit != null) {
      plotSizeUnit.value = plotUnit;
    }
    plotSizeValue.value = plotSize;
    _setMetricControllerText(
      minPlotSizeController,
      _updatePlotSizeValue,
      plotSize,
    );

    final roadDistanceMin = _toInt(raw['roadDistanceMin']);
    final roadDistanceMax = _toInt(raw['roadDistanceMax']);
    if (roadDistanceMin != null && roadDistanceMax != null) {
      distanceRange.value = DistanceRange(
        label: DistanceRange.getLabel(roadDistanceMin, roadDistanceMax),
        minMeters: roadDistanceMin,
        maxMeters: roadDistanceMax,
      );
    }

    final budgetMin = _toInt(raw['budgetMin']);
    final budgetMax = _toInt(raw['budgetMax']);
    if (budgetMin != null && budgetMax != null && budgetMin < budgetMax) {
      minBudgetValue.value = budgetMin;
      maxBudgetValue.value = budgetMax;
      budgetRange.value = BudgetRange(
        minBudget: budgetMin,
        maxBudget: budgetMax,
      );
      _setBudgetControllerText(
        minBudgetController,
        _updateMinBudgetValue,
        budgetMin,
      );
      _setBudgetControllerText(
        maxBudgetController,
        _updateMaxBudgetValue,
        budgetMax,
      );
    }

    location.value = LocationData(
      division: raw['division']?.toString() ?? address['division']?.toString(),
      district: raw['district']?.toString() ?? address['district']?.toString(),
      upazila: raw['upazila']?.toString() ?? address['upazila']?.toString(),
      pouroshova:
          raw['unionOrCityCorp']?.toString() ??
          address['unionOrCityCorp']?.toString(),
      wardNo: raw['wardNo']?.toString() ?? address['wardNo']?.toString(),
      postalCode:
          raw['postalCode']?.toString() ?? address['postalCode']?.toString(),
      fullAddress: raw['fullAddress']?.toString(),
      isFullAddressCustomized:
          raw['fullAddress']?.toString().trim().isNotEmpty == true,
    );
  }

  PropertyType? _mapPropertyType(String? rawType) {
    if (rawType == null || rawType.trim().isEmpty) {
      return null;
    }

    final normalized = rawType.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    switch (normalized) {
      case 'plainland':
      case 'land':
        return PropertyType.plainLand;
      case 'waterland':
      case 'water':
        return PropertyType.waterLand;
      case 'commercial':
        return PropertyType.commercial;
      case 'agroland':
        return PropertyType.agroLand;
      case 'blankroof':
        return PropertyType.blankRoof;
      case 'flat':
      default:
        return PropertyType.flat;
    }
  }

  LandUnit? _mapLandUnit(dynamic rawUnit) {
    final value = rawUnit?.toString().trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final unit in LandUnit.values) {
      if (unit.label.toLowerCase() == value) {
        return unit;
      }
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _updateTitleValue() {
    titleValue.value = titleController.text;
  }

  void _updateDescriptionValue() {
    descriptionValue.value = descriptionController.text;
  }

  void _updateMinBudgetValue() {
    _syncBudgetRangeFromInputs(changedMin: true);
  }

  void _updateMaxBudgetValue() {
    _syncBudgetRangeFromInputs(changedMin: false);
  }

  int? _parseBudgetInput(String rawValue) {
    final normalized = rawValue.replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  void _setBudgetControllerText(
    TextEditingController controller,
    VoidCallback listener,
    int value,
  ) {
    final textValue = value.toString();
    if (controller.text == textValue) {
      return;
    }
    controller.removeListener(listener);
    controller.text = textValue;
    controller.selection = TextSelection.collapsed(offset: textValue.length);
    controller.addListener(listener);
  }

  void _syncBudgetRangeFromInputs({required bool changedMin}) {
    final parsedMinInput = _parseBudgetInput(minBudgetController.text);
    final parsedMaxInput = _parseBudgetInput(maxBudgetController.text);

    minBudgetValue.value = parsedMinInput ?? 0;
    maxBudgetValue.value = parsedMaxInput ?? 0;

    if (parsedMinInput != null &&
        parsedMaxInput != null &&
        parsedMinInput < parsedMaxInput) {
      budgetRange.value = BudgetRange(
        minBudget: parsedMinInput,
        maxBudget: parsedMaxInput,
      );
    }
  }

  void _updateLandSizeValue() {
    landSizeValue.value = double.tryParse(minLandSizeController.text) ?? 0;
  }

  void _updatePlotSizeValue() {
    plotSizeValue.value = double.tryParse(minPlotSizeController.text) ?? 0;
  }

  /// Update budget range from slider
  void updateBudgetRange(BudgetRange range) {
    budgetRange.value = BudgetRange(
      minBudget: range.minBudget,
      maxBudget: range.maxBudget,
    );
    minBudgetValue.value = range.minBudget;
    maxBudgetValue.value = range.maxBudget;

    _setBudgetControllerText(
      minBudgetController,
      _updateMinBudgetValue,
      range.minBudget,
    );
    _setBudgetControllerText(
      maxBudgetController,
      _updateMaxBudgetValue,
      range.maxBudget,
    );
  }

  /// Update land size from slider (updates text field)
  void updateLandSizeFromSlider(double value) {
    landSizeValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
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
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
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
    return CurrencyFormatter.format(number);
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

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 1 && step <= totalSteps) {
      currentStep.value = step;
    }
  }

  /// Validate step 1 and proceed
  Future<void> validateAndNext() async {
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

      if (!_isBudgetRangeValid()) {
        Get.snackbar(
          'Invalid Budget Range',
          'Please ensure minimum budget is less than maximum budget',
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

  /// Change land size unit
  void changeLandSizeUnit(LandUnit unit) {
    _convertMetricValue(
      unitState: landSizeUnit,
      valueState: landSizeValue,
      controller: minLandSizeController,
      listener: _updateLandSizeValue,
      newUnit: unit,
    );
  }

  /// Change plot size unit
  void changePlotSizeUnit(LandUnit unit) {
    _convertMetricValue(
      unitState: plotSizeUnit,
      valueState: plotSizeValue,
      controller: minPlotSizeController,
      listener: _updatePlotSizeValue,
      newUnit: unit,
    );
  }

  void _convertMetricValue({
    required Rx<LandUnit> unitState,
    required RxDouble valueState,
    required TextEditingController controller,
    required VoidCallback listener,
    required LandUnit newUnit,
  }) {
    final oldUnit = unitState.value;
    if (oldUnit == newUnit) {
      return;
    }

    final converted = LandUnitConverter.convert(
      valueState.value,
      oldUnit,
      newUnit,
    );

    unitState.value = newUnit;
    valueState.value = converted;
    _setMetricControllerText(controller, listener, converted);
  }

  void _setMetricControllerText(
    TextEditingController controller,
    VoidCallback listener,
    double value,
  ) {
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    if (controller.text != formattedValue) {
      controller.removeListener(listener);
      controller.text = formattedValue;
      controller.addListener(listener);
    }
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
    if (isSavingDraft.value) {
      return;
    }
    isSavingDraft.value = true;
    if (currentStep.value == 1) {
      if (propertyType.value == null) {
        propertyTypeError.value = 'Please select a property type';
        isSavingDraft.value = false;
        return;
      }
      if (!requirementsFormKey.currentState!.validate()) {
        isSavingDraft.value = false;
        return;
      }
      if (!location.value.isComplete) {
        Get.snackbar(
          'Incomplete Location',
          'Please select all required location fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSavingDraft.value = false;
        return;
      }

      if (!_isBudgetRangeValid()) {
        Get.snackbar(
          'Invalid Budget Range',
          'Please ensure minimum budget is less than maximum budget',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSavingDraft.value = false;
        return;
      }

      await ApiErrorHandler.call(
        () => _submitStep1(advanceStep: false, showSuccessSnack: true),
      );
      isSavingDraft.value = false;
      return;
    }

    if (currentStep.value == 2) {
      await ApiErrorHandler.call(
        () => _submitStep1(advanceStep: false, showSuccessSnack: true),
      );
      isSavingDraft.value = false;
      return;
    }

    await ApiErrorHandler.call(
      () async =>
          throw Exception('Draft saving is not available on this step.'),
    );
    isSavingDraft.value = false;
  }

  /// Submit buy post for review
  Future<void> submitPost() async {
    final id = draftPostId.value;
    if (id == null || id.isEmpty) {
      Get.snackbar(
        'Missing Draft',
        'Please complete step 1 before submitting your post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => service.submitBuyPost(postId: id),
      );
      if (!result.isSuccess) {
        return;
      }

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
          Get.offNamed(AppRoutes.MAIN); // Navigate to home
          //Get.offNamed(AppRoutes.MY_POSTS); // Navigate to my posts
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
    isLoading.value = true;
    try {
      final payload = _buildStep1PayloadModel();
      final id = draftPostId.value;

      if (id == null || id.isEmpty) {
        final response = await service.createDraftStep1(payload: payload);
        final createdId = response.id;
        if (createdId != null && createdId.isNotEmpty) {
          draftPostId.value = createdId;
        }
      } else {
        await service.updateBuyPost(postId: id, payload: payload);
      }

      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your buy post has been saved as draft',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      if (advanceStep) {
        nextStep();
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
      isSavingDraft.value = false;
    }
  }

  CreateBuyPostPayloadModel get step1PayloadModel => _buildStep1PayloadModel();

  CreateBuyPostPayloadModel _buildStep1PayloadModel() {
    final selectedPropertyType = propertyType.value;
    if (selectedPropertyType == null) {
      throw Exception('Property type is required.');
    }

    final currentLocation = location.value;
    final range = distanceRange.value;
    final parsedBudgetMin = _parseBudgetInput(minBudgetController.text);
    final parsedBudgetMax = _parseBudgetInput(maxBudgetController.text);

    if (parsedBudgetMin == null || parsedBudgetMax == null) {
      throw Exception('Budget range is required.');
    }
    if (parsedBudgetMin >= parsedBudgetMax) {
      throw Exception(
        'Invalid budget range. Minimum budget must be less than maximum budget.',
      );
    }

    return CreateBuyPostPayloadModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      propertyType: selectedPropertyType.label,
      landSizeMin: landSizeValue.value,
      landSizeUnit: landSizeUnit.value.label,
      budgetMin: parsedBudgetMin,
      budgetMax: parsedBudgetMax,
      plotSizeMin: plotSizeValue.value > 0 ? plotSizeValue.value : null,
      plotSizeUnit: plotSizeValue.value > 0 ? plotSizeUnit.value.label : null,
      roadDistanceMin: range?.minMeters,
      roadDistanceMax: range?.maxMeters,
      division: currentLocation.division,
      district: currentLocation.district,
      upazila: currentLocation.upazila,
      unionOrCityCorp: currentLocation.pouroshova,
      wardNo: currentLocation.wardNo,
      postalCode: currentLocation.postalCode,
    );
  }

  bool _isBudgetRangeValid() {
    final parsedBudgetMin = _parseBudgetInput(minBudgetController.text);
    final parsedBudgetMax = _parseBudgetInput(maxBudgetController.text);
    if (parsedBudgetMin == null || parsedBudgetMax == null) {
      return false;
    }
    return parsedBudgetMin < parsedBudgetMax;
  }

  /// Go back to edit from review
  void goBackToEdit() {
    currentStep.value = 1;
  }

  /// Reset controller state
  void resetForm() {
    currentStep.value = 1;
    draftPostId.value = null;
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
    budgetRange.value = const BudgetRange(
      minBudget: minBudgetLimit,
      maxBudget: maxBudgetLimit,
    );
    minBudgetController.text = minBudgetLimit.toString();
    minBudgetValue.value = minBudgetLimit;
    maxBudgetController.text = maxBudgetLimit.toString();
    maxBudgetValue.value = maxBudgetLimit;
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
