import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Location data model
class LocationData {
  final String? division;
  final String? district;
  final String? upazila;
  final String? pouroshova;
  final String? wardNo;
  final String? postalCode;
  final String? fullAddress;

  const LocationData({
    this.division,
    this.district,
    this.upazila,
    this.pouroshova,
    this.wardNo,
    this.postalCode,
    this.fullAddress,
  });

  LocationData copyWith({
    String? division,
    String? district,
    String? upazila,
    String? pouroshova,
    String? wardNo,
    String? postalCode,
    String? fullAddress,
  }) {
    return LocationData(
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      pouroshova: pouroshova ?? this.pouroshova,
      wardNo: wardNo ?? this.wardNo,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  String get formattedAddress {
    final parts = <String>[];
    if (fullAddress != null && fullAddress!.isNotEmpty) {
      parts.add(fullAddress!);
    }
    if (wardNo != null && wardNo!.isNotEmpty) {
      parts.add('Ward No. $wardNo');
    }
    if (pouroshova != null && pouroshova!.isNotEmpty) {
      parts.add(pouroshova!);
    }
    if (upazila != null && upazila!.isNotEmpty) {
      parts.add('$upazila Thana');
    }
    if (district != null && district!.isNotEmpty) {
      parts.add(district!);
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    if (division != null && division!.isNotEmpty) {
      parts.add('$division Division');
    }
    return parts.join(', ');
  }

  bool get isComplete =>
      division != null &&
      district != null &&
      upazila != null &&
      pouroshova != null;
}

/// Location picker with cascading dropdowns
class LocationPicker extends StatelessWidget {
  final LocationData location;
  final ValueChanged<LocationData> onChanged;
  final bool showFullAddress;

  const LocationPicker({
    super.key,
    required this.location,
    required this.onChanged,
    this.showFullAddress = true,
  });

  // Mock data - replace with actual API data
  static const List<String> divisions = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Sylhet',
    'Barisal',
    'Rangpur',
    'Mymensingh',
  ];

  static const List<String> districts = [
    'Dhaka',
    'Gazipur',
    'Narayanganj',
    'Tangail',
    'Manikganj',
    'Munshiganj',
    'Narsingdi',
    'Faridpur',
  ];

  static const List<String> upazilas = [
    'Dhanmondi',
    'Gulshan',
    'Banani',
    'Mohammadpur',
    'Mirpur',
    'Uttara',
    'Badda',
    'Khilgaon',
  ];

  static const List<String> pouroshovas = [
    'Dhaka South City Corporation',
    'Dhaka North City Corporation',
    'Gazipur City Corporation',
    'Narayanganj City Corporation',
  ];

  static const List<String> wardNos = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Division
        _buildDropdown(
          label: 'Division',
          isRequired: true,
          value: location.division,
          items: divisions,
          hint: 'Select your division',
          onChanged: (value) {
            onChanged(LocationData(division: value));
          },
        ),
        SizedBox(height: 16.h),

        // District
        _buildDropdown(
          label: 'District',
          isRequired: true,
          value: location.district,
          items: districts,
          hint: 'Select your district',
          onChanged: (value) {
            onChanged(
              location.copyWith(
                district: value,
                upazila: null,
                pouroshova: null,
                wardNo: null,
              ),
            );
          },
        ),
        SizedBox(height: 16.h),

        // Upazila
        _buildDropdown(
          label: 'Upazila',
          isRequired: true,
          value: location.upazila,
          items: upazilas,
          hint: 'Select your upazila',
          onChanged: (value) {
            onChanged(
              location.copyWith(upazila: value, pouroshova: null, wardNo: null),
            );
          },
        ),
        SizedBox(height: 16.h),

        // Pouroshova/City Corp/Union
        _buildDropdown(
          label: 'Pouroshova/City Corp/Union',
          isRequired: true,
          value: location.pouroshova,
          items: pouroshovas,
          hint: 'Select your Pouroshova/City Corp',
          onChanged: (value) {
            onChanged(location.copyWith(pouroshova: value, wardNo: null));
          },
        ),
        SizedBox(height: 16.h),

        // Ward No
        _buildDropdown(
          label: 'Ward No',
          isRequired: false,
          value: location.wardNo,
          items: wardNos,
          hint: 'Select Ward No',
          onChanged: (value) {
            onChanged(location.copyWith(wardNo: value));
          },
        ),
        SizedBox(height: 16.h),

        // Postal Code
        _buildTextField(
          label: 'Postal Code',
          isRequired: false,
          value: location.postalCode ?? '',
          hint: 'Enter Postal Code',
          onChanged: (value) {
            onChanged(location.copyWith(postalCode: value));
          },
        ),

        if (showFullAddress) ...[
          SizedBox(height: 16.h),

          // Full Address
          _buildTextField(
            label: 'Full Address',
            isRequired: true,
            value: location.fullAddress ?? '',
            hint:
                'Holding ###, Ward #10, Bogura Pourashava, Bogura Sadar, Bogura-5800, Rajshahi',
            onChanged: (value) {
              onChanged(location.copyWith(fullAddress: value));
            },
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required bool isRequired,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(fontSize: 16.sp, color: AppColors.grey400),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
              style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
              items: items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
