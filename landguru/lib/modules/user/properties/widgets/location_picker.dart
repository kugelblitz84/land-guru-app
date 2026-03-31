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
  final bool? isFullAddressCustomized;

  const LocationData({
    this.division,
    this.district,
    this.upazila,
    this.pouroshova,
    this.wardNo,
    this.postalCode,
    this.fullAddress,
    this.isFullAddressCustomized,
  });

  LocationData copyWith({
    String? division,
    String? district,
    String? upazila,
    String? pouroshova,
    String? wardNo,
    String? postalCode,
    String? fullAddress,
    bool? isFullAddressCustomized,
  }) {
    return LocationData(
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      pouroshova: pouroshova ?? this.pouroshova,
      wardNo: wardNo ?? this.wardNo,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      isFullAddressCustomized:
          isFullAddressCustomized ?? this.isFullAddressCustomized,
    );
  }

  /// Generate default address from location components
  String get generatedAddress {
    final parts = <String>[];
    if (wardNo != null && wardNo!.isNotEmpty) {
      parts.add('Ward No. $wardNo');
    }
    if (pouroshova != null && pouroshova!.isNotEmpty) {
      parts.add(pouroshova!);
    }
    if (upazila != null && upazila!.isNotEmpty) {
      parts.add(upazila!);
    }
    if (district != null && district!.isNotEmpty) {
      parts.add(district!);
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    if (division != null && division!.isNotEmpty) {
      parts.add(division!);
    }
    return parts.join(', ');
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
class LocationPicker extends StatefulWidget {
  final LocationData location;
  final ValueChanged<LocationData> onChanged;
  final bool showFullAddress;

  const LocationPicker({
    super.key,
    required this.location,
    required this.onChanged,
    this.showFullAddress = true,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late TextEditingController _fullAddressController;
  late TextEditingController _postalCodeController;
  bool _isUserEditing = false;

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
  void initState() {
    super.initState();
    _fullAddressController = TextEditingController(
      text: widget.location.fullAddress ?? widget.location.generatedAddress,
    );
    _postalCodeController = TextEditingController(
      text: widget.location.postalCode ?? '',
    );
  }

  @override
  void didUpdateWidget(LocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update postal code controller if changed externally
    if (widget.location.postalCode != oldWidget.location.postalCode) {
      _postalCodeController.text = widget.location.postalCode ?? '';
    }
    // Auto-update full address if location fields changed and user hasn't customized
    if (!_isUserEditing && widget.location.isFullAddressCustomized != true) {
      final newGeneratedAddress = widget.location.generatedAddress;
      if (newGeneratedAddress.isNotEmpty &&
          _fullAddressController.text != newGeneratedAddress &&
          _fullAddressController.text == oldWidget.location.generatedAddress) {
        _fullAddressController.text = newGeneratedAddress;
      }
    }
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _updateLocationAndAddress(LocationData newLocation) {
    // Generate address from location components
    final generatedAddress = newLocation.generatedAddress;

    // If user hasn't customized the address, auto-populate
    if (widget.location.isFullAddressCustomized != true) {
      _fullAddressController.text = generatedAddress;
    }

    widget.onChanged(
      newLocation.copyWith(fullAddress: _fullAddressController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Division
        _buildDropdown(
          label: 'Division',
          isRequired: true,
          value: widget.location.division,
          items: divisions,
          hint: 'Select your division',
          onChanged: (value) {
            _updateLocationAndAddress(LocationData(division: value));
          },
        ),
        SizedBox(height: 16.h),

        // District
        _buildDropdown(
          label: 'District',
          isRequired: true,
          value: widget.location.district,
          items: districts,
          hint: 'Select your district',
          onChanged: (value) {
            _updateLocationAndAddress(
              widget.location.copyWith(
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
          value: widget.location.upazila,
          items: upazilas,
          hint: 'Select your upazila',
          onChanged: (value) {
            _updateLocationAndAddress(
              widget.location.copyWith(
                upazila: value,
                pouroshova: null,
                wardNo: null,
              ),
            );
          },
        ),
        SizedBox(height: 16.h),

        // Pouroshova/City Corp/Union
        _buildDropdown(
          label: 'Pouroshova/City Corp/Union',
          isRequired: true,
          value: widget.location.pouroshova,
          items: pouroshovas,
          hint: 'Select your Pouroshova/City Corp',
          onChanged: (value) {
            _updateLocationAndAddress(
              widget.location.copyWith(pouroshova: value, wardNo: null),
            );
          },
        ),
        SizedBox(height: 16.h),

        // Ward No
        _buildDropdown(
          label: 'Ward No',
          isRequired: true,
          value: widget.location.wardNo,
          items: wardNos,
          hint: 'Select Ward No',
          onChanged: (value) {
            _updateLocationAndAddress(widget.location.copyWith(wardNo: value));
          },
        ),
        SizedBox(height: 16.h),

        // Postal Code
        _buildPostalCodeField(),

        if (widget.showFullAddress) ...[
          SizedBox(height: 16.h),

          // Full Address
          _buildFullAddressField(),
        ],
      ],
    );
  }

  Widget _buildPostalCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Postal Code',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _postalCodeController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Postal Code is required';
            }
            return null;
          },
          onChanged: (value) {
            _updateLocationAndAddress(
              widget.location.copyWith(postalCode: value),
            );
          },
          style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText: 'Enter Postal Code',
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

  Widget _buildFullAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Full Address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _fullAddressController,
          maxLines: 2,
          onTap: () {
            _isUserEditing = true;
          },
          onChanged: (value) {
            widget.onChanged(
              widget.location.copyWith(
                fullAddress: value,
                isFullAddressCustomized: true,
              ),
            );
          },
          style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText:
                'Holding ###, Ward #10, Bogura Pourashava, Bogura Sadar, Bogura-5800, Rajshahi',
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
}
