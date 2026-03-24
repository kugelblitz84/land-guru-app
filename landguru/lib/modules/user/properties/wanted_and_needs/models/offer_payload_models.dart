class MakeOfferFromExistingPayload {
  const MakeOfferFromExistingPayload({required this.sellPostId});

  final String sellPostId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'sellPostId': sellPostId};
  }
}

class CreateDraftOfferStep1Payload {
  const CreateDraftOfferStep1Payload({required this.data});

  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

class UpdateDraftOfferStep2Payload {
  const UpdateDraftOfferStep2Payload({required this.photos});

  final List<String> photos;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'photos': photos};
  }
}
