import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/properties_widgets.dart';

/// Controller for Create Sell Post flow (4 steps)
/// Step 1: Property info (title, type, location, price)
/// Step 2: Media (photos, video, documents)
/// Step 3: Services selection
/// Step 4: Review & submit
class CreateSellPostController extends GetxController {
  // Current step (1-4)
  final RxInt currentStep = 1.obs;
  final int totalSteps = 4;

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
  final Rx<LandSizeRange?> landAmountRange = Rx<LandSizeRange?>(null);

  // Plot Size (Optional)
  final plotSizeController = TextEditingController();
  final Rx<LandUnit> plotSizeUnit = LandUnit.katha.obs;
  final RxDouble plotSizeValue = 0.0.obs; // Reactive value for plot size
  final Rx<LandSizeRange?> plotSizeRange = Rx<LandSizeRange?>(null);

  // Price per katha reactive
  final RxDouble pricePerKathaValue = 0.0.obs;

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

  // Distance from Road
  final Rx<DistanceRange?> distanceRange = Rx<DistanceRange?>(null);

  // Location
  final Rx<LocationData> location = const LocationData().obs;

  // Validation errors
  final RxString propertyTypeError = ''.obs;

  // Step 2: Media
  final RxList<PhotoItem> photos = <PhotoItem>[].obs;
  final Rx<VideoItem?> video = Rx<VideoItem?>(null);
  final RxList<DocumentItem> deedDocuments = <DocumentItem>[].obs;
  final RxList<DocumentItem> khatianDocuments = <DocumentItem>[].obs;
  final RxList<DocumentItem> otherDocuments = <DocumentItem>[].obs;

  // Step 3: Services
  final RxList<String> selectedServices = <String>[].obs;

  // Mandatory services (always selected)
  final List<VerificationService> mandatoryServices = const [
    VerificationService(
      id: 'ownership_validation',
      title: 'Ownership History Validation',
      isMandatory: true,
    ),
    VerificationService(
      id: 'pentagraph_map',
      title: 'Pentagraph Map',
      isMandatory: true,
    ),
    VerificationService(
      id: 'physical_estimate',
      title: 'Physical estimate & Border Demarcation',
      isMandatory: true,
    ),
    VerificationService(
      id: 'document_organization',
      title: 'Document Organization',
      isMandatory: true,
    ),
  ];

  // Optional services
  final List<VerificationService> optionalServices = const [
    VerificationService(
      id: 'property_registration',
      title: 'Property Registration/ Deed Writing Service',
    ),
    VerificationService(
      id: 'namjari_dcr',
      title: 'Namjari/ DCR/ Pouro City Corp Record Update',
    ),
    VerificationService(
      id: 'inheritance_dispute',
      title: 'Inheritance Dispute Analysis',
    ),
    VerificationService(
      id: 'government_acquisition',
      title: 'Government Acquisition Risk',
    ),
    VerificationService(id: 'court_case', title: 'Court case verification'),
  ];

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;

