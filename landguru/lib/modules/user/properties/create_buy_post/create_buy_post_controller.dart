import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service for Create Buy Post flow (2 steps)
/// Step 1: Requirements (property type, size, budget, location)
/// Step 2: Review & submit
class CreateBuyPostController extends GetxService {
  // Current step (1-2)
  final RxInt currentStep = 1.obs;

  // Step 1: Requirements
  final requirementsFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final minBudgetController = TextEditingController();
  final maxBudgetController = TextEditingController();
  final minSizeController = TextEditingController();
  final maxSizeController = TextEditingController();
  final RxString propertyType = ''.obs;
  final RxString selectedLocation = ''.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  /// Move to next step
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  /// Validate and move to review
  void validateAndNext() {
    if (requirementsFormKey.currentState!.validate()) {
      nextStep();
    }
  }

  /// Submit buy post
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
    minBudgetController.dispose();
    maxBudgetController.dispose();
    minSizeController.dispose();
    maxSizeController.dispose();
    super.onClose();
  }
}
