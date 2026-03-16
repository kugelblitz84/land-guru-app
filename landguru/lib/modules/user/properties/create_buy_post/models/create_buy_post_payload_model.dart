class CreateBuyPostPayloadModel {
  const CreateBuyPostPayloadModel({
    required this.title,
    required this.description,
    required this.propertyType,
    required this.landSizeMin,
    required this.landSizeUnit,
    required this.budgetMin,
    required this.budgetMax,
    this.plotSizeMin,
    this.plotSizeUnit,
    this.roadDistanceMin,
    this.roadDistanceMax,
    this.division,
    this.district,
    this.upazila,
    this.unionOrCityCorp,
    this.wardNo,
    this.postalCode,
  });

  final String title;
  final String description;
  final String propertyType;
  final double landSizeMin;
  final String landSizeUnit;
  final int budgetMin;
  final int budgetMax;
  final double? plotSizeMin;
  final String? plotSizeUnit;
  final int? roadDistanceMin;
  final int? roadDistanceMax;
  final String? division;
  final String? district;
  final String? upazila;
  final String? unionOrCityCorp;
  final String? wardNo;
  final String? postalCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'propertyType': propertyType,
      'landSizeMin': landSizeMin,
      'landSizeUnit': landSizeUnit,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      if (plotSizeMin != null) 'plotSizeMin': plotSizeMin,
      if (plotSizeUnit != null && plotSizeUnit!.trim().isNotEmpty)
        'plotSizeUnit': plotSizeUnit,
      if (roadDistanceMin != null) 'roadDistanceMin': roadDistanceMin,
      if (roadDistanceMax != null) 'roadDistanceMax': roadDistanceMax,
      if (division != null && division!.trim().isNotEmpty) 'division': division,
      if (district != null && district!.trim().isNotEmpty) 'district': district,
      if (upazila != null && upazila!.trim().isNotEmpty) 'upazila': upazila,
      if (unionOrCityCorp != null && unionOrCityCorp!.trim().isNotEmpty)
        'unionOrCityCorp': unionOrCityCorp,
      if (wardNo != null && wardNo!.trim().isNotEmpty) 'wardNo': wardNo,
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        'postalCode': postalCode,
    };
  }
}