  /// Calculate asking price (price per katha × land amount in katha)
  double get askingPrice {
    // Convert land amount to katha if different unit
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
    // Clear previous errors
    propertyTypeError.value = '';

    // Validate property type
    if (propertyType.value == null) {
      propertyTypeError.value = 'Please select a property type';
      return;
    }

    // Validate form fields
    if (infoFormKey.currentState!.validate()) {
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

  /// Validate step 2 (media) and proceed
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

    if (deedDocuments.isEmpty) {
      Get.snackbar(
        'Deed Documents Required',
        'Please upload at least one deed document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (khatianDocuments.isEmpty) {
      Get.snackbar(
        'Khatian Documents Required',
        'Please upload at least one khatian document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    nextStep();
  }

  /// Validate step 3 (services) and proceed
  void validateAndNextFromServices() {
    // Mandatory services are always selected, so just proceed
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

  /// Update land amount from slider (updates text field)
  void updateLandAmountFromSlider(double value) {
    landAmountValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (landAmountController.text != formattedValue) {
      landAmountController.removeListener(_updateLandAmountValue);
      landAmountController.text = formattedValue;
      landAmountController.addListener(_updateLandAmountValue);
    }
  }

  /// Update plot size from slider (updates text field)
  void updatePlotSizeFromSlider(double value) {
    plotSizeValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (plotSizeController.text != formattedValue) {
      plotSizeController.removeListener(_updatePlotSizeValue);
      plotSizeController.text = formattedValue;
      plotSizeController.addListener(_updatePlotSizeValue);
    }
  }

  /// Update land amount range (kept for backwards compatibility)
  void updateLandAmountRange(LandSizeRange range) {
    landAmountRange.value = range;
  }

  /// Update plot size range (kept for backwards compatibility)
  void updatePlotSizeRange(LandSizeRange range) {
    plotSizeRange.value = range;
  }

  // Photo management
  Future<void> addPhoto() async {
    // TODO: Implement actual image picker
    // Simulating photo addition
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

  // Video management
  Future<void> addVideo() async {
    // TODO: Implement actual video picker
    video.value = VideoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: 'video.mp4',
    );
  }

  void removeVideo() {
    video.value = null;
  }

  // Document management
  Future<void> addDeedDocument() async {
    // TODO: Implement actual document picker
    final newDoc = DocumentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Deed document ${deedDocuments.length + 1}.pdf',
      path: 'deed_${deedDocuments.length + 1}.pdf',
      size: '1.5MB',
    );
    deedDocuments.add(newDoc);
  }

  void removeDeedDocument(int index) {
    if (index >= 0 && index < deedDocuments.length) {
      deedDocuments.removeAt(index);
    }
  }

  Future<void> addKhatianDocument() async {
    // TODO: Implement actual document picker
    final newDoc = DocumentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Khatian document ${khatianDocuments.length + 1}.pdf',
      path: 'khatian_${khatianDocuments.length + 1}.pdf',
      size: '2.2MB',
    );
    khatianDocuments.add(newDoc);
  }

  void removeKhatianDocument(int index) {
    if (index >= 0 && index < khatianDocuments.length) {
      khatianDocuments.removeAt(index);
    }
  }

  Future<void> addOtherDocument() async {
    // TODO: Implement actual document picker
    final newDoc = DocumentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Other document ${otherDocuments.length + 1}.pdf',
      path: 'other_${otherDocuments.length + 1}.pdf',
      size: '1.0MB',
    );
    otherDocuments.add(newDoc);
  }

  void removeOtherDocument(int index) {
    if (index >= 0 && index < otherDocuments.length) {
      otherDocuments.removeAt(index);
    }
  }

  // Service management
  void toggleService(String serviceId) {
    if (selectedServices.contains(serviceId)) {
      selectedServices.remove(serviceId);
    } else {
      selectedServices.add(serviceId);
    }
  }

  bool isServiceSelected(String serviceId) {
    // Mandatory services are always selected
    if (mandatoryServices.any((s) => s.id == serviceId)) {
      return true;
    }
    return selectedServices.contains(serviceId);
  }

  /// Save as draft
  Future<void> saveAsDraft() async {
    isSavingDraft.value = true;
    try {
      // TODO: Implement save draft API call
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Draft Saved',
        'Your sell post has been saved as draft',
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

  /// Submit sell post for review
  Future<void> submitPost() async {
    isLoading.value = true;
    try {
      // TODO: Implement submit post API call
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

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 1 && step <= totalSteps) {
      currentStep.value = step;
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
    landAmountRange.value = null;
    plotSizeController.clear();
    plotSizeUnit.value = LandUnit.katha;
    plotSizeValue.value = 0;
    plotSizeRange.value = null;
    pricePerKathaValue.value = 0;
    distanceRange.value = null;
    location.value = const LocationData();
    propertyTypeError.value = '';
    photos.clear();
    video.value = null;
    deedDocuments.clear();
    khatianDocuments.clear();
    otherDocuments.clear();
    selectedServices.clear();
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
