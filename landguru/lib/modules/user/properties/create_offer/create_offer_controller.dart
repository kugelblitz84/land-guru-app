import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for Create Offer flow (3 steps)
/// Used when offering a property in response to a buy request
/// Step 1: Property info
/// Step 2: Media
/// Step 3: Review & submit
class CreateOfferController extends GetxService {
  // Current step (1-3)
  final RxInt currentStep = 1.obs;

  // Target buy post ID
  final RxString buyPostId = ''.obs;

  // Step 1: Property Info
  final infoFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final areaSizeController = TextEditingController();
  final RxString propertyType = ''.obs;
  final RxString selectedLocation = ''.obs;

  // Step 2: Media
  final RxList<String> photos = <String>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      buyPostId.value = Get.arguments['buyPostId'] ?? '';
    }
  }

  /// Move to next step
  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
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

  /// Submit offer
  Future<void> submitOffer() async {
    isLoading.value = true;
    try {
      // TODO: Implement submit offer API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Navigate to success
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
