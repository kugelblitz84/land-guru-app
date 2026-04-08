import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// Phone number input field with country code
class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final String hintText;

  // Field background color
  static const Color _fieldColor = Color.fromARGB(255, 255, 255, 255);

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.hintText = '17000-00000',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            validator: validator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            style: TextStyle(
              fontSize: 16.sp,
              color: enabled ? AppColors.grey900 : AppColors.grey600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.grey400),
              prefixIcon: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bangladesh flag from assets
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: Image.asset(
                        'assets/Logos/Bangladesh.png',
                        width: 24.w,
                        height: 16.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '+880',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.grey900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(width: 1, height: 24.h, color: AppColors.grey300),
                  ],
                ),
              ),
              filled: true,
              fillColor: enabled ? _fieldColor : AppColors.grey200,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
