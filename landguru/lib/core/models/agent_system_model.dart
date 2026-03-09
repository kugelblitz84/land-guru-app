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
    final statsMap = _readMap(json, ['stats']) ?? const <String, dynamic>{};
    final detailsMap =
        _readMap(json, ['personalDetails']) ?? const <String, dynamic>{};
    final verificationMap =
        _readMap(json, ['verificationDocs', 'verification']) ??
        const <String, dynamic>{};
    final bankInfoMap =
        _readMap(json, ['bankInfo']) ?? const <String, dynamic>{};

    return AgentProfileModel(
      agentId: _readString(json, ['agentId', 'id']) ?? '',
      fullName: _readString(json, ['fullName', 'name']) ?? '',
      phone: _readString(json, ['phone']) ?? '',
      email: _readString(json, ['email']) ?? '',
      photoUrl: _readString(json, ['photoUrl', 'image']) ?? '',
      agentType: _readString(json, ['agentType']) ?? '',
      isVerified: _readBool(json, ['isVerified']) ?? false,
      agentIdDisplay: _readString(json, ['agentIdDisplay']) ?? '',
      stats: AgentStats.fromJson(statsMap),
      assignedLocation: _readString(json, ['assignedLocation']) ?? '',
      services: _readStringList(json, ['services']),
      personalDetails: AgentPersonalDetails.fromJson(detailsMap),
      verificationDocs: AgentVerificationDocs.fromJson(verificationMap),
      bankInfo: AgentBankInfo.fromJson(bankInfoMap),
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
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
    }
    return null;
  }

  static Map<String, dynamic>? _readMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return null;
  }

  static List<String> _readStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
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
      totalTaskCompleted: _readInt(json, ['totalTaskCompleted']) ?? 0,
      totalEarned: _readDouble(json, ['totalEarned']) ?? 0,
    );
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
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
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
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
      division: _readString(json, ['division']) ?? '',
      district: _readString(json, ['district']) ?? '',
      upazila: _readString(json, ['upazila', 'thana']) ?? '',
      unionOrCityCorp: _readString(json, ['unionOrCityCorp']) ?? '',
      wardNo: _readString(json, ['wardNo']) ?? '',
      postalCode: _readString(json, ['postalCode']) ?? '',
      fullAddress: _readString(json, ['fullAddress', 'address']) ?? '',
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
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
      nidNumber:
          _readString(json, ['nidNumber', 'nidNo', 'nationalIdNumber']) ?? '',
      nidFrontUrl: _readString(json, ['nidFrontUrl']) ?? '',
      nidBackUrl: _readString(json, ['nidBackUrl']) ?? '',
      isNIDVerified: _readBool(json, ['isNIDVerified']) ?? false,
      tinNumber: _readString(json, ['tinNumber', 'tinNo']) ?? '',
      tinCertificateUrl: _readString(json, ['tinCertificateUrl']) ?? '',
      isTINVerified: _readBool(json, ['isTINVerified']) ?? false,
    );
  }

  bool get hasNidDocument =>
      nidFrontUrl.trim().isNotEmpty || nidBackUrl.trim().isNotEmpty;
  bool get hasTinDocument => tinCertificateUrl.trim().isNotEmpty;

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
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
      bankName: _readString(json, ['bankName']) ?? '',
      bankAccountNo: _readString(json, ['bankAccountNo']) ?? '',
      bankSwiftCode: _readString(json, ['bankSwiftCode']) ?? '',
      bankRoutingNo: _readString(json, ['bankRoutingNo']) ?? '',
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
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
    required this.isVerified,
    required this.profileImage,
    required this.email,
    required this.phone,
    required this.totalTasksCompleted,
    required this.totalEarned,
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
      isVerified: false,
      profileImage: '',
      email: '',
      phone: '',
      totalTasksCompleted: 0,
      totalEarned: 0,
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
  final bool isVerified;
  final String profileImage;
  final String email;
  final String phone;
  final int totalTasksCompleted;
  final double totalEarned;
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
  final bool isNidVerified;
  final bool isTinVerified;
  final String bankName;
  final String bankAccountNo;
  final String swiftCode;
  final String routingNo;

  String get displayName {
    if (agentTitle.trim().isNotEmpty) {
      return '$agentTitle $agentName';
    }
    return agentName;
  }

  AgentProfileStateModel copyWith({
    bool? isOnline,
    int? unreadNotificationCount,
    String? agentName,
    String? agentTitle,
    String? agentId,
    String? agentType,
    bool? isVerified,
    String? profileImage,
    String? email,
    String? phone,
    int? totalTasksCompleted,
    double? totalEarned,
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
      isVerified: isVerified ?? this.isVerified,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalEarned: totalEarned ?? this.totalEarned,
      assignedLocation: assignedLocation ?? this.assignedLocation,
      servicesProvided:
          servicesProvided ?? List<String>.from(this.servicesProvided),
      division: division ?? this.division,
      district: district ?? this.district,
      upazilla: upazilla ?? this.upazilla,
      pouroshova: pouroshova ?? this.pouroshova,
      wardNo: wardNo ?? this.wardNo,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      nidNumber: nidNumber ?? this.nidNumber,
      tinNumber: tinNumber ?? this.tinNumber,
      isNidVerified: isNidVerified ?? this.isNidVerified,
      isTinVerified: isTinVerified ?? this.isTinVerified,
      bankName: bankName ?? this.bankName,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      swiftCode: swiftCode ?? this.swiftCode,
      routingNo: routingNo ?? this.routingNo,
    );
  }
}
