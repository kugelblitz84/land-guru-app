/// Payment gateway status enum
enum PaymentGatewayStatus { success, failed, cancelled }

/// Result from payment gateway WebView
class PaymentGatewayResult {
  const PaymentGatewayResult({required this.status, this.redirectedUrl});

  final PaymentGatewayStatus status;
  final String? redirectedUrl;
}

/// SSLCommerz payment session response
class SslCommerzSession {
  const SslCommerzSession({
    required this.gatewayUrl,
    required this.raw,
    this.paymentId,
    this.sessionId,
    this.tranId,
    this.status,
  });

  final String gatewayUrl;
  final String? paymentId;
  final String? sessionId;
  final String? tranId;
  final String? status;
  final Map<String, dynamic> raw;

  factory SslCommerzSession.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);
    final gatewayUrl =
        normalized['gatewayUrl']?.toString() ??
        normalized['gateway_url']?.toString() ??
        normalized['GatewayPageURL']?.toString() ??
        normalized['redirectUrl']?.toString();

    if (gatewayUrl == null || gatewayUrl.isEmpty) {
      throw Exception('Missing payment gateway URL');
    }

    final sessionId =
        normalized['sessionId']?.toString() ??
        normalized['session_id']?.toString() ??
        normalized['sessionKey']?.toString();

    final tranId =
        normalized['tranId']?.toString() ?? normalized['tran_id']?.toString();

    final paymentId =
        normalized['paymentId']?.toString() ??
        normalized['payment_id']?.toString();

    final status = normalized['status']?.toString();

    return SslCommerzSession(
      gatewayUrl: gatewayUrl,
      paymentId: paymentId,
      sessionId: sessionId,
      tranId: tranId,
      status: status,
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
}

/// Payment session validation response
class PaymentSessionValidation {
  const PaymentSessionValidation({
    required this.status,
    required this.raw,
    this.paymentId,
    this.tranId,
  });

  final String status;
  final String? paymentId;
  final String? tranId;
  final Map<String, dynamic> raw;

  bool get isValidated {
    final normalized = status.toLowerCase();
    return normalized == 'validated' ||
        normalized == 'valid' ||
        normalized == 'success' ||
        normalized == 'completed';
  }

  factory PaymentSessionValidation.fromPayload(dynamic payload) {
    final normalized = _extractMap(payload);

    return PaymentSessionValidation(
      status: normalized['status']?.toString() ?? '',
      paymentId: normalized['paymentId']?.toString(),
      tranId: normalized['tranId']?.toString(),
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
}
