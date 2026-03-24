import 'package:flutter/material.dart';
import '../../../../core/enums/property_type.dart';
import '../../../../core/theme/app_colors.dart';

/// Tab enum for Sold/Bought
class DealTabs {
  static const String sold = 'sold';
  static const String bought = 'bought';
}

/// Deal status
class DealStatuses {
  static const String sold = 'sold';
  static const String bought = 'bought';

  static String label(String status) {
    switch (status) {
      case sold:
        return 'Sold';
      case bought:
        return 'Bought';
      default:
        return 'Unknown';
    }
  }

  static Color backgroundColor(String status) {
    return AppColors.success;
  }

  static Color textColor(String status) {
    return AppColors.white;
  }
}

/// Sort options for deals
class DealSortOptions {
  static const String newest = 'newest';
  static const String oldest = 'oldest';
  static const String priceHighToLow = 'price_high_to_low';
  static const String priceLowToHigh = 'price_low_to_high';

  static const List<String> values = [
    newest,
    oldest,
    priceHighToLow,
    priceLowToHigh,
  ];

  static String label(String option) {
    switch (option) {
      case newest:
        return 'Newest';
      case oldest:
        return 'Oldest';
      case priceHighToLow:
        return 'Price: High to Low';
      case priceLowToHigh:
        return 'Price: Low to High';
      default:
        return 'Newest';
    }
  }
}

/// Filter by property type
class DealTypeFilters {
  static const String all = 'all';
  static const String flat = 'flat';
  static const String plainLand = 'plain_land';
  static const String waterLand = 'water_land';

  static const List<String> values = [all, flat, plainLand, waterLand];

  static String label(String filter) {
    switch (filter) {
      case all:
        return 'All';
      case flat:
        return 'Flat';
      case plainLand:
        return 'Plain Land';
      case waterLand:
        return 'Water Land';
      default:
        return 'All';
    }
  }
}

/// Deal model for sold/bought properties
class Deal {
  final String id;
  final String postId;
  final String propertyTitle;
  final String? propertyImageUrl;
  final PropertyType propertyType;
  final String location;
  final String soldPrice;
  final String status;
  final DateTime dealDate;
  final String? description;

  // Property details
  final String? soldLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final List<String>? propertyPhotos;

  // Buyer/Seller info (depending on if sold or bought)
  final String? otherPartyId;
  final String? otherPartyName;
  final String? otherPartyAvatar;
  final bool otherPartyVerified;
  final int? buyersCount;
  final List<DealParticipant>? buyers;

  // Unlocked features
  final bool hasHideDueDiligence;
  final bool hasPropertyVideo;
  final bool hasOwnershipHistory;
  final String? propertyVideoUrl;
  final List<RiskChecklistItem>? riskChecklist;
  final List<OwnershipHistoryRecord>? ownershipHistory;

  // Legal documents
  final List<LegalDocument>? deedDocuments;
  final List<LegalDocument>? khatianDocuments;
  final List<LegalDocument>? porchagophMapDocuments;
  final List<LegalDocument>? otherDocuments;

  // Services taken
  final List<ServiceTaken>? servicesTaken;

  const Deal({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    this.propertyImageUrl,
    required this.propertyType,
    required this.location,
    required this.soldPrice,
    required this.status,
    required this.dealDate,
    this.description,
    this.soldLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.propertyPhotos,
    this.otherPartyId,
    this.otherPartyName,
    this.otherPartyAvatar,
    this.otherPartyVerified = false,
    this.buyersCount,
    this.buyers,
    this.hasHideDueDiligence = false,
    this.hasPropertyVideo = false,
    this.hasOwnershipHistory = false,
    this.propertyVideoUrl,
    this.riskChecklist,
    this.ownershipHistory,
    this.deedDocuments,
    this.khatianDocuments,
    this.porchagophMapDocuments,
    this.otherDocuments,
    this.servicesTaken,
  });

