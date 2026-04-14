// lib/services/history_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/registro_acceso.dart';

class HistoryService {
  Future<Map<String, dynamic>> getRegistrosByUsuario(
    String usuarioId, {
    String? token,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.registrosBaseUrl}/RegistrosAcceso/usuario/$usuarioId'
        '?Page=$page&PageSize=$pageSize',
      );
      debugPrint('[HistoryService] GET $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = (data['items'] as List)
            .map((j) => RegistroAcceso.fromJson(j))
            .toList();
        return {
          'items': items,
          'totalCount': data['totalCount'] ?? 0,
          'totalPages': data['totalPages'] ?? 1,
          'hasNextPage': data['hasNextPage'] ?? false,
        };
      }
      return {
        'items': <RegistroAcceso>[],
        'totalCount': 0,
        'totalPages': 1,
        'hasNextPage': false,
      };
    } catch (e) {
      debugPrint('[HistoryService] Error: $e');
      return {
        'items': <RegistroAcceso>[],
        'totalCount': 0,
        'totalPages': 1,
        'hasNextPage': false,
      };
    }
  }
}
