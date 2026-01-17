import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Document data model
class DocumentItem {
  final String id;
  final String name;
  final String path;
  final String? size;
  final bool isLocal;

  const DocumentItem({
    required this.id,
    required this.name,
    required this.path,
    this.size,
    this.isLocal = true,
  });
}

/// Document upload widget with file list
class DocumentUploadWidget extends StatelessWidget {
  final String label;
  final List<DocumentItem> documents;
  final VoidCallback onAddDocument;
  final ValueChanged<int> onRemoveDocument;
  final bool isRequired;
  final int maxSizeMB;

  const DocumentUploadWidget({
    super.key,
    required this.label,
    required this.documents,
    required this.onAddDocument,
    required this.onRemoveDocument,
    this.isRequired = true,
    this.maxSizeMB = 5,
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
              Icons.description_outlined,
              size: 18.sp,
              color: AppColors.grey700,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 15.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 12.h),

        // Document list
        ...documents.asMap().entries.map((entry) {
          return _buildDocumentItem(entry.value, entry.key);
        }),

        // Upload button
        GestureDetector(
          onTap: onAddDocument,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withAlpha(50),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Upload ${label.replaceAll(' section', '').replaceAll('*', '').trim()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'PDF/DOCX, max size ${maxSizeMB}MB',
          style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(DocumentItem document, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getFileIcon(document.name),
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (document.size != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    document.size!,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: () => onRemoveDocument(index),
            child: Icon(Icons.close, color: AppColors.grey500, size: 20.sp),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.article;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// Document list for review screens (read-only)
class DocumentListPreview extends StatelessWidget {
  final String label;
  final List<DocumentItem> documents;

  const DocumentListPreview({
    super.key,
    required this.label,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 18.sp,
              color: AppColors.grey700,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...documents.map((document) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    document.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
