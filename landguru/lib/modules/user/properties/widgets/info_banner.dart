import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Info banner type
enum InfoBannerType { info, warning, success, error }

/// Info banner widget for displaying important messages
class InfoBanner extends StatelessWidget {
  final String message;
  final InfoBannerType type;
  final IconData? icon;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = InfoBannerType.info,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case InfoBannerType.info:
        return AppColors.primary.withAlpha(30);
      case InfoBannerType.warning:
        return AppColors.warning.withAlpha(15);
      case InfoBannerType.success:
        return AppColors.success.withAlpha(15);
      case InfoBannerType.error:
        return AppColors.error.withAlpha(15);
    }
  }

  Color get _iconColor {
    switch (type) {
      case InfoBannerType.info:
        return AppColors.primary;
      case InfoBannerType.warning:
        return AppColors.warning;
      case InfoBannerType.success:
        return AppColors.success;
      case InfoBannerType.error:
        return AppColors.error;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case InfoBannerType.info:
        return Icons.info_outline;
      case InfoBannerType.warning:
        return Icons.warning_amber_outlined;
      case InfoBannerType.success:
        return Icons.check_circle_outline;
      case InfoBannerType.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _iconColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, color: _iconColor, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
