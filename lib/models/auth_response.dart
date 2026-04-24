enum LoginStatus { success, requiresTwoFactor, emailNotConfirmed, failed }

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final LoginStatus status;
  final String? errorMessage;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.status = LoginStatus.success,
    this.errorMessage,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
      tokenType: json['tokenType'] ?? 'Bearer',
      status: LoginStatus.success,
    );
  }

  factory AuthResponse.requiresTwoFactor() {
    return AuthResponse(
      accessToken: '',
      refreshToken: '',
      expiresIn: 0,
      tokenType: 'Bearer',
      status: LoginStatus.requiresTwoFactor,
    );
  }

  factory AuthResponse.emailNotConfirmed() {
    return AuthResponse(
      accessToken: '',
      refreshToken: '',
      expiresIn: 0,
      tokenType: 'Bearer',
      status: LoginStatus.emailNotConfirmed,
      errorMessage: 'Debes confirmar tu correo electrónico antes de iniciar sesión.',
    );
  }

  factory AuthResponse.failed(String message) {
    return AuthResponse(
      accessToken: '',
      refreshToken: '',
      expiresIn: 0,
      tokenType: 'Bearer',
      status: LoginStatus.failed,
      errorMessage: message,
    );
  }

  bool get isSuccess => status == LoginStatus.success && accessToken.isNotEmpty;
}
