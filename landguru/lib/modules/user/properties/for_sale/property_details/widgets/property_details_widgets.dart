import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/property_details_models.dart';

/// Property Title Section (Title, Price, Post ID)
class PropertyTitleSection extends StatelessWidget {
  final PropertyDetails property;

  const PropertyTitleSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '৳ ${property.price}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            property.postId,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

/// Property Tags Section (Property Type, Post Type, Verified, Locked/Unlocked)
class PropertyTagsSection extends StatelessWidget {
  final PropertyDetails property;
  final bool isLocked;

  const PropertyTagsSection({
    super.key,
    required this.property,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          // Property Type
          _buildTag(property.propertyType, property.propertyTypeColor),

          // Post Type
          _buildTag(property.postType, AppColors.grey600),

          // Verified
          if (property.isVerified)
            _buildTag('Verified', AppColors.success, icon: Icons.check_circle),

          // Locked/Unlocked
          _buildTag(
            isLocked ? 'Locked' : 'Unlocked',
            isLocked ? AppColors.grey600 : AppColors.success,
            icon: isLocked ? Icons.lock : Icons.lock_open,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: AppColors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Property Description Section with Read More
class PropertyDescriptionSection extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PropertyDescriptionSection({
    super.key,
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grey600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? 'Show Less' : 'Read More',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Property Detail Row (Icon + Label + Value)
class PropertyDetailRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final String? value;
  final String? iconPrefix;
  final String? imageAsset;

  const PropertyDetailRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.label,
    this.value,
    this.iconPrefix,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icon and Label on same line
          Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 20.w,
                  height: 20.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      icon ?? Icons.info,
                      size: 20.sp,
                      color: iconColor ?? AppColors.primary,
                    );
                  },
                )
              else if (iconPrefix != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withAlpha(30),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    iconPrefix!,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: iconColor ?? AppColors.primary,
                    ),
                  ),
                )
              else
                Icon(
                  icon ?? Icons.info,
                  size: 20.sp,
                  color: iconColor ?? AppColors.primary,
                ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          //SizedBox(height: 6.h),
          // Value/Description below
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 13.sp, color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Property Detail Row with Action (Change Metrics)
class PropertyDetailRowWithAction extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? iconPrefix;
  final String label;
  final String value;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? actionWidget;
  final Map<String, double>? conversions;
  final String? currentUnit;
  final String? imageAsset;

  const PropertyDetailRowWithAction({
    super.key,
    this.icon,
    this.iconColor,
    this.iconPrefix,
    required this.label,
    required this.value,
    this.actionText,
    this.onAction,
    this.actionWidget,
    this.conversions,
    this.currentUnit,
    this.imageAsset,
  }) : assert(
         actionWidget != null || (actionText != null && onAction != null),
         'Either actionWidget or both actionText and onAction must be provided',
       );

  String _formatValue(double val) {
    if (val >= 1000) {
      return val.toStringAsFixed(0);
    } else if (val >= 1) {
      return val.toStringAsFixed(2);
    } else {
      return val.toStringAsFixed(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and Label on same line with action widget
        Row(
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: 20.w,
                height: 20.h,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon ?? Icons.info,
                    size: 20.sp,
                    color: iconColor ?? AppColors.primary,
                  );
                },
              )
            else if (iconPrefix != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withAlpha(30),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  iconPrefix!,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              )
            else
              Icon(
                icon ?? Icons.info,
                size: 20.sp,
                color: iconColor ?? AppColors.primary,
              ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ),
            if (actionWidget != null)
              actionWidget!
            else
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        // Value and conversions below, aligned under label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            // Conversions row
            if (conversions != null && conversions!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                'In other metrics',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: conversions!.entries
                      .where((e) => currentUnit == null || e.key != currentUnit)
                      .map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: Text(
                            '${_formatValue(entry.value)} ${entry.key}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Land Shape Section with Map image
class LandShapeSection extends StatelessWidget {
  final String? imageUrl;

  const LandShapeSection({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                'Land Shape',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.r),
              child: _buildLandShapeImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandShapeImage() {
    final value = imageUrl?.trim() ?? '';
    if (value.isEmpty) {
      return _buildLandShapeFallback();
    }

    return Image.network(
      value,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildLandShapeFallback();
      },
    );
  }

  Widget _buildLandShapeFallback() {
    return Image.asset(
      'assets/images/Maps/LandShape.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48.sp, color: AppColors.grey400),
              SizedBox(height: 8.h),
              Text(
                'Land Shape Map',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Property Photos Section
class PropertyPhotosSection extends StatelessWidget {
  final List<String> photos;
  final ValueChanged<int>? onPhotoTap;

  const PropertyPhotosSection({
    super.key,
    required this.photos,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 10.w),
              Text(
                'Property Photos',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length + 1, // +1 for "more" indicator
              itemBuilder: (context, index) {
                if (index == photos.length) {
                  // More indicator
                  return GestureDetector(
                    onTap: photos.isNotEmpty ? () => onPhotoTap?.call(0) : null,
                    child: Container(
                      width: 80.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Center(
                        child: Text(
                          '+${photos.length}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => onPhotoTap?.call(index),
                  child: Container(
                    width: 80.w,
                    margin: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey200,
                            child: Icon(Icons.image, color: AppColors.grey400),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenImageViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const FullscreenImageViewerPage({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewerPage> createState() =>
      _FullscreenImageViewerPageState();
}

class _FullscreenImageViewerPageState extends State<FullscreenImageViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    if (widget.photos.isEmpty) {
      _currentIndex = 0;
      _pageController = PageController(initialPage: 0);
      return;
    }
    _currentIndex = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'No photos available',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.photos[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    size: 64.sp,
                    color: Colors.white54,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// How to Buy Section
class HowToBuySection extends StatelessWidget {
  const HowToBuySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to buy?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStep(
              imageAsset: 'assets/Logos/How Offering Work/You send offer.png',
              fallbackIcon: Icons.event_note_outlined,
              label: 'You request for\nAppointment',
            ),
            _buildArrow(),
            _buildStep(
              imageAsset:
                  'assets/Logos/How Offering Work/Buyers review and accepts.png',
              fallbackIcon: Icons.search,
              label: 'We review\nyour request',
            ),
            _buildArrow(),
            _buildStep(
              imageAsset:
                  'assets/Logos/How Offering Work/We schedule appointment.png',
              fallbackIcon: Icons.calendar_today_outlined,
              label: 'Schedules\nappointment',
            ),
            _buildArrow(),
            _buildStep(
              imageAsset:
                  'assets/Logos/How Offering Work/Meet with the buyer.png',
              fallbackIcon: Icons.people_outline,
              label: 'Meet with\nthe seller',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep({
    required String imageAsset,
    required IconData fallbackIcon,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imageAsset,
                width: 22.w,
                height: 22.h,
                color: AppColors.white,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    fallbackIcon,
                    color: AppColors.white,
                    size: 22.sp,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Icon(Icons.arrow_forward, size: 16.sp, color: AppColors.grey400),
    );
  }
}

/// Posted By Section
class PostedBySection extends StatelessWidget {
  final String name;
  final bool isVerified;
  final String? avatarUrl;
  final String postedTime;

  const PostedBySection({
    super.key,
    required this.name,
    required this.isVerified,
    this.avatarUrl,
    required this.postedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted By',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Avatar
              _buildAvatar(),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (isVerified)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 10.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    'Posted: $postedTime',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = avatarUrl?.trim() ?? '';
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: AppColors.grey200,
        child: Icon(Icons.person, color: AppColors.grey600, size: 20.sp),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 44.w,
        height: 44.h,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.grey200,
            child: Icon(Icons.person, color: AppColors.grey600, size: 20.sp),
          ),
        ),
      ),
    );
  }
}
