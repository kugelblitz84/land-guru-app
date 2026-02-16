class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;
  final bool isVerified;
  final Address address;
  final Verification verification;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.isVerified,
    required this.address,
    required this.verification,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final addressMap = _readMap(json, ['address']) ?? json;
    final verificationMap =
        _readMap(json, ['verification', 'verificationDocs']) ?? json;

    return ProfileModel(
      id: _readString(json, ['id']) ?? '',
      fullName: _readString(json, ['fullName', 'name']) ?? '',
      email: _readString(json, ['email']) ?? '',
      phone: _readString(json, ['phone']) ?? '',
      photoUrl: _readString(json, ['photoUrl', 'image']) ?? '',
      isVerified: _readBool(json, ['isVerified']) ?? false,
      address: Address.fromJson(addressMap),
      verification: Verification.fromJson(verificationMap),
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
        final normalized = value.toLowerCase().trim();
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
}

class Address {
  final String division;
  final String district;
  final String upazila;
  final String unionOrCityCorp;
  final String wardNo;
  final String postalCode;
  final String fullAddress;

  Address({
    required this.division,
    required this.district,
    required this.upazila,
    required this.unionOrCityCorp,
    required this.wardNo,
    required this.postalCode,
    required this.fullAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
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

class Verification {
  final String nidNumber;
  final String nidFrontUrl;
  final String nidBackUrl;
  final bool isNIDVerified;
  final String tinNumber;
  final String tinCertificateUrl;
  final bool isTINVerified;

  Verification({
    required this.nidNumber,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    required this.isNIDVerified,
    required this.tinNumber,
    required this.tinCertificateUrl,
    required this.isTINVerified,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      nidNumber: _readString(json, ['nidNumber']) ?? '',
      nidFrontUrl: _readString(json, ['nidFrontUrl']) ?? '',
      nidBackUrl: _readString(json, ['nidBackUrl']) ?? '',
      isNIDVerified: _readBool(json, ['isNIDVerified']) ?? false,
      tinNumber: _readString(json, ['tinNumber']) ?? '',
      tinCertificateUrl: _readString(json, ['tinCertificateUrl']) ?? '',
      isTINVerified: _readBool(json, ['isTINVerified']) ?? false,
    );
  }

  bool get nidVerified => isNIDVerified;
  bool get tinVerified => isTINVerified;

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
        final normalized = value.toLowerCase().trim();
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

class AccountSummaryModel {
  final String memberSince;
  final int activeDeals;
  final int propertiesListed;

  const AccountSummaryModel({
    required this.memberSince,
    required this.activeDeals,
    required this.propertiesListed,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      memberSince: _readString(json, ['memberSince']) ?? '--',
      activeDeals: _readInt(json, ['activeDeals']),
      propertiesListed: _readInt(json, ['propertiesListed']),
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

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }
}
