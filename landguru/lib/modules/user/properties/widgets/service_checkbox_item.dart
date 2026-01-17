import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Verification service model
class VerificationService {
  final String id;
  final String title;
  final String? subtitle;
  final bool isMandatory;

  const VerificationService({
    required this.id,
    required this.title,
    this.subtitle,
    this.isMandatory = false,
  });
}

/// Service checkbox item widget
class ServiceCheckboxItem extends StatelessWidget {
  final VerificationService service;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  const ServiceCheckboxItem({
    super.key,
    required this.service,
    required this.isSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !service.isMandatory && onChanged != null;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged!(!isSelected) : null,
      child: Opacity(
        opacity: service.isMandatory ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey200,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                    : null,
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey900,
                      ),
                    ),
                    if (service.isMandatory) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 12.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Mandatory',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header for services list
class ServicesSectionHeader extends StatelessWidget {
  final String title;

  const ServicesSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
