class SendOtpPayload {
  const SendOtpPayload({required this.phone, this.forgetPassword = false});

  final String phone;
  final bool forgetPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'phone': phone, 'forgetPassword': forgetPassword};
  }
}

class VerifyOtpPayload {
  const VerifyOtpPayload({required this.phone, required this.otp});

  final String phone;
  final String otp;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'phone': phone, 'otp': otp};
  }
}

class ResetPasswordWithOtpPayload {
  const ResetPasswordWithOtpPayload({
    required this.phone,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String phone;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phone,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class CompleteSignupPayload {
  const CompleteSignupPayload({
    required this.phone,
    required this.password,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.division,
    this.district,
    this.upazila,
    this.unionOrCityCorp,
    this.wardNo,
    this.postalCode,
    this.fullAddress,
  });

  final String phone;
  final String password;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? division;
  final String? district;
  final String? upazila;
  final String? unionOrCityCorp;
  final String? wardNo;
  final String? postalCode;
  final String? fullAddress;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phone,
      'password': password,
      'role': 'user',
      'fullName': fullName,
      'email': email,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      if (division != null && division!.isNotEmpty) 'division': division,
      if (district != null && district!.isNotEmpty) 'district': district,
      if (upazila != null && upazila!.isNotEmpty) 'upazila': upazila,
      if (unionOrCityCorp != null && unionOrCityCorp!.isNotEmpty)
        'unionOrCityCorp': unionOrCityCorp,
      if (wardNo != null && wardNo!.isNotEmpty) 'wardNo': wardNo,
      if (postalCode != null && postalCode!.isNotEmpty)
        'postalCode': postalCode,
      if (fullAddress != null && fullAddress!.isNotEmpty)
        'fullAddress': fullAddress,
    };
  }
}

class CompleteSignupIdentityPayload {
  const CompleteSignupIdentityPayload({
    required this.phone,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    this.tinCertificateUrl,
  });

  final String phone;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String? tinCertificateUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phone,
      'nidFrontUrl': nidFrontUrl,
      'nidBackUrl': nidBackUrl,
      if (tinCertificateUrl != null && tinCertificateUrl!.isNotEmpty)
        'tinCertificateUrl': tinCertificateUrl,
    };
  }
}

class LoginPayload {
  const LoginPayload({required this.phone, required this.password});

  final String phone;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'phone': phone, 'password': password};
  }
}

class AuthUserModel {
  const AuthUserModel({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.photoUrl = '',
    this.role = '',
    this.isVerified = false,
    this.agentType = '',
    this.agentId = '',
    this.agentIdDisplay = '',
    this.agentTitle = '',
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;
  final String role;
  final bool isVerified;
  final String agentType;
  final String agentId;
  final String agentIdDisplay;
  final String agentTitle;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: _readString(json, 'id') ?? '',
      fullName: _readString(json, 'fullName') ?? '',
      email: _readString(json, 'email') ?? '',
      phone: _readString(json, 'phone') ?? '',
      photoUrl: _readString(json, 'photoUrl') ?? '',
      role: _readString(json, 'role') ?? '',
      isVerified: _readBool(json, 'isVerified') ?? false,
      agentType: _readString(json, 'agentType') ?? '',
      agentId: _readString(json, 'agentId') ?? '',
      agentIdDisplay: _readString(json, 'agentIdDisplay') ?? '',
      agentTitle: _readString(json, 'agentTitle') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'isVerified': isVerified,
      'agentType': agentType,
      'agentId': agentId,
      'agentIdDisplay': agentIdDisplay,
      'agentTitle': agentTitle,
    };
  }

  AuthUserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    bool? isVerified,
    String? agentType,
    String? agentId,
    String? agentIdDisplay,
    String? agentTitle,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      agentType: agentType ?? this.agentType,
      agentId: agentId ?? this.agentId,
      agentIdDisplay: agentIdDisplay ?? this.agentIdDisplay,
      agentTitle: agentTitle ?? this.agentTitle,
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
      final normalized = value.toLowerCase().trim();
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

class AuthSessionResponse {
  const AuthSessionResponse({
    required this.raw,
    this.accessToken,
    // this.refreshToken,
    this.user,
  });

  final Map<String, dynamic> raw;
  final String? accessToken;
  //final String? refreshToken;
  final AuthUserModel? user;

  factory AuthSessionResponse.fromPayload(dynamic payload) {
    if (payload is! Map) {
      throw Exception('Invalid auth response');
    }

    final map = Map<String, dynamic>.from(payload);

    AuthUserModel? extractUser() {
      final directUser = map['user'];
      if (directUser is Map) {
        return AuthUserModel.fromJson(Map<String, dynamic>.from(directUser));
      }

      final data = map['data'];
      if (data is Map) {
        final nestedUser = data['user'];
        if (nestedUser is Map) {
          return AuthUserModel.fromJson(Map<String, dynamic>.from(nestedUser));
        }
      }

      return null;
    }

    String? extractToken(String key) {
      final value = map[key]?.toString();
      if (value != null && value.isNotEmpty) {
        return value;
      }

      final data = map['data'];
      if (data is Map) {
        final nested = data[key]?.toString();
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }

      return null;
    }

    return AuthSessionResponse(
      raw: map,
      accessToken: extractToken('accessToken'),
      //refreshToken: extractToken(const ['refreshToken']),
      user: extractUser(),
    );
  }
}
