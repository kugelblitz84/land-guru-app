class AgentProfileModel {
  final String agentId;
  final String fullName;
  final String phone;
  final String email;
  final String photoUrl;
  final String agentType;
  final bool isVerified;
  final String agentIdDisplay;
  final AgentStats stats;
  final String assignedLocation;
  final List<String> services;
  final AgentPersonalDetails personalDetails;
  final AgentVerificationDocs verificationDocs;
  final AgentBankInfo bankInfo;
  AgentProfileModel({
    required this.agentId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.agentType,
    required this.isVerified,
    required this.agentIdDisplay,
    required this.stats,
    required this.assignedLocation,
    required this.services,
    required this.personalDetails,
    required this.verificationDocs,
    required this.bankInfo,
  });

  factory AgentProfileModel.fromJson(Map<String, dynamic> json) {
    final statsMap = _readMap(json, 'stats') ?? const <String, dynamic>{};
    final detailsMap =
        _readMap(json, 'personalDetails') ?? const <String, dynamic>{};
    final verificationMap =
      _readMap(json, 'verificationDocs') ?? const <String, dynamic>{};
    final bankInfoMap =
        _readMap(json, 'bankInfo') ?? const <String, dynamic>{};

    return AgentProfileModel(
      agentId: _readString(json, 'agentId') ?? '',
      fullName: _readString(json, 'fullName') ?? '',
      phone: _readString(json, 'phone') ?? '',
      email: _readString(json, 'email') ?? '',
      photoUrl: _readString(json, 'photoUrl') ?? '',
      agentType: _readString(json, 'agentType') ?? '',
      isVerified: _readBool(json, 'isVerified') ?? false,
      agentIdDisplay: _readString(json, 'agentIdDisplay') ?? '',
      stats: AgentStats.fromJson(statsMap),
      assignedLocation: _readString(json, 'assignedLocation') ?? '',
      services: _readStringList(json, 'services'),
      personalDetails: AgentPersonalDetails.fromJson(detailsMap),
      verificationDocs: AgentVerificationDocs.fromJson(verificationMap),
      bankInfo: AgentBankInfo.fromJson(bankInfoMap),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _readMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<String> _readStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }
}

class AgentStats {
  final int totalTaskCompleted;
  final double totalEarned;

  AgentStats({required this.totalTaskCompleted, required this.totalEarned});

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      totalTaskCompleted: _readInt(json, 'totalTaskCompleted') ?? 0,
      totalEarned: _readDouble(json, 'totalEarned') ?? 0,
    );
  }

  static int? _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }
}

class AgentPersonalDetails {
  final String division;
  final String district;
  final String upazila;
  final String unionOrCityCorp;
  final String wardNo;
  final String postalCode;
  final String fullAddress;

  AgentPersonalDetails({
    required this.division,
    required this.district,
    required this.upazila,
    required this.unionOrCityCorp,
    required this.wardNo,
    required this.postalCode,
    required this.fullAddress,
  });

  factory AgentPersonalDetails.fromJson(Map<String, dynamic> json) {
    return AgentPersonalDetails(
      division: _readString(json, 'division') ?? '',
      district: _readString(json, 'district') ?? '',
      upazila: _readString(json, 'upazila') ?? '',
      unionOrCityCorp: _readString(json, 'unionOrCityCorp') ?? '',
      wardNo: _readString(json, 'wardNo') ?? '',
      postalCode: _readString(json, 'postalCode') ?? '',
      fullAddress: _readString(json, 'fullAddress') ?? '',
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}

class AgentVerificationDocs {
  final String nidNumber;
  final String nidFrontUrl;
  final String nidBackUrl;
  final bool isNIDVerified;
  final String tinNumber;
  final String tinCertificateUrl;
  final bool isTINVerified;

  AgentVerificationDocs({
    required this.nidNumber,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    required this.isNIDVerified,
    required this.tinNumber,
    required this.tinCertificateUrl,
    required this.isTINVerified,
  });

  factory AgentVerificationDocs.fromJson(Map<String, dynamic> json) {
    return AgentVerificationDocs(
      // NOTE: /agents/profile sample exposes verificationDocs.nidFrontUrl,
      // nidBackUrl, isNIDVerified, tinCertificateUrl, isTINVerified only.
      // Keep number fields empty until backend defines canonical names.
      nidNumber: _readString(json, 'nidNumber') ?? '',
      nidFrontUrl: _readString(json, 'nidFrontUrl') ?? '',
      nidBackUrl: _readString(json, 'nidBackUrl') ?? '',
      isNIDVerified: _readBool(json, 'isNIDVerified') ?? false,
      tinNumber: _readString(json, 'tinNumber') ?? '',
      tinCertificateUrl: _readString(json, 'tinCertificateUrl') ?? '',
      isTINVerified: _readBool(json, 'isTINVerified') ?? false,
    );
  }

  bool get nidVerified => isNIDVerified;
  bool get tinVerified => isTINVerified;
  bool get hasNidDocument =>
      nidFrontUrl.trim().isNotEmpty || nidBackUrl.trim().isNotEmpty;
  bool get hasTinDocument => tinCertificateUrl.trim().isNotEmpty;

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return null;
  }
}

class AgentBankInfo {
  final String bankName;
  final String bankAccountNo;
  final String bankSwiftCode;
  final String bankRoutingNo;

