import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_offer_controller.dart';
import 'views/create_offer_info_view.dart';
import 'views/create_offer_media_view.dart';
import 'views/create_offer_review_view.dart';

/// Main wrapper view for Create Offer flow
/// Handles navigation between steps based on controller state
class CreateOfferView extends GetView<CreateOfferController> {
  const CreateOfferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 1:
          return const CreateOfferInfoView();
        case 2:
          return const CreateOfferMediaView();
        case 3:
          return const CreateOfferReviewView();
        default:
          return const CreateOfferInfoView();
      }
    });
  }
}
