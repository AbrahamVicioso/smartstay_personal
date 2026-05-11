import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/credencial_acceso.dart';

class CredencialService {
  String get _base => AppConstants.registrosBaseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<CredencialAcceso>> getMisCredenciales(String token) async {
    try {
      final url = '$_base/credencialesacceso/me/personal';
      debugPrint('[CredencialService] GET $url');

      final response = await http
          .get(Uri.parse(url), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      debugPrint('[CredencialService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> items = body is List ? body : (body['items'] ?? body['data'] ?? []);
        return items.map((j) => CredencialAcceso.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[CredencialService] Error: $e');
      return [];
    }
  }

  Future<bool> toggleCredencial(String token, int credencialId) async {
    try {
      final url = '$_base/credencialesacceso/me/personal/$credencialId/toggle';
      debugPrint('[CredencialService] POST $url');

      final response = await http
          .post(Uri.parse(url), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      debugPrint('[CredencialService] Toggle status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[CredencialService] Toggle error: $e');
      return false;
    }
  }
}
