class MyDealsSoldListPayload {
  const MyDealsSoldListPayload({
    this.page = 1,
    this.limit = 10,
    this.propertyType,
    this.sort = 'DESC',
  });

  final int page;
  final int limit;
  final String? propertyType;
  final String sort;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      if (propertyType != null && propertyType!.trim().isNotEmpty)
        'propertyType': propertyType,
      'sort': sort,
    };
  }
}

class MyDealsBoughtListPayload {
  const MyDealsBoughtListPayload({this.page = 1, this.limit = 10});

  final int page;
  final int limit;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'page': page, 'limit': limit};
  }
}

class MyBoughtDealDetailsPayload {
  const MyBoughtDealDetailsPayload({required this.dealId});

  final String dealId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': dealId};
  }
}

class MySoldDealDetailsPayload {
  const MySoldDealDetailsPayload({required this.soldPostId});

  final String soldPostId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': soldPostId};
  }
}

class MyBoughtResellPayload {
  const MyBoughtResellPayload({
    required this.dealId,
    required this.askingPrice,
    required this.askingPricePerUnit,
    required this.description,
  });

  final String dealId;
  final int askingPrice;
  final int askingPricePerUnit;
  final String description;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'askingPrice': askingPrice,
      'askingPricePerUnit': askingPricePerUnit,
      'description': description,
    };
  }
}
