import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../modules/user/properties/create_sell_post/services/sell_post_service.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/utils/currency_formatter.dart';
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

  // Share Unit (Optional) - only visible when checkbox is checked
  final RxBool hasShareUnit = false.obs;
  final shareUnitController = TextEditingController();
  final Rx<LandUnit> shareUnitUnit = LandUnit.katha.obs;
  final RxDouble shareUnitValue = 0.0.obs; // Reactive value for share unit
  final Rx<LandSizeRange?> shareUnitRange = Rx<LandSizeRange?>(null);
  final service = Get.find<SellPostService>();
  // Price per katha reactive
  final RxDouble pricePerKathaValue = 0.0.obs;
  // isNegotiable
  final RxBool isNegotiable = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update reactive values when text changes
    landAmountController.addListener(_updateLandAmountValue);
    plotSizeController.addListener(_updatePlotSizeValue);
    shareUnitController.addListener(_updateShareUnitValue);
    pricePerKathaController.addListener(_updatePricePerKathaValue);
  }

  void _updateLandAmountValue() {
    landAmountValue.value = double.tryParse(landAmountController.text) ?? 0;
  }

  void _updatePlotSizeValue() {
    plotSizeValue.value = double.tryParse(plotSizeController.text) ?? 0;
  }

  void _updateShareUnitValue() {
    shareUnitValue.value = double.tryParse(shareUnitController.text) ?? 0;
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
  final RxBool isUploadingMedia = false.obs;
  final RxnString draftPostId = RxnString();

  /// Calculate asking price (price per katha × land amount in katha)
  double get askingPrice {
    // Convert land amount to katha if different unit
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

  /// Format share unit for display
  String get formattedShareUnit {
    if (!hasShareUnit.value) return '';
    final value = shareUnitValue.value;
    if (value == 0) return '';
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} ${shareUnitUnit.value.label}';
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
    // Clear previous errors
    propertyTypeError.value = '';

    // Validate property type
    if (propertyType.value == null) {
      propertyTypeError.value = 'Please select a property type';
      return;
    }

    // Validate form fields
    if (!infoFormKey.currentState!.validate()) {
      return;
    }

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

    await ApiErrorHandler.call(
      () => _submitStep1(advanceStep: true, showSuccessSnack: false),
    );
  }

  void toggleIsNegotiable() {
    isNegotiable.value = !isNegotiable.value;
  }

  /// Validate step 2 (media) and proceed
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

    if (video.value == null) {
      Get.snackbar(
        'Video Required',
        'Please add a property video',
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

    await ApiErrorHandler.call(
      () => _submitStep2(advanceStep: true, showSuccessSnack: false),
    );
  }

  /// Validate step 3 (services) and proceed
  Future<void> validateAndNextFromServices() async {
    await ApiErrorHandler.call(
      () => _submitStep3(advanceStep: true, showSuccessSnack: false),
    );
  }

  /// Change land amount unit
  void changeLandAmountUnit(LandUnit unit) {
    _convertMetricValue(
      unitState: landAmountUnit,
      valueState: landAmountValue,
      controller: landAmountController,
      listener: _updateLandAmountValue,
      newUnit: unit,
    );
  }

  /// Change plot size unit
  void changePlotSizeUnit(LandUnit unit) {
    _convertMetricValue(
      unitState: plotSizeUnit,
      valueState: plotSizeValue,
      controller: plotSizeController,
      listener: _updatePlotSizeValue,
      newUnit: unit,
    );
  }

  /// Change share unit unit
  void changeShareUnitUnit(LandUnit unit) {
    _convertMetricValue(
      unitState: shareUnitUnit,
      valueState: shareUnitValue,
      controller: shareUnitController,
      listener: _updateShareUnitValue,
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

  /// Toggle share unit checkbox
  void toggleShareUnit(bool value) {
    hasShareUnit.value = value;
    if (!value) {
      // Clear share unit data when unchecked
      shareUnitController.clear();
      shareUnitValue.value = 0;
      shareUnitUnit.value = LandUnit.katha;
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

  /// Update land amount from slider (updates text field)
  void updateLandAmountFromSlider(double value) {
    landAmountValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
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
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    if (plotSizeController.text != formattedValue) {
      plotSizeController.removeListener(_updatePlotSizeValue);
      plotSizeController.text = formattedValue;
      plotSizeController.addListener(_updatePlotSizeValue);
    }
  }

  /// Update share unit from slider (updates text field)
  void updateShareUnitFromSlider(double value) {
    shareUnitValue.value = value;
    // Update text field without triggering listener loop
    final formattedValue = value == value.toInt()
        ? value.toInt().toString()
        : value
              .toStringAsFixed(3)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    if (shareUnitController.text != formattedValue) {
      shareUnitController.removeListener(_updateShareUnitValue);
      shareUnitController.text = formattedValue;
      shareUnitController.addListener(_updateShareUnitValue);
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
    if (isUploadingMedia.value) {
      return;
    }

    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
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

  // Video management
  Future<void> addVideo() async {
    if (isUploadingMedia.value) {
      return;
    }

    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv'],
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
      video.value = VideoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: uploadResult.data!,
        isLocal: false,
      );
    }
    isUploadingMedia.value = false;
  }

  void removeVideo() {
    video.value = null;
  }

  // Document management
  Future<void> addDeedDocument() async {
    await _pickAndUploadDocument(target: deedDocuments, labelPrefix: 'Deed');
  }

  void removeDeedDocument(int index) {
    if (index >= 0 && index < deedDocuments.length) {
      deedDocuments.removeAt(index);
    }
  }

  Future<void> addKhatianDocument() async {
    await _pickAndUploadDocument(
      target: khatianDocuments,
      labelPrefix: 'Khatian',
    );
  }

  void removeKhatianDocument(int index) {
    if (index >= 0 && index < khatianDocuments.length) {
      khatianDocuments.removeAt(index);
    }
  }

  Future<void> addOtherDocument() async {
    await _pickAndUploadDocument(target: otherDocuments, labelPrefix: 'Other');
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
    if (isSavingDraft.value || isLoading.value) {
      return;
    }
    isSavingDraft.value = true;
    if (currentStep.value == 1) {
      await ApiErrorHandler.call(
        () => _submitStep1(advanceStep: false, showSuccessSnack: true),
      );
      isSavingDraft.value = false;
      return;
    }

    if (currentStep.value == 2) {
      await ApiErrorHandler.call(
        () => _submitStep2(advanceStep: false, showSuccessSnack: true),
      );
      isSavingDraft.value = false;
      return;
    }

    if (currentStep.value == 3) {
      await ApiErrorHandler.call(
        () => _submitStep3(advanceStep: false, showSuccessSnack: true),
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

  Future<void> _submitStep1({
    required bool advanceStep,
    required bool showSuccessSnack,
  }) async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    try {
      final payload = _buildStep1Payload();

      final response = await service.createDraftStep1(payload: payload);
      final id = response['id']?.toString();
      if (id != null && id.isNotEmpty) {
        draftPostId.value = id;
      }
      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your sell post has been saved as draft',
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
    }
  }

  Future<void> _submitStep2({
    required bool advanceStep,
    required bool showSuccessSnack,
  }) async {
    final id = draftPostId.value;
    if (id == null || id.isEmpty) {
      throw Exception('Please complete step 1 before uploading media.');
    }
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final payload = _buildStep2Payload();
      final service = Get.find<SellPostService>();
      await service.updateDraftStep(postId: id, step: 2, payload: payload);
      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your sell post media has been saved',
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
    }
  }

  Future<void> _submitStep3({
    required bool advanceStep,
    required bool showSuccessSnack,
  }) async {
    final id = draftPostId.value;
    if (id == null || id.isEmpty) {
      throw Exception('Please complete step 1 before selecting services.');
    }
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final payload = _buildStep3Payload();
      final service = Get.find<SellPostService>();
      await service.updateDraftStep(postId: id, step: 3, payload: payload);
      if (showSuccessSnack) {
        Get.snackbar(
          'Draft Saved',
          'Your sell post services have been saved',
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
      'pricePerUnit': pricePerKathaValue.value,
      'askingPrice': askingPrice,
      'isNegotiable': isNegotiable.value,
      if (range != null) 'roadDistanceMin': range.minMeters,
      if (range != null) 'roadDistanceMax': range.maxMeters,
      if (plotSizeValue.value > 0) 'plotSize': plotSizeValue.value,
      if (plotSizeValue.value > 0) 'plotUnit': plotSizeUnit.value.label,
      if (hasShareUnit.value && shareUnitValue.value > 0)
        'shareAmount': shareUnitValue.value,
      if (hasShareUnit.value && shareUnitValue.value > 0)
        'shareUnit': shareUnitUnit.value.label,
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
    final payload = <String, dynamic>{
      'photos': photos.map((photo) => photo.path).toList(),
      'deedFiles': deedDocuments.map((doc) => doc.path).toList(),
      'khatianFiles': khatianDocuments.map((doc) => doc.path).toList(),
      'otherFiles': otherDocuments.map((doc) => doc.path).toList(),
    };
    final videoUrl = video.value?.path;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      payload['videoUrl'] = videoUrl;
    }
    return payload;
  }

  Map<String, dynamic> _buildStep3Payload() {
    final titles = <String>[];
    titles.addAll(mandatoryServices.map((service) => service.title));

    for (final serviceId in selectedServices) {
      final matches = optionalServices
          .where((service) => service.id == serviceId)
          .toList();
      if (matches.isNotEmpty) {
        titles.add(matches.first.title);
      }
    }

    return {'selectedServices': titles};
  }

  /// Submit sell post for review
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
      final service = Get.find<SellPostService>();
      final result = await ApiErrorHandler.call(
        () => service.submitSellPost(postId: id),
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
          Get.offNamed(AppRoutes.HOME); // Navigate to home
          //Get.offNamed(AppRoutes.MY_POSTS); // Navigate to my posts
        },
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
    draftPostId.value = null;
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
    hasShareUnit.value = false;
    shareUnitController.clear();
    shareUnitUnit.value = LandUnit.katha;
    shareUnitValue.value = 0;
    shareUnitRange.value = null;
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

  Future<void> _pickAndUploadDocument({
    required RxList<DocumentItem> target,
    required String labelPrefix,
  }) async {
    if (isUploadingMedia.value) {
      return;
    }

    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (pickResult == null || pickResult.files.isEmpty) {
      return;
    }

    final file = pickResult.files.single;
    final path = file.path;
    if (path == null) {
      return;
    }

    isUploadingMedia.value = true;
    final uploadService = Get.find<UploadService>();
    final uploadResult = await ApiErrorHandler.call(
      () => uploadService.uploadFile(
        file: File(path),
        contentType: _guessContentType(path),
        type: 'DEED',
      ),
    );
    if (uploadResult.isSuccess && uploadResult.data != null) {
      final newDoc = DocumentItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name.isNotEmpty ? file.name : '$labelPrefix document',
        path: uploadResult.data!,
        size: _formatBytes(file.size),
        isLocal: false,
      );
      target.add(newDoc);
    }
    isUploadingMedia.value = false;
  }

  String _guessContentType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    if (i >= suffixes.length) {
      i = suffixes.length - 1;
    }
    final size = bytes / math.pow(1024, i);
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  void onClose() {
    landAmountController.removeListener(_updateLandAmountValue);
    plotSizeController.removeListener(_updatePlotSizeValue);
    shareUnitController.removeListener(_updateShareUnitValue);
    pricePerKathaController.removeListener(_updatePricePerKathaValue);
    titleController.dispose();
    descriptionController.dispose();
    pricePerKathaController.dispose();
    landAmountController.dispose();
    plotSizeController.dispose();
    shareUnitController.dispose();
    super.onClose();
  }
}
