import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Video data model
class VideoItem {
  final String id;
  final String path;
  final String? thumbnailPath;
  final bool isLocal;

  const VideoItem({
    required this.id,
    required this.path,
    this.thumbnailPath,
    this.isLocal = true,
  });
}

/// Video upload widget
class VideoUploadWidget extends StatelessWidget {
  final VideoItem? video;
  final VoidCallback onAddVideo;
  final VoidCallback? onRemoveVideo;
  final VoidCallback? onPlayVideo;
  final String label;
  final bool isRequired;
  final int maxSizeMB;

  const VideoUploadWidget({
    super.key,
    this.video,
    required this.onAddVideo,
    this.onRemoveVideo,
    this.onPlayVideo,
    this.label = 'Property Video',
    this.isRequired = true,
    this.maxSizeMB = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 20.sp,
              color: AppColors.grey700,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 16.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 12.h),

        if (video == null)
          // Upload area
          GestureDetector(
            onTap: onAddVideo,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withAlpha(100),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.video_call_outlined,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Add Video Tour',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Max 1 file, Max size: ${maxSizeMB}MB',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          )
        else
          // Video preview
          _buildVideoPreview(),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary.withAlpha(150), AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: GestureDetector(
              onTap: onPlayVideo,
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                  size: 36.sp,
                ),
              ),
            ),
          ),
        ),

        // Remove button
        if (onRemoveVideo != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onRemoveVideo,
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.white, size: 18.sp),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact video preview for review screens
class VideoPreviewCompact extends StatelessWidget {
  final VideoItem video;
  final VoidCallback? onPlay;

  const VideoPreviewCompact({super.key, required this.video, this.onPlay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        width: double.infinity,
        height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary.withAlpha(150), AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: AppColors.primary,
              size: 32.sp,
            ),
          ),
        ),
      ),
    );
  }
}
