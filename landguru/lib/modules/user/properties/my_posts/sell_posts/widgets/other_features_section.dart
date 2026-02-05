import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/sell_post_models.dart';

/// Other Features Section for Active status (expandable sections)
class OtherFeaturesSection extends StatelessWidget {
  final List<DueDiligenceItem>? dueDiligenceChecklist;
  final List<OwnershipHistoryItem>? ownershipHistory;
  final List<ServiceVerificationItem>? servicesTaken;
  final bool dueDiligenceExpanded;
  final bool videoExpanded;
  final bool ownershipExpanded;
  final Function(int) onToggleExpansion;

  const OtherFeaturesSection({
    super.key,
    this.dueDiligenceChecklist,
    this.ownershipHistory,
    this.servicesTaken,
    required this.dueDiligenceExpanded,
    required this.videoExpanded,
    required this.ownershipExpanded,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.featured_play_list_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Other Features',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey600,
                size: 24.sp,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Risk & Due Diligence Checklist
          if (dueDiligenceChecklist != null)
            _buildExpandableFeature(
              index: 0,
              title: 'Risk & Due Diligence Checklist',
              subtitle: 'Get further verification about this property',
              icon: Icons.checklist_rounded,
              iconColor: AppColors.primary,
              content: _buildDueDiligenceContent(),
              isExpanded: dueDiligenceExpanded,
            ),

          // Property Video
          _buildExpandableFeature(
            index: 1,
            title: 'Property Video',
            subtitle: 'Get a video tour of the property before buying',
            icon: Icons.videocam_outlined,
            iconColor: AppColors.primary,
            content: _buildVideoContent(),
            isExpanded: videoExpanded,
          ),

          // Ownership History
          if (ownershipHistory != null)
            _buildExpandableFeature(
              index: 2,
              title: 'Ownership History',
              subtitle: 'Get to know the connected owners history',
              icon: Icons.history,
              iconColor: AppColors.grey600,
              content: _buildOwnershipHistoryContent(),
              isExpanded: ownershipExpanded,
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableFeature({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget content,
    required bool isExpanded,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => onToggleExpansion(index),
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildDueDiligenceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...?dueDiligenceChecklist?.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.success,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grey700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 8.h),
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: Center(
            child: Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 40.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ...?ownershipHistory?.asMap().entries.map((entry) {
          final index = entry.key;
          final owner = entry.value;
          final isLast = index == (ownershipHistory?.length ?? 0) - 1;
          final isFirst = index == 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.primary.withAlpha(20)
                          : AppColors.grey100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFirst ? AppColors.primary : AppColors.grey300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: isFirst ? AppColors.primary : AppColors.grey400,
                      size: 18.sp,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40.h, color: AppColors.grey300),
                ],
              ),
              SizedBox(width: 12.w),
              // Owner info card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.white : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isFirst
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                          if (owner.period.isNotEmpty)
                            Text(
                              owner.period,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isFirst
                                    ? AppColors.primary
                                    : AppColors.grey500,
                              ),
                            ),
                        ],
                      ),
                      if (owner.isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// Pentagraph Map Section for Active status
class PentagraphMapSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const PentagraphMapSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pentagraph Map',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Detailed Mouza map of the area',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
              child: Column(
                children: [
                  Divider(color: AppColors.grey200),
                  SizedBox(height: 12.h),
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: Image.asset(
                        'assets/images/Maps/PentaGraphMap.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 48.sp,
                                  color: AppColors.grey400,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Pentagraph Map',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Services Taken Section for Active status
class ServicesTakenSection extends StatelessWidget {
  // Agent images for services
  static const List<String> _agentImages = [
    'assets/images/User_DP/abrar.jpg',
    'assets/images/User_DP/Farhan.jpg',
    'assets/images/User_DP/forhad.jpg',
    'assets/images/User_DP/jahangir.jpg',
    'assets/images/User_DP/rahman.jpg',
    'assets/images/User_DP/sahil.jpg',
  ];

  final List<ServiceVerificationItem> services;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ServicesTakenSection({
    super.key,
    required this.services,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.miscellaneous_services_outlined,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Services Taken',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Get to see which services was taken by the seller',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
              child: Column(
                children: [
                  Divider(color: AppColors.grey200),
                  SizedBox(height: 12.h),
                  ...services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    final isLast = index == services.length - 1;
                    final agentImage =
                        _agentImages[index % _agentImages.length];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 100.h,
                                color: AppColors.grey300,
                              ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        // Service card
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service name and verified badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.serviceName,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                    ),
                                    if (service.isVerified)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          'Verified',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                // Assigned agent label
                                Text(
                                  'ASSIGNED AGENT',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.grey500,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                // Agent info with avatar
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor: AppColors.grey200,
                                      backgroundImage: AssetImage(agentImage),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.assignedAgent,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.grey900,
                                          ),
                                        ),
                                        if (service.agentRole.isNotEmpty)
                                          Text(
                                            service.agentRole,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.grey500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
