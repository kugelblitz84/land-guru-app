import 'package:flutter/material.dart';
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
