import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../forgot_password_controller.dart';

/// Forgot Password Step 1: Enter phone number
class ForgotPasswordPhoneView extends GetView<ForgotPasswordController> {
  const ForgotPasswordPhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement phone input UI
    // - Title: Forgot Password
    // - Subtitle: Enter your phone number to reset
    // - Phone input with country code
    // - Continue button
    // - Back to login link
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
