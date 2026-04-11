import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/employee.dart';
import '../config/constants.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveTokens(authResponse);
        await _storage.write(key: AppConstants.userEmailKey, value: email);
        return authResponse;
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al registrarse: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<AuthResponse> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

    if (refreshToken == null) {
      throw Exception('No hay refresh token disponible');
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.refreshEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveTokens(authResponse);
        return authResponse;
      } else {
        throw Exception('Error al refrescar token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<User?> getUserInfo() async {
    final token = await getAccessToken();
    final email = await _storage.read(key: AppConstants.userEmailKey);

    if (token == null || email == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/Users/by-email/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Employee?> getEmpleado(String userId, String email) async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final responseLista = await http.get(
        Uri.parse('${AppConstants.personalBaseUrl}/Personal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (responseLista.statusCode == 200) {
        final data = jsonDecode(responseLista.body);

        if (data is List) {
          final lista = data
              .where((emp) => (emp['usuarioId'] ?? '').toString() == userId)
              .toList();

          if (lista.isNotEmpty) {
            return Employee.fromJson(lista.first);
          }
        } else if (data is Map<String, dynamic>) {
          final usuarioId = data['usuarioId'] ?? '';
          if (usuarioId.toString() == userId) {
            return Employee.fromJson(data);
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> esEmpleado(String userId, String email) async {
    final empleado = await getEmpleado(userId, email);
    return empleado != null;
  }

  Future<void> _saveTokens(AuthResponse authResponse) async {
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;

    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: authResponse.accessToken,
    );
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: authResponse.refreshToken,
    );
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }

    _accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    return _accessToken;
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }
}
