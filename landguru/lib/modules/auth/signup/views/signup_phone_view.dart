import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../signup_controller.dart';

/// Signup Step 1: Enter phone number
class SignupPhoneView extends GetView<SignupController> {
  const SignupPhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement phone input UI
    // - Step indicator (1/4)
    // - Title: Enter your phone number
    // - Phone input with country code
    // - Continue button
    // - Already have account? Login link
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