  Deal copyWith({
    String? id,
    String? postId,
    String? propertyTitle,
    String? propertyImageUrl,
    PropertyType? propertyType,
    String? location,
    String? soldPrice,
    String? status,
    DateTime? dealDate,
    String? description,
    String? soldLandAmount,
    String? plotSize,
    String? distanceFromRoad,
    List<String>? propertyPhotos,
    String? otherPartyId,
    String? otherPartyName,
    String? otherPartyAvatar,
    bool? otherPartyVerified,
    int? buyersCount,
    List<DealParticipant>? buyers,
    bool? hasHideDueDiligence,
    bool? hasPropertyVideo,
    bool? hasOwnershipHistory,
    String? propertyVideoUrl,
    List<RiskChecklistItem>? riskChecklist,
    List<OwnershipHistoryRecord>? ownershipHistory,
    List<LegalDocument>? deedDocuments,
    List<LegalDocument>? khatianDocuments,
    List<LegalDocument>? porchagophMapDocuments,
    List<LegalDocument>? otherDocuments,
    List<ServiceTaken>? servicesTaken,
  }) {
    return Deal(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyImageUrl: propertyImageUrl ?? this.propertyImageUrl,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      soldPrice: soldPrice ?? this.soldPrice,
      status: status ?? this.status,
      dealDate: dealDate ?? this.dealDate,
      description: description ?? this.description,
      soldLandAmount: soldLandAmount ?? this.soldLandAmount,
      plotSize: plotSize ?? this.plotSize,
      distanceFromRoad: distanceFromRoad ?? this.distanceFromRoad,
      propertyPhotos: propertyPhotos ?? this.propertyPhotos,
      otherPartyId: otherPartyId ?? this.otherPartyId,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      otherPartyAvatar: otherPartyAvatar ?? this.otherPartyAvatar,
      otherPartyVerified: otherPartyVerified ?? this.otherPartyVerified,
      buyersCount: buyersCount ?? this.buyersCount,
      buyers: buyers ?? this.buyers,
      hasHideDueDiligence: hasHideDueDiligence ?? this.hasHideDueDiligence,
      hasPropertyVideo: hasPropertyVideo ?? this.hasPropertyVideo,
      hasOwnershipHistory: hasOwnershipHistory ?? this.hasOwnershipHistory,
      propertyVideoUrl: propertyVideoUrl ?? this.propertyVideoUrl,
      riskChecklist: riskChecklist ?? this.riskChecklist,
      ownershipHistory: ownershipHistory ?? this.ownershipHistory,
      deedDocuments: deedDocuments ?? this.deedDocuments,
      khatianDocuments: khatianDocuments ?? this.khatianDocuments,
      porchagophMapDocuments:
          porchagophMapDocuments ?? this.porchagophMapDocuments,
      otherDocuments: otherDocuments ?? this.otherDocuments,
      servicesTaken: servicesTaken ?? this.servicesTaken,
    );
  }

