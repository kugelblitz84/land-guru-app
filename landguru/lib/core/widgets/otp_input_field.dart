import 'package:flutter/material.dart';

/// OTP input field with 6 digit boxes
class OtpInputField extends StatelessWidget {
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final int length;

  const OtpInputField({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement OTP input UI with individual digit boxes
    return const Placeholder();
  }
}
