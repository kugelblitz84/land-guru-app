import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'models/property_details_models.dart';
import 'property_details_controller.dart';
import 'widgets/property_details_widgets.dart';

/// Property Details - Locked View (before paying to unlock)
class PropertyDetailsLockedView extends GetView<PropertyDetailsController> {
  const PropertyDetailsLockedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(Icons.arrow_back, color: AppColors.grey900, size: 24.sp),
        ),
        title: Text(
          'Property Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final property = controller.property.value;
        if (property == null) {
          return const Center(child: Text('Property not found'));
        }

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Image
                    _buildPropertyImage(property),

                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Title and Price
                          PropertyTitleSection(property: property),

                          SizedBox(height: 12.h),

                          // Tags
                          PropertyTagsSection(
                            property: property,
                            isLocked: true,
                          ),

                          SizedBox(height: 16.h),

                          // Description
                          PropertyDescriptionSection(
                            description: property.description,
                            isExpanded: controller.isDescriptionExpanded.value,
                            onToggle: controller.toggleDescription,
                          ),

                          SizedBox(height: 16.h),

                          // Location
                          PropertyDetailRow(
                            imageAsset: 'assets/Logos/Location.png',
                            label: 'Location',
                            value: property.location,
                          ),

                          SizedBox(height: 16.h),

                          // Sellable Land Amount
                          Obx(() {
                            final conversions = controller.getAllConversions(
                              property.sellableLandAmount,
                            );
                            final convertedValue = controller
                                .getConvertedLandAmount(
                                  property.sellableLandAmount,
                                );
                            final currentUnit =
                                controller.selectedLandUnit.value.label;

                            // Build conversions map with labels
                            final conversionsMap = <String, double>{};
                            conversions.forEach((unit, value) {
                              if (unit.label != currentUnit) {
                                conversionsMap[unit.label] = value;
                              }
                            });

                            return PropertyDetailRowWithAction(
                              imageAsset: 'assets/Logos/Land&plotSize.png',
                              label: 'Sellable Land Amount',
                              value: convertedValue,
                              actionText: 'Change Metrics',
                              onAction: controller.changeMetrics,
                              conversions: conversionsMap,
                              currentUnit: currentUnit,
                            );
                          }),

                          SizedBox(height: 16.h),

                          // Plot Size
                          Obx(() {
                            final conversions = controller.getAllConversions(
                              property.plotSize,
                            );
                            final convertedValue = controller
                                .getConvertedLandAmount(property.plotSize);
                            final currentUnit =
                                controller.selectedLandUnit.value.label;

                            // Build conversions map with labels
                            final conversionsMap = <String, double>{};
                            conversions.forEach((unit, value) {
                              if (unit.label != currentUnit) {
                                conversionsMap[unit.label] = value;
                              }
                            });

                            return PropertyDetailRowWithAction(
                              imageAsset: 'assets/Logos/Land&plotSize.png',
                              label: 'Plot Size',
                              value: convertedValue,
                              actionText: 'Change Metrics',
                              onAction: controller.changeMetrics,
                              conversions: conversionsMap,
                              currentUnit: currentUnit,
                            );
                          }),

                          SizedBox(height: 16.h),

                          // Distance from Road
                          PropertyDetailRow(
                            imageAsset: 'assets/Logos/DistanceFromRoad.png',
                            label: 'Distance from Road',
                            value: property.distanceFromRoad,
                          ),

                          SizedBox(height: 20.h),

                          // Land Shape
                          const LandShapeSection(),

                          SizedBox(height: 20.h),

                          // Property Photos
                          PropertyPhotosSection(
                            photos: property.propertyPhotos,
                          ),

                          SizedBox(height: 24.h),

                          // Locked Features Section
                          _buildLockedFeaturesSection(),

                          SizedBox(height: 24.h),

                          // How to buy section
                          const HowToBuySection(),

                          SizedBox(height: 24.h),

                          // Posted By section
                          PostedBySection(
                            name: property.postedBy,
                            isVerified: property.isVerified,
                            postedTime: property.postedTime,
                          ),

                          SizedBox(height: 100.h), // Space for bottom button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action button
            _buildBottomActionButton(),
          ],
        );
      }),
    );
  }

  Widget _buildPropertyImage(PropertyDetails property) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: property.propertyPhotos.isNotEmpty
            ? Image.asset(
                property.propertyPhotos.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primary.withAlpha(50),
      child: Center(
        child: Icon(
          Icons.image,
          size: 60.sp,
          color: AppColors.primary.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildLockedFeaturesSection() {
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
              Icon(Icons.lock, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Locked Features',
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

          // Feature items
          ...controller.lockedFeatures.map((feature) {
            return _buildLockedFeatureItem(feature);
          }),

          SizedBox(height: 16.h),

          // Unlock button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.unlockProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_open, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Unlock All Features at ৳4000',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Info text
          Text(
            'Pay one time fee to unlock the above features.\nAll post will be unlocked afterwards',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedFeatureItem(LockedFeature feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: feature.iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(feature.icon, color: feature.iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  feature.subtitle,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Obx(() {
      final hasRequested = controller.hasRequestedAppointment.value;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasRequested
                    ? null
                    : () => _showRequestAppointmentDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasRequested
                      ? AppColors.grey300
                      : AppColors.primary,
                  foregroundColor: hasRequested
                      ? AppColors.grey600
                      : AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBackgroundColor: AppColors.grey300,
                  disabledForegroundColor: AppColors.grey600,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasRequested
                          ? 'Request for appointment'
                          : 'Request For Appointment',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!hasRequested) ...[
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 20.sp),
                    ],
                  ],
                ),
              ),
            ),
            if (hasRequested) ...[
              SizedBox(height: 8.h),
              Text(
                'Check appointment section to see the update.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showRequestAppointmentDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => RequestAppointmentDialog(
        property: controller.property.value!,
        userName: controller.userName.value,
        initialPhone: controller.userPhone.value,
        initialAddress: controller.userAddress.value,
        onSubmit: (phone, address) async {
          final success = await controller.submitAppointmentRequest(
            phone: phone,
            address: address,
          );
          if (success) {
            Get.back(); // Close the request dialog first
            _showRequestSubmittedDialog(); // Then show success dialog
          }
          return success;
        },
      ),
    );
  }

  void _showRequestSubmittedDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => RequestSubmittedDialog(
        property: controller.property.value!,
        onClose: () => Get.back(),
      ),
    );
  }
}

