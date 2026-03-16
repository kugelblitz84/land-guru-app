class UpdateAgentProfilePayload {
  const UpdateAgentProfilePayload({
    required this.fullName,
    required this.email,
    required this.division,
    required this.district,
    required this.upazila,
    required this.unionOrCityCorp,
    required this.wardNo,
    required this.postalCode,
    required this.fullAddress,
    this.photoUrl,
  });

  final String fullName;
  final String email;
  final String division;
  final String district;
  final String upazila;
  final String unionOrCityCorp;
  final String wardNo;
  final String postalCode;
  final String fullAddress;
  final String? photoUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      if (division.isNotEmpty) 'division': division,
      if (district.isNotEmpty) 'district': district,
      if (upazila.isNotEmpty) 'upazila': upazila,
      if (unionOrCityCorp.isNotEmpty) 'unionOrCityCorp': unionOrCityCorp,
      if (wardNo.isNotEmpty) 'wardNo': wardNo,
      if (postalCode.isNotEmpty) 'postalCode': postalCode,
      if (fullAddress.isNotEmpty) 'fullAddress': fullAddress,
    };
  }
}

class UpdateAgentProfilePhotoPayload {
  const UpdateAgentProfilePhotoPayload({required this.photoUrl});

  final String photoUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'photoUrl': photoUrl};
  }
}
