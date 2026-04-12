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
      } else if (response.statusCode == 401) {
        throw Exception('Correo o contraseña incorrectos');
      } else if (response.statusCode >= 500) {
        throw Exception('Error del servidor, intenta más tarde');
      } else {
        throw Exception('Error inesperado (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception && 
          (e.toString().contains('SocketException') || 
           e.toString().contains('TimeoutException') || 
           e.toString().contains('HttpException'))) {
        throw Exception('Error de conexión. Verifica tu internet');
      }
      rethrow;
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
    final response = await http.get(
      Uri.parse('${AppConstants.personalBaseUrl}/Personal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("USER ID LOGIN: $userId");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        for (var emp in data) {
          final apiUserId = emp['usuarioId']?.toString().trim();

          print("API USER ID: $apiUserId");

          if (apiUserId == userId.trim()) {
            print("✅ EMPLEADO ENCONTRADO");
            return Employee.fromJson(emp);
          }
        }
      }
    } else {
      print("❌ ERROR API PERSONAL: ${response.statusCode}");
    }

    print("❌ NO SE ENCONTRO EMPLEADO");
    return null;
  } catch (e) {
    print("❌ ERROR: $e");
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
