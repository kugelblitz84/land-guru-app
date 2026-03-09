import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Info banner type
class InfoBannerTypes {
  static const String info = 'info';
  static const String warning = 'warning';
  static const String success = 'success';
  static const String error = 'error';
}

/// Info banner widget for displaying important messages
class InfoBanner extends StatelessWidget {
  final String message;
  final String type;
  final IconData? icon;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = InfoBannerTypes.info,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case InfoBannerTypes.info:
        return AppColors.primary.withAlpha(30);
      case InfoBannerTypes.warning:
        return AppColors.warning.withAlpha(15);
      case InfoBannerTypes.success:
        return AppColors.success.withAlpha(15);
      case InfoBannerTypes.error:
      default:
        return AppColors.error.withAlpha(15);
    }
  }

  Color get _iconColor {
    switch (type) {
      case InfoBannerTypes.info:
        return AppColors.primary;
      case InfoBannerTypes.warning:
        return AppColors.warning;
      case InfoBannerTypes.success:
        return AppColors.success;
      case InfoBannerTypes.error:
      default:
        return AppColors.error;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case InfoBannerTypes.info:
        return Icons.info_outline;
      case InfoBannerTypes.warning:
        return Icons.warning_amber_outlined;
      case InfoBannerTypes.success:
        return Icons.check_circle_outline;
      case InfoBannerTypes.error:
      default:
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