  AgentBankInfo({
    required this.bankName,
    required this.bankAccountNo,
    required this.bankSwiftCode,
    required this.bankRoutingNo,
  });

  factory AgentBankInfo.fromJson(Map<String, dynamic> json) {
    return AgentBankInfo(
      bankName: _readString(json, 'bankName') ?? '',
      bankAccountNo: _readString(json, 'bankAccountNo') ?? '',
      bankSwiftCode: _readString(json, 'bankSwiftCode') ?? '',
      bankRoutingNo: _readString(json, 'bankRoutingNo') ?? '',
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}

class AgentProfileStateModel {
  const AgentProfileStateModel({
    required this.isOnline,
    required this.unreadNotificationCount,
    required this.agentName,
    required this.agentTitle,
    required this.agentId,
    required this.agentType,
    required this.profileImage,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.assignedLocation,
    required this.servicesProvided,
    required this.division,
    required this.district,
    required this.upazilla,
    required this.pouroshova,
    required this.wardNo,
    required this.postalCode,
    required this.fullAddress,
    required this.nidNumber,
    required this.tinNumber,
    required this.totalTasksCompleted,
    required this.totalEarned,
    required this.isNidVerified,
    required this.isTinVerified,
    required this.bankName,
    required this.bankAccountNo,
    required this.swiftCode,
    required this.routingNo,
  });

  factory AgentProfileStateModel.initial() {
    return const AgentProfileStateModel(
      isOnline: true,
      unreadNotificationCount: 0,
      agentName: '',
      agentTitle: '',
      agentId: '',
      agentType: '',
      profileImage: '',
      email: '',
      phone: '',
      isVerified: false,
      assignedLocation: '',
      servicesProvided: <String>[],
      division: '',
      district: '',
      upazilla: '',
      pouroshova: '',
      wardNo: '',
      postalCode: '',
      fullAddress: '',
      nidNumber: 'Not provided',
      tinNumber: 'Not provided',
      totalTasksCompleted: 0,
      totalEarned: 0,
      isNidVerified: false,
      isTinVerified: false,
      bankName: '',
      bankAccountNo: '',
      swiftCode: '',
      routingNo: '',
    );
  }

  final bool isOnline;
  final int unreadNotificationCount;
  final String agentName;
  final String agentTitle;
  final String agentId;
  final String agentType;
  final String profileImage;
  final String email;
  final String phone;
  final bool isVerified;
  final String assignedLocation;
  final List<String> servicesProvided;
  final String division;
  final String district;
  final String upazilla;
  final String pouroshova;
  final String wardNo;
  final String postalCode;
  final String fullAddress;
  final String nidNumber;
  final String tinNumber;
  final int totalTasksCompleted;
  final double totalEarned;
  final bool isNidVerified;
  final bool isTinVerified;
  final String bankName;
  final String bankAccountNo;
  final String swiftCode;
  final String routingNo;

  String get displayName {
    final name = agentName.trim();
    final title = agentTitle.trim();
    if (title.isEmpty) {
      return name;
    }
    if (name.isEmpty) {
      return title;
    }
    return '$title $name';
  }

  AgentProfileStateModel copyWith({
    bool? isOnline,
    int? unreadNotificationCount,
    String? agentName,
    String? agentTitle,
    String? agentId,
    String? agentType,
    String? profileImage,
    String? email,
    String? phone,
    bool? isVerified,
    String? assignedLocation,
    List<String>? servicesProvided,
    String? division,
    String? district,
    String? upazilla,
    String? pouroshova,
    String? wardNo,
    String? postalCode,
    String? fullAddress,
    String? nidNumber,
    String? tinNumber,
    int? totalTasksCompleted,
    double? totalEarned,
    bool? isNidVerified,
    bool? isTinVerified,
    String? bankName,
    String? bankAccountNo,
    String? swiftCode,
    String? routingNo,
  }) {
    return AgentProfileStateModel(
      isOnline: isOnline ?? this.isOnline,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      agentName: agentName ?? this.agentName,
      agentTitle: agentTitle ?? this.agentTitle,
      agentId: agentId ?? this.agentId,
      agentType: agentType ?? this.agentType,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      assignedLocation: assignedLocation ?? this.assignedLocation,
      servicesProvided: servicesProvided ?? this.servicesProvided,
      division: division ?? this.division,
      district: district ?? this.district,
      upazilla: upazilla ?? this.upazilla,
      pouroshova: pouroshova ?? this.pouroshova,
      wardNo: wardNo ?? this.wardNo,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      nidNumber: nidNumber ?? this.nidNumber,
      tinNumber: tinNumber ?? this.tinNumber,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalEarned: totalEarned ?? this.totalEarned,
      isNidVerified: isNidVerified ?? this.isNidVerified,
      isTinVerified: isTinVerified ?? this.isTinVerified,
      bankName: bankName ?? this.bankName,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      swiftCode: swiftCode ?? this.swiftCode,
      routingNo: routingNo ?? this.routingNo,
    );
  }
}
