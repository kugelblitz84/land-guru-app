import 'package:flutter/material.dart';

/// Offer status enum for land wanted posts
enum OfferStatus {
  none,
  pendingBuyerReview, // Waiting for buyer to accept/reject
  buyerAcceptedPendingAdmin, // Buyer accepted, waiting for admin review
  buyerAcceptedAppointment, // Buyer accepted, admin approved, appointment scheduled
  rejected;

  String get label {
    switch (this) {
      case OfferStatus.none:
        return '';
      case OfferStatus.pendingBuyerReview:
        return 'Pending Buyer Review';
      case OfferStatus.buyerAcceptedPendingAdmin:
        return 'Buyer accepted your offer';
      case OfferStatus.buyerAcceptedAppointment:
        return 'Buyer accepted your offer';
      case OfferStatus.rejected:
        return 'Offer Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OfferStatus.none:
        return const Color(0xFF9E9E9E);
      case OfferStatus.pendingBuyerReview:
        return const Color(0xFF9E9E9E);
      case OfferStatus.buyerAcceptedPendingAdmin:
        return const Color(0xFF4CAF50);
      case OfferStatus.buyerAcceptedAppointment:
        return const Color(0xFF4CAF50);
      case OfferStatus.rejected:
        return const Color(0xFFF44336);
    }
  }
}
