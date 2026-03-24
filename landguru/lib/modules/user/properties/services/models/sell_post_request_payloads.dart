class UpdateSellPostPayload {
  const UpdateSellPostPayload({required this.data});

  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

class RequoteSellPostPayload {
  const RequoteSellPostPayload({
    required this.proposedMandatoryFee,
    required this.proposedOptionalFee,
  });

  final double proposedMandatoryFee;
  final double proposedOptionalFee;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'proposedMandatoryFee': proposedMandatoryFee,
      'proposedOptionalFee': proposedOptionalFee,
    };
  }
}

class RequestSellPostAppointmentPayload {
  const RequestSellPostAppointmentPayload({
    required this.sellPostId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
  });

  final String sellPostId;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sellPostId': sellPostId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
    };
  }
}
