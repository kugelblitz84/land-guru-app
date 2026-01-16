import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for Create Sell Post flow (4 steps)
/// Step 1: Property info (title, type, location, price)
/// Step 2: Media (photos, video)
/// Step 3: Services selection
/// Step 4: Review & submit
class CreateSellPostController extends GetxService {
  // Current step (1-4)
  final RxInt currentStep = 1.obs;

  // Step 1: Property Info
  final infoFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final areaSizeController = TextEditingController();
  final RxString propertyType = ''.obs; // Flat, Plain Land, Water Land
  final RxString selectedLocation = ''.obs;

  // Step 2: Media
  final RxList<String> photos = <String>[].obs;
  final RxString videoPath = ''.obs;
  final RxList<String> documents = <String>[].obs;

  // Step 3: Services
  final RxList<String> selectedServices = <String>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;

  /// Move to next step
  void nextStep() {
    if (currentStep.value < 4) {
      currentStep.value++;
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  /// Validate and move to next step from Step 1
  void validateAndNextFromInfo() {
    if (infoFormKey.currentState!.validate()) {
      nextStep();
    }
  }

  /// Add photo
  Future<void> addPhoto() async {
    // TODO: Implement photo picker
  }

  /// Remove photo
  void removePhoto(int index) {
    photos.removeAt(index);
  }

  /// Add video
  Future<void> addVideo() async {
    // TODO: Implement video picker
  }

  /// Add document
  Future<void> addDocument() async {
    // TODO: Implement document picker
  }

  /// Toggle service selection
  void toggleService(String serviceId) {
    if (selectedServices.contains(serviceId)) {
      selectedServices.remove(serviceId);
    } else {
      selectedServices.add(serviceId);
    }
  }

  /// Save as draft
  Future<void> saveAsDraft() async {
    isSavingDraft.value = true;
    try {
      // TODO: Implement save draft API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isSavingDraft.value = false;
    }
  }

  /// Submit post for review
  Future<void> submitPost() async {
    isLoading.value = true;
    try {
      // TODO: Implement submit post API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Navigate to success or my posts
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    areaSizeController.dispose();
    super.onClose();
  }
}
