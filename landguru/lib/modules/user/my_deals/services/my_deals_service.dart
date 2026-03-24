import 'package:get/get.dart';

import '../../../../core/enums/property_type.dart';
import '../../../../core/services/api_client.dart';
import '../models/deal_models.dart';
import '../models/payloads/my_deals_payload_models.dart';

class MyDealsService extends GetxService {
  MyDealsService(this._apiClient);

  final ApiClient _apiClient;

  Future<DealStats> getMySoldSummary() async {
    final response = await _apiClient.get('/sell-posts/my-sold/summary');
    final payload = _asMap(response.data);
    final stats = _asMap(payload['stats']);

    return DealStats.fromMap(<String, dynamic>{
      'propertySold': _toInt(stats['totalSold']) ?? 0,
      'totalEarned': _formatPrice(stats['totalEarned']),
    });
  }

  Future<DealStats> getMyBoughtSummary() async {
    final response = await _apiClient.get('/buy-posts/my-bought/summary');
    final payload = _asMap(response.data);
    final stats = _asMap(payload['stats']);

    return DealStats.fromMap(<String, dynamic>{
      'propertyBought': _toInt(stats['totalBought']) ?? 0,
      'totalSpent': _formatPrice(stats['totalSpent']),
    });
  }

  Future<MyDealsListResponse> getMySoldDeals({
    required MyDealsSoldListPayload payload,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/my-sold',
      queryParameters: payload.toMap(),
    );

    final root = _asMap(response.data);
    final data = root['data'];
    final meta = _asMap(root['meta']);

    final deals = data is List
        ? data
              .whereType<Map>()
              .map(
                (item) => _mapSoldDealListItem(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <Deal>[];

    return MyDealsListResponse(
      deals: deals,
      total: _toInt(meta['total']) ?? deals.length,
      page: _toInt(meta['page']) ?? payload.page,
      limit: _toInt(meta['limit']) ?? payload.limit,
      totalPages: _toInt(meta['totalPages']) ?? 1,
    );
  }

  Future<MyDealsListResponse> getMyBoughtDeals({
    required MyDealsBoughtListPayload payload,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/my-bought',
      queryParameters: payload.toMap(),
    );

    final root = _asMap(response.data);
    final data = root['data'];
    final meta = _asMap(root['meta']);

    final deals = data is List
        ? data
              .whereType<Map>()
              .map(
                (item) =>
                    _mapBoughtDealListItem(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <Deal>[];

    return MyDealsListResponse(
      deals: deals,
      total: _toInt(meta['total']) ?? deals.length,
      page: _toInt(meta['page']) ?? payload.page,
      limit: _toInt(meta['limit']) ?? payload.limit,
      totalPages: _toInt(meta['totalPages']) ?? 1,
    );
  }

  Future<Deal> getMyBoughtDealDetails({
    required MyBoughtDealDetailsPayload payload,
  }) async {
    final response = await _apiClient.get(
      '/buy-posts/my-bought/${payload.dealId}/details',
    );

    final root = _asMap(response.data);
    final data = _asMap(root['data']);
    final transaction = _asMap(data['transaction']);
    final seller = _asMap(data['seller']);
    final property = _asMap(data['property']);
    final address = _asMap(property['address']);
    final documents = _asMap(data['documents']);

    final propertyId = _toText(property['id']) ?? payload.dealId;
    final finalDealAmount = _formatPrice(transaction['finalDealAmount']);

    return Deal.fromMap(<String, dynamic>{
      'id': propertyId,
      'postId': _resolvePostId(propertyId),
      'propertyTitle': _toText(property['title']) ?? 'Untitled Property',
      'propertyImageUrl': _readPrimaryPhoto(property['photos']),
      'propertyType': _mapPropertyType(property['propertyType']).name,
      'location': _composeLocation(address),
      'soldPrice': finalDealAmount,
      'status': DealStatuses.bought,
      'dealDate': (_toDateTime(transaction['boughtAt']) ?? DateTime.now())
          .toIso8601String(),
      'description': _toText(property['description']),
      'soldLandAmount': _formatLand(
        property['sellableAmount'],
        property['sellableUnit'],
      ),
      'plotSize': _formatLand(property['plotSize'], property['plotUnit']),
      'distanceFromRoad': _formatDistance(
        property['roadDistanceMin'],
        property['roadDistanceMax'],
      ),
      'propertyPhotos': _toTextList(property['photos']),
      'otherPartyId': _toText(seller['id']),
      'otherPartyName': _toText(seller['fullName']) ?? 'Unknown Seller',
      'otherPartyAvatar': _toText(seller['photoUrl']),
      'otherPartyVerified': true,
      'hasHideDueDiligence': true,
      'hasPropertyVideo': _toText(documents['video']) != null,
      'hasOwnershipHistory': _toList(data['ownershipHistory']).isNotEmpty,
      'propertyVideoUrl': _toText(documents['video']),
      'deedDocuments': _mapDocUrls(
        _toList(documents['deed']),
        'deed',
      )?.map((doc) => doc.toMap()).toList(),
      'khatianDocuments': _mapDocUrls(
        _toList(documents['khatian']),
        'khatian',
      )?.map((doc) => doc.toMap()).toList(),
      'porchagophMapDocuments': _mapDocUrls(
        _toList(documents['pentagraphMap']),
        'pentagraph',
      )?.map((doc) => doc.toMap()).toList(),
      'servicesTaken': _mapServices(
        _toList(data['servicesTaken']),
      )?.map((service) => service.toMap()).toList(),
    });
  }

  Future<Deal> getMySoldDealDetails({
    required MySoldDealDetailsPayload payload,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/my-sold/${payload.soldPostId}/details',
    );

    final root = _asMap(response.data);
    final data = _asMap(root['data']);
    final buyers = _toList(data['buyers']);
    final documents = _asMap(data['documents']);

    final soldPostId = _toText(data['id']) ?? payload.soldPostId;
    final allBuyers = _mapParticipants(buyers);
    final primaryBuyer = allBuyers?.isNotEmpty == true
        ? allBuyers!.first
        : null;

    return Deal.fromMap(<String, dynamic>{
      'id': soldPostId,
      'postId': _resolvePostId(soldPostId),
      'propertyTitle': _toText(data['title']) ?? 'Untitled Property',
      'propertyImageUrl': _readPrimaryPhoto(data['photos']),
      'propertyType': _mapPropertyType(data['propertyType']).name,
      'location': _toText(data['location']) ?? 'Location not specified',
      'soldPrice': _formatPrice(data['totalDealAmount']),
      'status': DealStatuses.sold,
      'dealDate': (_toDateTime(data['lastSoldDate']) ?? DateTime.now())
          .toIso8601String(),
      'soldLandAmount': _formatLand(
        data['sellableLandAmount'],
        data['sellableUnit'],
      ),
      'plotSize': _formatLand(data['plotSize'], data['plotUnit']),
      'distanceFromRoad': _toText(data['distanceFromRoad']) ?? 'Not specified',
      'propertyPhotos': _toTextList(data['photos']),
      'buyersCount': _toInt(data['buyersCount']),
      'buyers': allBuyers?.map((buyer) => buyer.toMap()).toList(),
      'otherPartyId': primaryBuyer?.id,
      'otherPartyName': primaryBuyer?.name ?? 'Unknown Buyer',
      'otherPartyAvatar': primaryBuyer?.photoUrl,
      'otherPartyVerified': primaryBuyer?.isVerified ?? false,
      'hasHideDueDiligence': _toList(data['riskChecklist']).isNotEmpty,
      'hasPropertyVideo': _toText(data['videoUrl']) != null,
      'hasOwnershipHistory': _toList(data['ownershipHistory']).isNotEmpty,
      'propertyVideoUrl': _toText(data['videoUrl']),
      'riskChecklist': _mapRiskChecklist(
        _toList(data['riskChecklist']),
      )?.map((item) => item.toMap()).toList(),
      'ownershipHistory': _mapOwnershipHistory(
        _toList(data['ownershipHistory']),
      )?.map((record) => record.toMap()).toList(),
      'deedDocuments': _mapDocUrls(
        _toList(documents['deed']),
        'deed',
      )?.map((doc) => doc.toMap()).toList(),
      'khatianDocuments': _mapDocUrls(
        _toList(documents['khatian']),
        'khatian',
      )?.map((doc) => doc.toMap()).toList(),
      'porchagophMapDocuments': _mapDocUrls(
        _toList(documents['map']),
        'map',
      )?.map((doc) => doc.toMap()).toList(),
      'otherDocuments': _mapDocUrls(
        _toList(documents['other']),
        'other',
      )?.map((doc) => doc.toMap()).toList(),
      'servicesTaken': _mapServices(
        _toList(data['servicesTaken']),
      )?.map((service) => service.toMap()).toList(),
    });
  }

  Future<ResellSubmissionResult> resellBoughtDeal({
    required MyBoughtResellPayload payload,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/my-bought/${payload.dealId}/resell',
      data: payload.toMap(),
    );

    final root = _asMap(response.data);
    final rawData = root['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return ResellSubmissionResult(
      success: root['success'] == true,
      message:
          _toText(root['message']) ?? 'Resell request submitted successfully',
      postId: _toText(data['postId']),
      title: _toText(data['title']),
      isResell: data['isResell'] == true,
      status: _toText(data['status']),
      askingPrice: _toInt(data['askingPrice']),
      propertyType: _toText(data['propertyType']),
      image: _toText(data['image']),
    );
  }

  Deal _mapSoldDealListItem(Map<String, dynamic> json) {
    final id = _toText(json['id']) ?? '';
    return Deal.fromMap(<String, dynamic>{
      'id': id,
      'postId': _resolvePostId(id),
      'propertyTitle': _toText(json['title']) ?? 'Untitled Property',
      'propertyImageUrl': _toText(json['image']),
      'propertyType': _mapPropertyType(json['type']).name,
      'location': 'Location not specified',
      'soldPrice': _formatPrice(json['price']),
      'status': DealStatuses.sold,
      'dealDate': (_toDateTime(json['soldAt']) ?? DateTime.now())
          .toIso8601String(),
      'otherPartyName': 'Unknown Buyer',
    });
  }

  Deal _mapBoughtDealListItem(Map<String, dynamic> json) {
    final id = _toText(json['id']) ?? '';
    return Deal.fromMap(<String, dynamic>{
      'id': id,
      'postId': _resolvePostId(id),
      'propertyTitle': _toText(json['title']) ?? 'Untitled Property',
      'propertyImageUrl': _toText(json['image']),
      'propertyType': _mapPropertyType(json['type']).name,
      'location': 'Location not specified',
      'soldPrice': _formatPrice(json['boughtPrice']),
      'status': DealStatuses.bought,
      'dealDate': (_toDateTime(json['boughtAt']) ?? DateTime.now())
          .toIso8601String(),
      'otherPartyName': 'Unknown Seller',
    });
  }

  PropertyType _mapPropertyType(dynamic rawType) {
    final normalized = (rawType?.toString() ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'plain land':
      case 'plainland':
      case 'plot':
      case 'land':
        return PropertyType.plainLand;
      case 'water land':
      case 'waterland':
      case 'water':
        return PropertyType.waterLand;
      case 'house':
      case 'duplex':
      case 'flat':
      default:
        return PropertyType.flat;
    }
  }

  String _formatPrice(dynamic value) {
    final numeric = value is num
        ? value
        : num.tryParse(value?.toString().replaceAll(',', '') ?? '');
    if (numeric == null) {
      final text = value?.toString().trim();
      return (text == null || text.isEmpty) ? '0' : text;
    }

    final source = numeric.toStringAsFixed(0);
    return source.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  String _formatLand(dynamic amount, dynamic unit) {
    final amountText = _toText(amount);
    if (amountText == null || amountText.isEmpty) {
      return 'Not specified';
    }

    final unitText = _toText(unit);
    if (unitText == null || unitText.isEmpty) {
      return amountText;
    }

    return '$amountText $unitText';
  }

  String _formatDistance(dynamic min, dynamic max) {
    final minText = _toText(min);
    final maxText = _toText(max);

    if (minText != null && maxText != null) {
      return '${minText}m-${maxText}m';
    }
    if (minText != null) {
      return '${minText}m';
    }
    if (maxText != null) {
      return '${maxText}m';
    }
    return 'Not specified';
  }

  String _composeLocation(Map<String, dynamic> address) {
    final parts = <String>[
      _toText(address['fullAddress']) ?? '',
      _toText(address['upazila']) ?? '',
      _toText(address['district']) ?? '',
      _toText(address['division']) ?? '',
      _toText(address['postalCode']) ?? '',
    ].where((part) => part.trim().isNotEmpty).toList(growable: false);

    if (parts.isEmpty) {
      return 'Location not specified';
    }
    return parts.join(', ');
  }

  List<LegalDocument>? _mapDocUrls(List<dynamic> urls, String prefix) {
    if (urls.isEmpty) {
      return null;
    }

    final docs = <LegalDocument>[];
    for (var i = 0; i < urls.length; i++) {
      final url = _toText(urls[i]);
      if (url == null) {
        continue;
      }
      final name = _fileNameFromUrl(url);
      final fileType = _fileTypeFromName(name);
      docs.add(
        LegalDocument(
          id: '$prefix-$i',
          name: name,
          fileUrl: url,
          fileType: fileType,
        ),
      );
    }
    return docs.isEmpty ? null : docs;
  }

  List<ServiceTaken>? _mapServices(List<dynamic> list) {
    if (list.isEmpty) {
      return null;
    }

    final services = <ServiceTaken>[];
    for (final item in list.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final agent = map['agent'] is Map
          ? Map<String, dynamic>.from(map['agent'] as Map)
          : <String, dynamic>{};
      services.add(
        ServiceTaken(
          id: _toText(map['id']) ?? '',
          serviceName: _toText(map['serviceName']) ?? 'Service',
          agentName: _toText(map['agentName']) ?? _toText(agent['name']),
          agentAvatar: _toText(map['agentPhoto']) ?? _toText(agent['photo']),
          agentRole: _toText(map['agentRole']) ?? _toText(agent['role']),
          status: _toText(map['status']) ?? 'PENDING',
        ),
      );
    }

    return services.isEmpty ? null : services;
  }

  String? _readPrimaryPhoto(dynamic photos) {
    final list = _toTextList(photos);
    if (list == null || list.isEmpty) {
      return null;
    }
    return list.first;
  }

  String _resolvePostId(String id) {
    final clean = id.trim();
    if (clean.isEmpty) {
      return '#POST';
    }
    final short = clean.length > 8 ? clean.substring(0, 8) : clean;
    return '#POST-${short.toUpperCase()}';
  }

  String _fileNameFromUrl(String url) {
    final clean = url.trim();
    if (clean.isEmpty) {
      return 'document';
    }
    final withoutQuery = clean.split('?').first;
    final segments = withoutQuery.split('/');
    final last = segments.isNotEmpty ? segments.last : 'document';
    return last.isEmpty ? 'document' : last;
  }

  String _fileTypeFromName(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index < 0 || index == fileName.length - 1) {
      return 'file';
    }
    return fileName.substring(index + 1).toLowerCase();
  }

  List<DealParticipant>? _mapParticipants(List<dynamic> list) {
    if (list.isEmpty) {
      return null;
    }

    final participants = <DealParticipant>[];
    for (final item in list.whereType<Map>()) {
      participants.add(
        DealParticipant.fromMap(Map<String, dynamic>.from(item)),
      );
    }

    return participants.isEmpty ? null : participants;
  }

  List<RiskChecklistItem>? _mapRiskChecklist(List<dynamic> list) {
    if (list.isEmpty) {
      return null;
    }

    final checklist = <RiskChecklistItem>[];
    for (final item in list.whereType<Map>()) {
      checklist.add(RiskChecklistItem.fromMap(Map<String, dynamic>.from(item)));
    }

    return checklist.isEmpty ? null : checklist;
  }

  List<OwnershipHistoryRecord>? _mapOwnershipHistory(List<dynamic> list) {
    if (list.isEmpty) {
      return null;
    }

    final history = <OwnershipHistoryRecord>[];
    for (final item in list.whereType<Map>()) {
      history.add(
        OwnershipHistoryRecord.fromMap(Map<String, dynamic>.from(item)),
      );
    }

    return history.isEmpty ? null : history;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw Exception('Invalid response');
  }

  List<dynamic> _toList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
  }

  String? _toText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  DateTime? _toDateTime(dynamic value) {
    final text = _toText(value);
    if (text == null) {
      return null;
    }
    return DateTime.tryParse(text)?.toLocal();
  }

  List<String>? _toTextList(dynamic value) {
    if (value is! List) {
      return null;
    }
    final list = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return list.isEmpty ? null : list;
  }
}

class MyDealsListResponse {
  const MyDealsListResponse({
    required this.deals,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<Deal> deals;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

class ResellSubmissionResult {
  const ResellSubmissionResult({
    required this.success,
    required this.message,
    this.postId,
    this.title,
    this.isResell,
    this.status,
    this.askingPrice,
    this.propertyType,
    this.image,
  });

  final bool success;
  final String message;
  final String? postId;
  final String? title;
  final bool? isResell;
  final String? status;
  final int? askingPrice;
  final String? propertyType;
  final String? image;
}
