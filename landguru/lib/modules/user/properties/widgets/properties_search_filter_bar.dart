import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable search input with filter action button for property screens.
class PropertiesSearchFilterBar extends StatelessWidget {
  const PropertiesSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onFilterTap,
    this.hintText = 'Search location, area',
    this.inputBackgroundColor,
    this.buttonBackgroundColor,
    this.showShadow = true,
    this.padding,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onFilterTap;
  final String hintText;
  final Color? inputBackgroundColor;
  final Color? buttonBackgroundColor;
  final bool showShadow;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final boxShadow = showShadow
        ? <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : const <BoxShadow>[];

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: inputBackgroundColor ?? AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: boxShadow,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.grey500, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey900,
                      ),
                      onChanged: onSearchChanged,
                      onSubmitted: onSearchSubmitted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color:
                    buttonBackgroundColor ??
                    inputBackgroundColor ??
                    AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: boxShadow,
              ),
              child: Icon(Icons.tune, color: AppColors.grey700, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}
