class DraftEntityResponse {
  const DraftEntityResponse({required this.raw, this.id});

  final Map<String, dynamic> raw;
  final String? id;

  factory DraftEntityResponse.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);

    final id =
        normalized['id']?.toString() ??
        normalized['offerId']?.toString() ??
        normalized['draftOfferId']?.toString() ??
        normalized['postId']?.toString();

    return DraftEntityResponse(raw: normalized, id: id);
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
}
