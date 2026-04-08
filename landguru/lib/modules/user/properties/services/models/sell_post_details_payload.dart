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
      _addressMap?['fullAddress']?.toString() ??
      _addressMap?['address']?.toString() ??
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

  String? get distanceFromRoadMin =>
      raw['roadDistanceMin']?.toString() ??
      raw['distanceFromRoadMin']?.toString();
  String? get distanceFromRoadMax =>
      raw['roadDistanceMax']?.toString() ??
      raw['distanceFromRoadMax']?.toString();

  int? get lastCompletedStep {
    final value = raw['lastCompletedStep'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? get videoUrl {
    final value =
        raw['videoUrl']?.toString().trim() ??
        _firstDocumentByCategory('VIDEO')?.toString().trim();
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
    return _readStringList(
      raw['deedFiles'],
      fallback: _documentsByCategory('DEED'),
    );
  }

  List<String> get khatianFiles {
    return _readStringList(
      raw['khatianFiles'],
      fallback: _documentsByCategory('KHATIAN'),
    );
  }

  List<String> get otherFiles {
    return _readStringList(
      raw['otherFiles'],
      fallback: _documentsByCategory('OTHER'),
    );
  }

  List<String> get pentagraphMapFiles {
    return _documentsByCategory('PENTAGRAPH_MAP');
  }

  List<String> get selectedServices {
    final fromLegacy = _readStringList(raw['selectedServices']);
    if (fromLegacy.isNotEmpty) {
      return fromLegacy;
    }

    final list = raw['selectedServiceslist'];
    if (list is! List) {
      return const [];
    }

    return list
        .whereType<Map>()
        .map((item) => item['serviceKey']?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get selectedServiceItems {
    final list = raw['selectedServiceslist'];
    if (list is! List) {
      return const [];
    }
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> get riskChecklistItems {
    final list = raw['riskChecklist'];
    if (list is! List) {
      return const [];
    }
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> get ownershipHistoryItems {
    final list = raw['ownershipHistory'];
    if (list is! List) {
      return const [];
    }
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, String>> get legalDocumentItems {
    final docs = raw['documents'];
    if (docs is! List) {
      return const [];
    }

    return docs
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) {
          final category =
              (item['category']?.toString().trim().toUpperCase() ?? 'OTHER');
          final fileUrl = item['fileUrl']?.toString().trim() ?? '';
          if (fileUrl.isEmpty) {
            return const <String, String>{};
          }

          return <String, String>{'category': category, 'url': fileUrl};
        })
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
      final name = _readString(seller, 'name') ?? _readString(seller, 'fullName');
      if (name != null) return name;
    }
    return _readString(raw, 'postedBy') ??
        _readString(raw, 'sellerName') ??
        'Unknown Seller';
  }

  String? get sellerAvatarUrl {
    final seller = _seller;
    if (seller != null) {
      return _readString(seller, 'avatar') ??
          _readString(seller, 'image') ??
          _readString(seller, 'photoUrl');
    }
    return _readString(raw, 'sellerAvatar') ??
        _readString(raw, 'sellerImage') ??
        _readString(raw, 'avatar');
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

  Map<String, dynamic>? get _addressMap {
    final value = raw['address'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<String> _readStringList(dynamic rawList, {List<String>? fallback}) {
    if (rawList is! List) {
      return fallback ?? const [];
    }

    final values = rawList
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (values.isNotEmpty) {
      return values;
    }
    return fallback ?? const [];
  }

  List<String> _documentsByCategory(String category) {
    final docs = raw['documents'];
    if (docs is! List) {
      return const [];
    }

    return docs
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where(
          (item) =>
              item['category']?.toString().trim().toUpperCase() == category,
        )
        .map((item) => item['fileUrl']?.toString().trim() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String? _firstDocumentByCategory(String category) {
    final docs = _documentsByCategory(category);
    if (docs.isEmpty) {
      return null;
    }
    return docs.first;
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

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
    return null;
  }
}
