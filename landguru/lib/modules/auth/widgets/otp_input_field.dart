import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// OTP input field with individual digit boxes
class OtpInputField extends StatefulWidget {
  final int length;
  final List<TextEditingController>? controllers;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const OtpInputField({
    super.key,
    this.length = 4,
    this.controllers,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final bool _ownsControllers;

  @override
  void initState() {
    super.initState();
    if (widget.controllers != null &&
        widget.controllers!.length != widget.length) {
      throw ArgumentError(
        'OtpInputField controllers length must match the length parameter.',
      );
    }
    _ownsControllers = widget.controllers == null;
    _controllers =
        widget.controllers ??
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    if (_ownsControllers) {
      for (final c in _controllers) {
        c.dispose();
      }
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _notify() {
    final otp = _otp;
    widget.onChanged?.call(otp);

    if (otp.length == widget.length &&
        !_controllers.any((c) => c.text.isEmpty)) {
      widget.onCompleted?.call(otp);
    }
  }

  void _moveTo(int index) {
    if (index < 0 || index >= widget.length) return;
    _focusNodes[index].requestFocus();
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _controllers[index].text.length),
    );
  }

  void _setFromPaste(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return;

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < clean.length ? clean[i] : '';
    }

    setState(() {});
    _notify();

    final nextIndex = clean.length >= widget.length
        ? widget.length - 1
        : clean.length;
    _moveTo(nextIndex.clamp(0, widget.length - 1));
  }

  void _onChanged(int index, String value) {
    // if user pasted (some keyboards paste into one field)
    if (value.length > 1) {
      _setFromPaste(value);
      return;
    }

    setState(() {});

    if (value.isNotEmpty) {
      // ✅ move forward when a digit typed
      if (index < widget.length - 1) {
        _moveTo(index + 1);
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _notify();
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    // ✅ backspace behavior: if empty, go prev and clear it
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      setState(() {});
      _moveTo(index - 1);
      _notify();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 70.w,
          height: 60.h,
          child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true), // no stealing focus
            onKeyEvent: (event) => _onKey(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: index == widget.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              maxLength: 1,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _controllers[index].text.isNotEmpty
                    ? AppColors.primary.withAlpha(26)
                    : AppColors.grey100,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: _controllers[index].text.isNotEmpty
                        ? AppColors.primary.withAlpha(77)
                        : Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
