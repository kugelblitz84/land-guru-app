import 'package:flutter/material.dart';

/// Phone number input field with country code
class PhoneInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String countryCode;

  const PhoneInputField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.countryCode = '+880',
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement phone input UI with country code selector
    return const Placeholder();
  }
}
