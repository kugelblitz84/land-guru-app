import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_sell_post_controller.dart';
import 'views/create_sell_post_info_view.dart';
import 'views/create_sell_post_media_view.dart';
import 'views/create_sell_post_services_view.dart';
import 'views/create_sell_post_review_view.dart';

/// Main wrapper view for Create Sell Post flow
/// Handles navigation between steps based on controller state
class CreateSellPostView extends GetView<CreateSellPostController> {
  const CreateSellPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 1:
          return const CreateSellPostInfoView();
        case 2:
          return const CreateSellPostMediaView();
        case 3:
          return const CreateSellPostServicesView();
        case 4:
          return const CreateSellPostReviewView();
        default:
          return const CreateSellPostInfoView();
      }
    });
  }
}
