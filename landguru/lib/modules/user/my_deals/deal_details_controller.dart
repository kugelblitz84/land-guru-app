import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';

/// Service for Deal Details screen
class DealDetailsController extends GetxService {
  // State
  final RxBool isLoading = false.obs;
  final RxString dealId = ''.obs;
  final RxBool isSoldDeal = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      dealId.value = Get.arguments['dealId'] ?? '';
      isSoldDeal.value = Get.arguments['isSold'] ?? true;
    }
    loadDealDetails();
  }

  /// Load deal details
  Future<void> loadDealDetails() async {
    isLoading.value = true;
    await ApiErrorHandler.call(
      () => Future<void>.delayed(const Duration(seconds: 1)),
      showError: false,
    );
    isLoading.value = false;
  }

  /// Download documents
  Future<void> downloadDocuments() async {
    // TODO: Implement download documents
  }
}