  factory Deal.fromMap(Map<String, dynamic> map) {
    return Deal(
      id: map['id']?.toString() ?? '',
      postId: map['postId']?.toString() ?? '',
      propertyTitle: map['propertyTitle']?.toString() ?? 'Untitled Property',
      propertyImageUrl: _textOrNull(map['propertyImageUrl']),
      propertyType: _mapPropertyType(map['propertyType']?.toString()),
      location: map['location']?.toString() ?? 'Location not specified',
      soldPrice: map['soldPrice']?.toString() ?? '0',
      status: map['status']?.toString() ?? DealStatuses.sold,
      dealDate:
          DateTime.tryParse(map['dealDate']?.toString() ?? '') ??
          DateTime.now(),
      description: _textOrNull(map['description']),
      soldLandAmount: _textOrNull(map['soldLandAmount']),
      plotSize: _textOrNull(map['plotSize']),
      distanceFromRoad: _textOrNull(map['distanceFromRoad']),
      propertyPhotos: _textListOrNull(map['propertyPhotos']),
      otherPartyId: _textOrNull(map['otherPartyId']),
      otherPartyName: _textOrNull(map['otherPartyName']),
      otherPartyAvatar: _textOrNull(map['otherPartyAvatar']),
      otherPartyVerified: map['otherPartyVerified'] == true,
      buyersCount: _toInt(map['buyersCount']),
      buyers: _participantsOrNull(map['buyers']),
      hasHideDueDiligence: map['hasHideDueDiligence'] == true,
      hasPropertyVideo: map['hasPropertyVideo'] == true,
      hasOwnershipHistory: map['hasOwnershipHistory'] == true,
      propertyVideoUrl: _textOrNull(map['propertyVideoUrl']),
      riskChecklist: _riskChecklistOrNull(map['riskChecklist']),
      ownershipHistory: _ownershipHistoryOrNull(map['ownershipHistory']),
      deedDocuments: _docsOrNull(map['deedDocuments']),
      khatianDocuments: _docsOrNull(map['khatianDocuments']),
      porchagophMapDocuments: _docsOrNull(map['porchagophMapDocuments']),
      otherDocuments: _docsOrNull(map['otherDocuments']),
      servicesTaken: _servicesOrNull(map['servicesTaken']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'propertyTitle': propertyTitle,
      'propertyImageUrl': propertyImageUrl,
      'propertyType': propertyType.name,
      'location': location,
      'soldPrice': soldPrice,
      'status': status,
      'dealDate': dealDate.toIso8601String(),
      'description': description,
      'soldLandAmount': soldLandAmount,
      'plotSize': plotSize,
      'distanceFromRoad': distanceFromRoad,
      'propertyPhotos': propertyPhotos,
      'otherPartyId': otherPartyId,
      'otherPartyName': otherPartyName,
      'otherPartyAvatar': otherPartyAvatar,
      'otherPartyVerified': otherPartyVerified,
      'buyersCount': buyersCount,
      'buyers': buyers?.map((party) => party.toMap()).toList(),
      'hasHideDueDiligence': hasHideDueDiligence,
      'hasPropertyVideo': hasPropertyVideo,
      'hasOwnershipHistory': hasOwnershipHistory,
      'propertyVideoUrl': propertyVideoUrl,
      'riskChecklist': riskChecklist?.map((item) => item.toMap()).toList(),
      'ownershipHistory': ownershipHistory
          ?.map((record) => record.toMap())
          .toList(),
      'deedDocuments': deedDocuments?.map((doc) => doc.toMap()).toList(),
      'khatianDocuments': khatianDocuments?.map((doc) => doc.toMap()).toList(),
      'porchagophMapDocuments': porchagophMapDocuments
          ?.map((doc) => doc.toMap())
          .toList(),
      'otherDocuments': otherDocuments?.map((doc) => doc.toMap()).toList(),
      'servicesTaken': servicesTaken
          ?.map((service) => service.toMap())
          .toList(),
    };
  }

  /// Get property type label
  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  /// Get property type color
  Color get propertyTypeColor {
    switch (propertyType) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32);
      case PropertyType.waterLand:
        return const Color(0xFF0288D1);
      case PropertyType.flat:
        return AppColors.primary;
    }
  }

  /// Get formatted deal time ago
  String get dealTimeAgo {
    final diff = DateTime.now().difference(dealDate);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Get "Sold To" or "Bought From" label
  String get otherPartyLabel =>
      status == DealStatuses.sold ? 'Sold To' : 'Bought From';
}

/// Legal document model
class LegalDocument {
  final String id;
  final String name;
  final String? fileUrl;
  final String fileType; // pdf, docx, etc.

  const LegalDocument({
    required this.id,
    required this.name,
    this.fileUrl,
    required this.fileType,
  });

  LegalDocument copyWith({
    String? id,
    String? name,
    String? fileUrl,
    String? fileType,
  }) {
    return LegalDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
    );
  }

  factory LegalDocument.fromMap(Map<String, dynamic> map) {
    return LegalDocument(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Document',
      fileUrl: _textOrNull(map['fileUrl']),
      fileType: map['fileType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'fileUrl': fileUrl,
      'fileType': fileType,
    };
  }
}

class DealParticipant {
  final String id;
  final String name;
  final String? photoUrl;
  final bool isVerified;
  final String role;
  final DateTime? boughtAt;
  final String? price;
  final String? soldAmount;
  final String? soldUnit;

  const DealParticipant({
    required this.id,
    required this.name,
    this.photoUrl,
    this.isVerified = false,
    this.role = 'Buyer',
    this.boughtAt,
    this.price,
    this.soldAmount,
    this.soldUnit,
  });

