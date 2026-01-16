import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../signup_controller.dart';

/// Signup Step 2: Verify OTP
class SignupOtpView extends GetView<SignupController> {
  const SignupOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement OTP verification UI
    // - Step indicator (2/4)
    // - Title: Verify your phone
    // - Subtitle showing phone number
    // - OTP input (6 digits)
    // - Resend OTP link with countdown
    // - Verify button
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
