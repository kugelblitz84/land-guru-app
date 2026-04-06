class UnlockPaymentMethod {
  const UnlockPaymentMethod({required this.code, required this.name});

  final String code;
  final String name;

  factory UnlockPaymentMethod.fromMap(Map<String, dynamic> map) {
    final code = map['code']?.toString().trim() ?? '';
    final name = map['name']?.toString().trim() ?? '';

    return UnlockPaymentMethod(code: code, name: name.isEmpty ? code : name);
  }
}

class UnlockFeaturesSummary {
  const UnlockFeaturesSummary({
    required this.userId,
    required this.isLimited,
    required this.unlockFeaturesAmount,
    required this.paymentMethods,
    required this.raw,
  });

  final String userId;
  final bool isLimited;
  final double unlockFeaturesAmount;
  final List<UnlockPaymentMethod> paymentMethods;
  final Map<String, dynamic> raw;

  factory UnlockFeaturesSummary.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);

    return UnlockFeaturesSummary(
      userId: normalized['userId']?.toString() ?? '',
      isLimited: normalized['isLimited'] == true,
      unlockFeaturesAmount: _toDouble(normalized['unlockFeaturesAmount']),
      paymentMethods: _toPaymentMethods(normalized['paymentMethods']),
      raw: normalized,
    );
  }

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return payload;
    }

    if (payload is Map) {
      final data = payload['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return Map<String, dynamic>.from(payload);
    }

    throw Exception('Invalid response');
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<UnlockPaymentMethod> _toPaymentMethods(dynamic value) {
    if (value is! List) {
      return const <UnlockPaymentMethod>[];
    }

    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .map(UnlockPaymentMethod.fromMap)
        .where((method) => method.code.isNotEmpty)
        .toList();
  }
}

class UnlockFeaturesAccess {
  const UnlockFeaturesAccess({
    required this.id,
    required this.userId,
    required this.isLimited,
    required this.raw,
  });

  final String id;
  final String userId;
  final bool isLimited;
  final Map<String, dynamic> raw;

  factory UnlockFeaturesAccess.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);

    return UnlockFeaturesAccess(
      id: normalized['id']?.toString() ?? '',
      userId: normalized['userId']?.toString() ?? '',
      isLimited: normalized['isLimited'] == true,
      raw: normalized,
    );
  }

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return payload;
    }

    if (payload is Map) {
      final data = payload['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return Map<String, dynamic>.from(payload);
    }

    throw Exception('Invalid response');
  }
}
