import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/land_unit.dart';

export '../../../../core/enums/land_unit.dart';

/// Metrics input field with unit dropdown
class MetricsInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final LandUnit selectedUnit;
  final ValueChanged<LandUnit> onUnitChanged;
  final bool isRequired;
  final String? hintText;
  final String? Function(String?)? validator;

  const MetricsInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.selectedUnit,
    required this.onUnitChanged,
    this.isRequired = true,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Number input
            Expanded(
              flex: 2,
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                elevation: 3,
                shadowColor: AppColors.black.withAlpha(100),

                //shadowColor: AppColors.black.withAlpha(50),
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: validator,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText ?? '0.000',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.grey400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: AppColors.black.withAlpha(25),
                    //     blurRadius: 10,
                    //     offset: const Offset(0, 4),
                    //   ),
                    // ],
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
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Unit dropdown
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LandUnit>(
                    value: selectedUnit,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey600,
                    ),
                    style: TextStyle(fontSize: 16.sp, color: AppColors.primary),
                    items: LandUnit.values.map((unit) {
                      return DropdownMenuItem<LandUnit>(
                        value: unit,
                        child: Text(unit.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onUnitChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
