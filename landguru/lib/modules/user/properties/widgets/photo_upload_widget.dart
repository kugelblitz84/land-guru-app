import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Photo data model
class PhotoItem {
  final String id;
  final String path;
  final bool isLocal;

  const PhotoItem({required this.id, required this.path, this.isLocal = true});
}

/// Photo upload widget with grid display
class PhotoUploadWidget extends StatelessWidget {
  final List<PhotoItem> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;
  final int maxPhotos;
  final String label;
  final bool isRequired;

  const PhotoUploadWidget({
    super.key,
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.maxPhotos = 10,
    this.label = 'Property Photos',
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(Icons.image_outlined, size: 20.sp, color: AppColors.grey700),
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

        // Upload area
        GestureDetector(
          onTap: photos.length < maxPhotos ? onAddPhoto : null,
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
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Image.asset(
                        'assets/Logos/Camera.png',
                        fit: BoxFit.contain,
                      ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Max $maxPhotos Photos',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ),

        // Photo thumbnails
        if (photos.isNotEmpty) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return _buildThumbnail(photos[index], index);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThumbnail(PhotoItem photo, int index) {
    return Container(
      width: 80.w,
      height: 80.h,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.grey200,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoPreviewTile(
              photo: photo,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),

          // Remove button
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => onRemovePhoto(index),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.white, size: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoPreviewTile extends StatelessWidget {
  final PhotoItem photo;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const PhotoPreviewTile({
    super.key,
    required this.photo,
    required this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = photo.isLocal
        ? Image.file(
            File(photo.path),
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(),
          )
        : Image.network(
            photo.path,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }
              return Container(
                color: AppColors.grey100,
                child: Center(
                  child: SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          );

    return ClipRRect(borderRadius: borderRadius, child: imageWidget);
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(100),
            AppColors.primaryDark.withAlpha(150),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.white.withAlpha(150),
          size: 24.sp,
        ),
      ),
    );
  }
}

/// Compact photo grid for review screens
class PhotoGridPreview extends StatelessWidget {
  final List<PhotoItem> photos;
  final int maxVisible;
  final VoidCallback? onViewAll;

  const PhotoGridPreview({
    super.key,
    required this.photos,
    this.maxVisible = 4,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final visiblePhotos = photos.take(maxVisible).toList();
    final remainingCount = photos.length - maxVisible;

    return Row(
      children: [
        ...visiblePhotos.asMap().entries.map((entry) {
          return Container(
            width: 60.w,
            height: 60.h,
            margin: EdgeInsets.only(right: 8.w),
            child: PhotoPreviewTile(
              photo: entry.value,
              borderRadius: BorderRadius.circular(8.r),
            ),
          );
        }),
        if (remainingCount > 0)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.grey200,
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