/// Request Appointment Dialog
class RequestAppointmentDialog extends StatefulWidget {
  final PropertyDetails property;
  final String userName;
  final String initialPhone;
  final String initialAddress;
  final Future<bool> Function(String phone, String address) onSubmit;

  const RequestAppointmentDialog({
    super.key,
    required this.property,
    required this.userName,
    required this.initialPhone,
    required this.initialAddress,
    required this.onSubmit,
  });

  @override
  State<RequestAppointmentDialog> createState() =>
      _RequestAppointmentDialogState();
}

class _RequestAppointmentDialogState extends State<RequestAppointmentDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(
      _phoneController.text,
      _addressController.text,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
    // Note: Parent callback handles closing this dialog and showing success dialog
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request For Appointment',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: AppColors.grey600,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              Text(
                'By requesting for appointment, you are agreeing to share your details below. You will be notified for appointment soon.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
              ),

              SizedBox(height: 16.h),

              // Property card
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: property.propertyPhotos.isNotEmpty
                          ? Image.asset(
                              property.propertyPhotos.first,
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60.w,
                                  height: 60.h,
                                  color: AppColors.grey200,
                                  child: Icon(
                                    Icons.image,
                                    color: AppColors.grey400,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 60.w,
                              height: 60.h,
                              color: AppColors.grey200,
                              child: Icon(
                                Icons.image,
                                color: AppColors.grey400,
                              ),
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                'Price: ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                              Text(
                                '৳ ${property.price}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              _buildSmallTag(
                                property.propertyType,
                                property.propertyTypeColor,
                              ),
                              SizedBox(width: 6.w),
                              if (property.isVerified)
                                _buildSmallTag(
                                  'Verified',
                                  AppColors.success,
                                  icon: Icons.check_circle,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Full Name (read-only)
              _buildLabel('Full Name', isRequired: true),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.userName,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
                ),
              ),

              SizedBox(height: 16.h),

              // Phone Number
              _buildLabel('Phone Number', isRequired: true),
              SizedBox(height: 8.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey400,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
              ),

              SizedBox(height: 16.h),

              // Your Address
              _buildLabel('Your Address', isRequired: true),
              SizedBox(height: 8.h),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey400,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
              ),

              SizedBox(height: 24.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Request for appointment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey900,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(fontSize: 14.sp, color: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildSmallTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10.sp, color: AppColors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Request Submitted Dialog
class RequestSubmittedDialog extends StatelessWidget {
  final PropertyDetails property;
  final VoidCallback onClose;

  const RequestSubmittedDialog({
    super.key,
    required this.property,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: AppColors.grey600, size: 24.sp),
              ),
            ),

            // Success icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 50.sp,
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              'Request Submitted',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),

            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'You will be notified for appointment soon.\nIt may take up to 1-3 business days for reviewing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
            ),

            SizedBox(height: 20.h),

            // Property card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: property.propertyPhotos.isNotEmpty
                        ? Image.asset(
                            property.propertyPhotos.first,
                            width: 60.w,
                            height: 60.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60.w,
                                height: 60.h,
                                color: AppColors.grey200,
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.grey400,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 60.w,
                            height: 60.h,
                            color: AppColors.grey200,
                            child: Icon(Icons.image, color: AppColors.grey400),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              'Price: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              '৳ ${property.price}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: property.propertyTypeColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                property.propertyType,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            if (property.isVerified)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Status
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Pending Admin Review',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
