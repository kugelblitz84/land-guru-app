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
  final Map<String, dynamic>? user;

  factory AuthSessionResponse.fromPayload(dynamic payload) {
    if (payload is! Map) {
      throw Exception('Invalid auth response');
    }

    final map = Map<String, dynamic>.from(payload);

    Map<String, dynamic>? extractUser() {
      final directUser = map['user'];
      if (directUser is Map) {
        return Map<String, dynamic>.from(directUser);
      }

      final data = map['data'];
      if (data is Map) {
        final nestedUser = data['user'];
        if (nestedUser is Map) {
          return Map<String, dynamic>.from(nestedUser);
        }
      }

      return null;
    }

    String? extractToken(List<String> keys) {
      for (final key in keys) {
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
      }
      return null;
    }

    return AuthSessionResponse(
      raw: map,
      accessToken: extractToken(const ['accessToken', 'token']),
      //refreshToken: extractToken(const ['refreshToken']),
      user: extractUser(),
    );
  }
}
