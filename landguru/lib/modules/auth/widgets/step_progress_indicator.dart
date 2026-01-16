import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// Step progress indicator widget for multi-step forms
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((currentStep / totalSteps) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : AppColors.grey200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
