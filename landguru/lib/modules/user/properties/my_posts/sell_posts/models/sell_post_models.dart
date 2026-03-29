import '../../models/my_post_status.dart';

/// Extended model for Sell Post Details (includes all property info)
class SellPostDetails {
  final String id;
  final String postId;
  final String title;
  final String price;
  final MyPostStatus status;
  final bool isVerified;
  final String? imageUrl;
  final List<String> propertyPhotos;
  final String description;
  final String propertyType;
  final String sellableLandAmount;
  final String plotSize;
  final String? shareUnit; // Optional - only for properties with share units
  final String distanceFromRoad;
  final String location;
  final String timestamp;
  final String timestampPrefix;

  // Bill breakdown (for Quoted status)
  final BillBreakdown? billBreakdown;

  // Legal documents
  final List<LegalDocument> deedDocuments;
  final List<LegalDocument> khatianDocuments;

  // For Active status - verification services
  final List<ServiceVerificationItem>? servicesTaken;
  final List<OwnershipHistoryItem>? ownershipHistory;
  final List<DueDiligenceItem>? dueDiligenceChecklist;

  const SellPostDetails({
    required this.id,
    required this.postId,
    required this.title,
    required this.price,
    required this.status,
    this.isVerified = false,
    this.imageUrl,
    this.propertyPhotos = const [],
    required this.description,
    required this.propertyType,
    required this.sellableLandAmount,
    required this.plotSize,
    this.shareUnit,
    required this.distanceFromRoad,
    required this.location,
    required this.timestamp,
    required this.timestampPrefix,
    this.billBreakdown,
    this.deedDocuments = const [],
    this.khatianDocuments = const [],
    this.servicesTaken,
    this.ownershipHistory,
    this.dueDiligenceChecklist,
  });
}

/// Bill Breakdown model (for Quoted status)
class BillBreakdown {
  final List<ServiceFeeItem> mandatoryServices;
  final List<ServiceFeeItem> optionalServices;
  final double totalPayable;
  final double? lastRequoteAmount;
  final double? mandatoryServiceFees;
  final double? optionalServiceFees;
  final int quotationRevisions;

  const BillBreakdown({
    required this.mandatoryServices,
    required this.optionalServices,
    required this.totalPayable,
    this.lastRequoteAmount,
    this.mandatoryServiceFees,
    this.optionalServiceFees,
    this.quotationRevisions = 0,
  });

  double get mandatoryTotal =>
      mandatoryServices.fold(0.0, (sum, item) => sum + item.fee);

  double get optionalTotal =>
      optionalServices.fold(0.0, (sum, item) => sum + item.fee);
}

/// Service Fee Item for bill breakdown
class ServiceFeeItem {
  final String name;
  final double fee;
  final bool isSelected;

  const ServiceFeeItem({
    required this.name,
    required this.fee,
    this.isSelected = true,
  });
}

/// Legal Document model
class LegalDocument {
  final String name;
  final String size;
  final String? iconType; // 'pdf', 'docx', etc.

  const LegalDocument({required this.name, required this.size, this.iconType});
}

/// Service Verification Item (for Active status)
class ServiceVerificationItem {
  final String serviceName;
  final String assignedAgent;
  final String agentRole;
  final String? agentImageUrl;
  final bool isVerified;

  const ServiceVerificationItem({
    required this.serviceName,
    required this.assignedAgent,
    required this.agentRole,
    this.agentImageUrl,
    this.isVerified = true,
  });
}

/// Ownership History Item
class OwnershipHistoryItem {
  final String name;
  final String period;
  final bool isCurrent;

  const OwnershipHistoryItem({
    required this.name,
    required this.period,
    this.isCurrent = false,
  });
}

/// Due Diligence Checklist Item
class DueDiligenceItem {
  final String title;
  final bool isPassed;

  const DueDiligenceItem({required this.title, this.isPassed = true});
}

class QuotePaymentMethod {
  final String code;
  final String name;

  const QuotePaymentMethod({required this.code, required this.name});

  factory QuotePaymentMethod.fromMap(Map<String, dynamic> map) {
    final code = map['code']?.toString().trim() ?? '';
    final name = map['name']?.toString().trim();

    return QuotePaymentMethod(
      code: code,
      name: (name == null || name.isEmpty) ? code : name,
    );
  }
}

class QuotePaymentSummary {
  final String postId;
  final String title;
  final String status;
  final double askingPrice;
  final double validatedPrice;
  final double mandatoryServiceFee;
  final double optionalServiceFee;
  final double totalPayable;
  final int quoteRevisedCount;
  final List<QuotePaymentMethod> paymentMethods;
  final Map<String, dynamic> raw;

  const QuotePaymentSummary({
    required this.postId,
    required this.title,
    required this.status,
    required this.askingPrice,
    required this.validatedPrice,
    required this.mandatoryServiceFee,
    required this.optionalServiceFee,
    required this.totalPayable,
    required this.quoteRevisedCount,
    required this.paymentMethods,
    required this.raw,
  });

  factory QuotePaymentSummary.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);

    return QuotePaymentSummary(
      postId: normalized['postId']?.toString() ?? '',
      title: normalized['title']?.toString() ?? '',
      status: normalized['status']?.toString() ?? '',
      askingPrice: _asDouble(normalized['askingPrice']),
      validatedPrice: _asDouble(normalized['validatedPrice']),
      mandatoryServiceFee: _asDouble(normalized['mandatoryServiceFee']),
      optionalServiceFee: _asDouble(normalized['optionalServiceFee']),
      totalPayable: _asDouble(normalized['totalPayable']),
      quoteRevisedCount: _asInt(normalized['quoteRevisedCount']),
      paymentMethods: _extractPaymentMethods(normalized['paymentMethods']),
      raw: normalized,
    );
  }

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final nested = payload['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      return payload;
    }

    if (payload is Map) {
      final nested = payload['data'];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      return Map<String, dynamic>.from(payload);
    }

    throw Exception('Invalid response');
  }

  static List<QuotePaymentMethod> _extractPaymentMethods(dynamic raw) {
    if (raw is! List) return <QuotePaymentMethod>[];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(QuotePaymentMethod.fromMap)
        .where((method) => method.code.isNotEmpty)
        .toList();
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
