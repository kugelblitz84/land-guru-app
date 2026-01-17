import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_buy_post_controller.dart';
import 'views/create_buy_post_info_view.dart';
import 'views/create_buy_post_review_view.dart';

/// Main wrapper view for Create Buy Post flow
/// Handles navigation between steps based on controller state
class CreateBuyPostView extends GetView<CreateBuyPostController> {
  const CreateBuyPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 1:
          return const CreateBuyPostInfoView();
        case 2:
          return const CreateBuyPostReviewView();
        default:
          return const CreateBuyPostInfoView();
      }
    });
  }
}