  factory DealParticipant.fromMap(Map<String, dynamic> map) {
    return DealParticipant(
      id: map['id']?.toString() ?? map['buyerId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Buyer',
      photoUrl: _textOrNull(map['photo']) ?? _textOrNull(map['photoUrl']),
      isVerified: map['isVerified'] == true,
      role: map['role']?.toString() ?? 'Buyer',
      boughtAt: DateTime.tryParse(map['boughtAt']?.toString() ?? ''),
      price: _textOrNull(map['price']),
      soldAmount: _textOrNull(map['soldAmount']),
      soldUnit: _textOrNull(map['soldUnit']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'photo': photoUrl,
      'isVerified': isVerified,
      'role': role,
      'boughtAt': boughtAt?.toIso8601String(),
      'price': price,
      'soldAmount': soldAmount,
      'soldUnit': soldUnit,
    };
  }
}

class RiskChecklistItem {
  final String label;
  final bool checked;

  const RiskChecklistItem({required this.label, required this.checked});

  factory RiskChecklistItem.fromMap(Map<String, dynamic> map) {
    return RiskChecklistItem(
      label: map['label']?.toString() ?? '',
      checked: map['checked'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'label': label, 'checked': checked};
  }
}

class OwnershipHistoryRecord {
  final String ownerName;
  final String duration;
  final bool isCurrent;

  const OwnershipHistoryRecord({
    required this.ownerName,
    required this.duration,
    required this.isCurrent,
  });

  factory OwnershipHistoryRecord.fromMap(Map<String, dynamic> map) {
    return OwnershipHistoryRecord(
      ownerName: map['ownerName']?.toString() ?? 'Unknown Owner',
      duration: map['duration']?.toString() ?? '',
      isCurrent: map['isCurrent'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownerName': ownerName,
      'duration': duration,
      'isCurrent': isCurrent,
    };
  }
}

/// Service taken model
class ServiceTaken {
  final String id;
  final String serviceName;
  final String? agentName;
  final String? agentAvatar;
  final String? agentRole;
  final String status; // Pending, Completed, etc.

  const ServiceTaken({
    required this.id,
    required this.serviceName,
    this.agentName,
    this.agentAvatar,
    this.agentRole,
    required this.status,
  });

  ServiceTaken copyWith({
    String? id,
    String? serviceName,
    String? agentName,
    String? agentAvatar,
    String? agentRole,
    String? status,
  }) {
    return ServiceTaken(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      agentName: agentName ?? this.agentName,
      agentAvatar: agentAvatar ?? this.agentAvatar,
      agentRole: agentRole ?? this.agentRole,
      status: status ?? this.status,
    );
  }

  factory ServiceTaken.fromMap(Map<String, dynamic> map) {
    return ServiceTaken(
      id: map['id']?.toString() ?? '',
      serviceName: map['serviceName']?.toString() ?? 'Service',
      agentName: _textOrNull(map['agentName']),
      agentAvatar: _textOrNull(map['agentAvatar']) ?? _textOrNull(map['photo']),
      agentRole: _textOrNull(map['agentRole']) ?? _textOrNull(map['role']),
      status: map['status']?.toString() ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serviceName': serviceName,
      'agentName': agentName,
      'agentAvatar': agentAvatar,
      'agentRole': agentRole,
      'status': status,
    };
  }
}

/// Stats for deals
class DealStats {
  final int propertySold;
  final String totalEarned;
  final int propertyBought;
  final String totalSpent;

  const DealStats({
    this.propertySold = 0,
    this.totalEarned = '0',
    this.propertyBought = 0,
    this.totalSpent = '0',
  });

  DealStats copyWith({
    int? propertySold,
    String? totalEarned,
    int? propertyBought,
    String? totalSpent,
  }) {
    return DealStats(
      propertySold: propertySold ?? this.propertySold,
      totalEarned: totalEarned ?? this.totalEarned,
      propertyBought: propertyBought ?? this.propertyBought,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  factory DealStats.fromMap(Map<String, dynamic> map) {
    return DealStats(
      propertySold: _toInt(map['propertySold']) ?? 0,
      totalEarned: map['totalEarned']?.toString() ?? '0',
      propertyBought: _toInt(map['propertyBought']) ?? 0,
      totalSpent: map['totalSpent']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'propertySold': propertySold,
      'totalEarned': totalEarned,
      'propertyBought': propertyBought,
      'totalSpent': totalSpent,
    };
  }
}

String? _textOrNull(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

List<String>? _textListOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

List<LegalDocument>? _docsOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .whereType<Map>()
      .map((item) => LegalDocument.fromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

List<ServiceTaken>? _servicesOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .whereType<Map>()
      .map((item) => ServiceTaken.fromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

List<DealParticipant>? _participantsOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .whereType<Map>()
      .map((item) => DealParticipant.fromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

List<RiskChecklistItem>? _riskChecklistOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .whereType<Map>()
      .map((item) => RiskChecklistItem.fromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

List<OwnershipHistoryRecord>? _ownershipHistoryOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final mapped = value
      .whereType<Map>()
      .map(
        (item) =>
            OwnershipHistoryRecord.fromMap(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
  return mapped.isEmpty ? null : mapped;
}

PropertyType _mapPropertyType(String? rawType) {
  final normalized = rawType?.trim().toLowerCase() ?? '';
  switch (normalized) {
    case 'plain land':
    case 'plainland':
    case 'land':
    case 'plot':
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

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
