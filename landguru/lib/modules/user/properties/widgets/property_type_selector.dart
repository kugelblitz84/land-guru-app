import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Property types available for selection
enum PropertyType {
  plainLand('Plain Land'),
  flat('Flat'),
  commercial('Commercial'),
  waterLand('Water Land'),
  agroLand('Agro Land'),
  blankRoof('Blank Roof');

  final String label;
  const PropertyType(this.label);
}

/// Property type selector with chip-style buttons
class PropertyTypeSelector extends StatelessWidget {
  final PropertyType? selectedType;
  final ValueChanged<PropertyType> onChanged;
  final String? label;

  const PropertyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: PropertyType.values.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  // border: Border.all(
                  //   color: isSelected ? AppColors.primary : AppColors.grey500,
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
