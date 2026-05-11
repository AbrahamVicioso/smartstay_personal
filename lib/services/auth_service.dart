import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/employee.dart';
import '../config/constants.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _accessToken;

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await _saveTokens(authResponse);
        await _storage.write(key: AppConstants.userEmailKey, value: email);
        return authResponse;
      }

      if (response.statusCode == 401) {
        final detail = _extractDetail(response.body);
        if (_isEmailNotConfirmed(detail)) {
          return AuthResponse.emailNotConfirmed();
        }
        if (_requiresTwoFactor(detail)) {
          return AuthResponse.requiresTwoFactor();
        }
        throw Exception('Correo o contraseña incorrectos');
      }

      if (response.statusCode >= 500) {
        throw Exception('Error del servidor, intenta más tarde');
      }

      throw Exception('Error inesperado (${response.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet');
    }
  }

  // ─── 2FA ──────────────────────────────────────────────────────────────────

  /// Solicita a la API que envíe el código de 2FA al correo del usuario.
  Future<void> send2FACode(String email) async {
    final response = await http
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}/LoginSendTwoFactorCode'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('No se pudo enviar el código de verificación');
    }
  }

  /// Verifica el código 2FA y, si es válido, devuelve los tokens.
  Future<AuthResponse> verify2FA(String email, String code) async {
    final response = await http
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}/LoginVerifyTwoFactor'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'code': code}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveTokens(authResponse);
      await _storage.write(key: AppConstants.userEmailKey, value: email);
      return authResponse;
    }

    if (response.statusCode == 401) {
      throw Exception('Código incorrecto o expirado');
    }

    throw Exception('Error al verificar el código (${response.statusCode})');
  }

  // ─── Refresh token ────────────────────────────────────────────────────────

  Future<AuthResponse> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

    if (refreshToken == null) {
      throw Exception('No hay refresh token disponible');
    }

    final response = await http
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.refreshEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveTokens(authResponse);
      return authResponse;
    }

    throw Exception('Sesión expirada. Inicia sesión de nuevo');
  }

  // ─── User info ────────────────────────────────────────────────────────────

  Future<User?> getUserInfo() async {
    final token = await getAccessToken();
    if (token == null) return null;
    return _userFromJwt(token);
  }

  User? _userFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64url → base64 estándar
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(Uint8List.fromList(base64Decode(payload)));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      // ASP.NET Identity usa estos claim types
      const nsBase = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/';
      const nsMicrosoft = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/';

      final id = (claims['sub'] ??
              claims['${nsBase}nameidentifier'] ??
              claims['nameid'] ??
              '')
          .toString();

      final email = (claims['email'] ??
              claims['${nsBase}emailaddress'] ??
              '')
          .toString();

      final name = (claims['name'] ??
              claims['${nsBase}name'] ??
              claims['given_name'] ??
              '')
          .toString();

      final roles = claims['${nsMicrosoft}role'] ??
          claims['role'] ??
          claims['roles'] ??
          '';
      final department = roles is List ? roles.join(', ') : roles.toString();

      return User(
        id: id,
        email: email,
        name: name,
        department: department,
        isEmailConfirmed: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Employee?> getEmpleado(String userId, String email) async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.personalBaseUrl}/Personal/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Employee.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> esEmpleado(String userId, String email) async {
    final empleado = await getEmpleado(userId, email);
    return empleado != null;
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  Future<void> _saveTokens(AuthResponse authResponse) async {
    _accessToken = authResponse.accessToken;
    await _storage.write(key: AppConstants.accessTokenKey, value: authResponse.accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: authResponse.refreshToken);
  }

  Future<String?> getAccessToken() async {
    _accessToken ??= await _storage.read(key: AppConstants.accessTokenKey);
    return _accessToken;
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    _accessToken = null;
    await _storage.deleteAll();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      return (json['detail'] ?? json['message'] ?? '').toString().toLowerCase();
    } catch (_) {
      return body.toLowerCase();
    }
  }

  bool _requiresTwoFactor(String detail) =>
      detail.contains('twofactor') ||
      detail.contains('two_factor') ||
      detail.contains('2fa') ||
      detail.contains('requirestwofactor');

  bool _isEmailNotConfirmed(String detail) =>
      detail.contains('email') &&
      (detail.contains('confirm') || detail.contains('verificad') || detail.contains('verified'));
}
