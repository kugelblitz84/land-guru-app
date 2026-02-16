import 'package:get/get.dart';

import '../../../../core/services/api_client.dart';

class SellPostDetailsService extends GetxService {
  SellPostDetailsService(this._apiClient);

  final ApiClient _apiClient;

  Future<SellPostDetailsPayload> getSellPostById(String postId) async {
    final response = await _apiClient.get('/sell-posts/$postId');

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    return SellPostDetailsPayload.fromJson(Map<String, dynamic>.from(payload));
  }

  Future<Map<String, dynamic>> updateSellPost({
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/$postId',
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    throw Exception('Invalid response');
  }

  Future<void> deleteSellPost(String postId) async {
    await _apiClient.delete('/sell-posts/$postId');
  }

  Future<Map<String, dynamic>> requoteSellPost({
    required String postId,
    required double proposedMandatoryFee,
    required double proposedOptionalFee,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/$postId/requote',
      data: {
        'proposedMandatoryFee': proposedMandatoryFee,
        'proposedOptionalFee': proposedOptionalFee,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    throw Exception('Invalid response');
  }

  Future<void> requestAppointment({
    required String sellPostId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
  }) async {
    await _apiClient.post(
      '/sell-posts/appointments/request',
      data: {
        'sellPostId': sellPostId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'buyerAddress': buyerAddress,
      },
    );
  }
}

class SellPostDetailsPayload {
  SellPostDetailsPayload({required this.raw});

  final Map<String, dynamic> raw;

  factory SellPostDetailsPayload.fromJson(Map<String, dynamic> json) {
    return SellPostDetailsPayload(raw: json);
  }

  String get id => raw['id']?.toString() ?? '';

  String get title => raw['title']?.toString() ?? 'Untitled Property';

  String get propertyTypeRaw => raw['propertyType']?.toString() ?? '';

  String get statusRaw => raw['status']?.toString() ?? '';

  bool get isVerified => raw['isVerified'] == true;

  String get description =>
      raw['description']?.toString() ?? 'No description available.';

  String get location =>
      raw['fullAddress']?.toString() ??
      raw['address']?.toString() ??
      'Location not specified';

  String get postId => raw['postId']?.toString().trim().isNotEmpty == true
      ? raw['postId'].toString()
      : _fallbackPostId(id);

  String get priceFormatted => _formatPrice(raw['askingPrice'] ?? raw['price']);

  String get sellableLandAmount =>
      _formatLand(raw['sellableAmount'], raw['sellableUnit']);

  String get plotSize => _formatLand(raw['plotSize'], raw['plotUnit']);

  String? get shareUnit {
    final amount = raw['shareAmount'];
    final unit = raw['shareUnit'];
    if (amount == null || unit == null) return null;
    final amountText = amount.toString().trim();
    final unitText = unit.toString().trim();
    if (amountText.isEmpty || unitText.isEmpty) return null;
    return '$amountText $unitText';
  }

  String get distanceFromRoad =>
      _formatDistance(raw['roadDistanceMin'], raw['roadDistanceMax']);

  int? get lastCompletedStep {
    final value = raw['lastCompletedStep'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? get videoUrl {
    final value = raw['videoUrl']?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  List<String> get photos {
    final list = raw['photos'];
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> get deedFiles {
    final list = raw['deedFiles'];
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> get khatianFiles {
    final list = raw['khatianFiles'];
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> get otherFiles {
    final list = raw['otherFiles'];
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> get selectedServices {
    final list = raw['selectedServices'];
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? get billBreakdown {
    final value = raw['billBreakdown'];
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  String get postedTime => _formatTimeAgo(
    raw['updatedAt']?.toString() ?? raw['createdAt']?.toString(),
  );

  String get sellerName {
    final seller = _seller;
    if (seller != null) {
      final name = _readString(seller, const ['name', 'fullName']);
      if (name != null) return name;
    }
    return _readString(raw, const ['postedBy', 'sellerName']) ??
        'Unknown Seller';
  }

  String? get sellerAvatarUrl {
    final seller = _seller;
    if (seller != null) {
      return _readString(seller, const ['avatar', 'image', 'photoUrl']);
    }
    return _readString(raw, const ['sellerAvatar', 'sellerImage', 'avatar']);
  }

  bool get sellerVerified {
    final seller = _seller;
    if (seller == null) return false;
    return seller['isVerified'] == true;
  }

  Map<String, dynamic>? get _seller {
    final value = raw['seller'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _fallbackPostId(String id) {
    if (id.isEmpty) return '#POST';
    final short = id.length > 8 ? id.substring(0, 8).toUpperCase() : id;
    return '#POST-$short';
  }

  static String _formatPrice(dynamic value) {
    if (value == null) return '0';

    final parsedNumber = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(',', ''));

    if (parsedNumber == null) {
      return value.toString();
    }

    final isInteger = parsedNumber == parsedNumber.roundToDouble();
    final base = isInteger
        ? parsedNumber.toInt().toString()
        : parsedNumber.toStringAsFixed(2);

    final parts = base.split('.');
    final intPart = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    if (parts.length == 1 || parts.last == '00') {
      return intPart;
    }

    return '$intPart.${parts.last}';
  }

  static String _formatLand(dynamic amount, dynamic unit) {
    if (amount == null || unit == null) return 'N/A';
    final amountText = amount.toString().trim();
    final unitText = unit.toString().trim();
    if (amountText.isEmpty || unitText.isEmpty) return 'N/A';
    return '$amountText $unitText';
  }

  static String _formatDistance(dynamic min, dynamic max) {
    final minText = min?.toString();
    final maxText = max?.toString();
    if (minText != null &&
        maxText != null &&
        minText.isNotEmpty &&
        maxText.isNotEmpty) {
      return '${minText}m-${maxText}m';
    }
    if (minText != null && minText.isNotEmpty) return '${minText}m';
    if (maxText != null && maxText.isNotEmpty) return '${maxText}m';
    return 'N/A';
  }

  static String _formatTimeAgo(String? createdAtRaw) {
    if (createdAtRaw == null || createdAtRaw.isEmpty) return 'Just now';
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return 'Just now';

    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';

    final years = (months / 12).floor();
    return '${years}y ago';
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
