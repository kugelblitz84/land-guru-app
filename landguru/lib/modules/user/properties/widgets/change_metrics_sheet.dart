import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'metrics_input_field.dart';

/// Bottom sheet for changing measurement unit
class ChangeMetricsSheet extends StatelessWidget {
  final LandUnit selectedUnit;
  final ValueChanged<LandUnit> onUnitSelected;

  const ChangeMetricsSheet({
    super.key,
    required this.selectedUnit,
    required this.onUnitSelected,
  });

  /// Show the change metrics bottom sheet
  static Future<LandUnit?> show(
    BuildContext context, {
    required LandUnit currentUnit,
  }) {
    return showModalBottomSheet<LandUnit>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ChangeMetricsSheet(
          selectedUnit: currentUnit,
          onUnitSelected: (unit) {
            Navigator.pop(context, unit);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            'Select Unit',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 16.h),

          // Unit options
          ...LandUnit.values.map((unit) {
            final isSelected = unit == selectedUnit;
            return GestureDetector(
              onTap: () => onUnitSelected(unit),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.grey200, width: 1),
                  ),
                ),
                child: Text(
                  unit.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.grey700,
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
