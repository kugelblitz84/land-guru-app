class CreateSellPostPayloadModel {
  const CreateSellPostPayloadModel({
    required this.title,
    required this.description,
    required this.propertyType,
    required this.sellableAmount,
    required this.sellableUnit,
    required this.askingPricePerUnit,
    required this.askingPrice,
    required this.isPropertyShareable,
    this.roadDistanceMin,
    this.roadDistanceMax,
    this.plotSize,
    this.plotUnit,
    this.shareAmount,
    this.shareUnit,
    this.division,
    this.district,
    this.upazila,
    this.unionOrCityCorp,
    this.wardNo,
    this.postalCode,
    this.fullAddress,
  });

  final String title;
  final String description;
  final String propertyType;
  final double sellableAmount;
  final String sellableUnit;
  final double askingPricePerUnit;
  final double askingPrice;
  final bool isPropertyShareable;
  final int? roadDistanceMin;
  final int? roadDistanceMax;
  final double? plotSize;
  final String? plotUnit;
  final double? shareAmount;
  final String? shareUnit;
  final String? division;
  final String? district;
  final String? upazila;
  final String? unionOrCityCorp;
  final String? wardNo;
  final String? postalCode;
  final String? fullAddress;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'propertyType': propertyType,
      'sellableAmount': sellableAmount,
      'sellableUnit': sellableUnit,
      // Keep legacy alias for older API validators.
      //'pricePerUnit': askingPricePerUnit,
      'askingPricePerUnit': askingPricePerUnit,
      'askingPrice': askingPrice,
      // Keep legacy alias for older API validators.
      //'isShareable': isPropertyShareable,
      'isPropertyShareable': isPropertyShareable,
      if (roadDistanceMin != null) 'roadDistanceMin': roadDistanceMin,
      if (roadDistanceMax != null) 'roadDistanceMax': roadDistanceMax,
      if (plotSize != null) 'plotSize': plotSize,
      if (plotUnit != null && plotUnit!.trim().isNotEmpty) 'plotUnit': plotUnit,
      if (shareAmount != null) 'shareAmount': shareAmount,
      if (shareUnit != null && shareUnit!.trim().isNotEmpty)
        'shareUnit': shareUnit,
      if (division != null && division!.trim().isNotEmpty) 'division': division,
      if (district != null && district!.trim().isNotEmpty) 'district': district,
      if (upazila != null && upazila!.trim().isNotEmpty) 'upazila': upazila,
      if (unionOrCityCorp != null && unionOrCityCorp!.trim().isNotEmpty)
        'unionOrCityCorp': unionOrCityCorp,
      if (wardNo != null && wardNo!.trim().isNotEmpty) 'wardNo': wardNo,
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        'postalCode': postalCode,
      if (fullAddress != null && fullAddress!.trim().isNotEmpty)
        'fullAddress': fullAddress,
    };
  }
}

class CreateSellPostStepPayload {
  const CreateSellPostStepPayload({required this.data});

  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}
