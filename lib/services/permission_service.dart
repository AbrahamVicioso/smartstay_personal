import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/permiso_personal.dart';

class PermissionService {
  
  String _getBaseUrl() {
    return AppConstants.personalBaseUrl;
  }

  String _getHabitacionesUrl() {
    return AppConstants.habitacionesBaseUrl;
  }

  /// GET /PermisoPersonal/personal/{personalId}/activos
  Future<List<PermisoPersonal>> getPermisosActivos(String personalId, String? token) async {
    if (personalId.isEmpty) {
      debugPrint('[PermissionService] personalId vacio');
      return [];
    }

    try {
      final url = '${_getBaseUrl()}/PermisoPersonal/personal/$personalId/activos';
      debugPrint('[PermissionService] GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[PermissionService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('[PermissionService] Permisos activos: ${data.length}');
        return data.map((json) => PermisoPersonal.fromJson(json)).toList();
      } else {
        debugPrint('[PermissionService] Error: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('[PermissionService] Exception: $e');
      return [];
    }
  }

  /// GET /PermisoPersonal/personal/{personalId}
  Future<List<PermisoPersonal>> getPermisosByPersonal(String personalId, String? token) async {
    if (personalId.isEmpty) {
      return [];
    }

    try {
      final url = '${_getBaseUrl()}/PermisoPersonal/personal/$personalId';
      debugPrint('[PermissionService] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PermisoPersonal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[PermissionService] Error: $e');
      return [];
    }
  }

  /// POST /PermisoPersonal - Solicitar acceso a habitacion o actividad
  Future<Map<String, dynamic>> solicitarAcceso({
    required String personalId,
    String? token,
    int? habitacionId,
    int? actividadId,
    String? justificacion,
    DateTime? fechaExpiracion,
    bool esTemporal = true,
  }) async {
    try {
      final url = '${_getBaseUrl()}/PermisoPersonal';
      debugPrint('[PermissionService] POST $url');

      final body = {
        'personalId': int.tryParse(personalId) ?? personalId,
        if (habitacionId != null) 'habitacionId': habitacionId,
        if (actividadId != null) 'actividadId': actividadId,
        if (fechaExpiracion != null) 'fechaExpiracion': fechaExpiracion.toIso8601String(),
        'esTemporal': esTemporal,
        if (justificacion != null) 'justificacion': justificacion,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('[PermissionService] solicitarAcceso status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'exitoso': true,
          'mensaje': 'Permiso solicitado correctamente',
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : null,
        };
      } else {
        return {
          'exitoso': false,
          'mensaje': 'Error al solicitar permiso: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('[PermissionService] solicitarAcceso error: $e');
      return {
        'exitoso': false,
        'mensaje': 'Error de conexion: $e',
      };
    }
  }

  /// POST /Habitacion/{habitacionId}/unlock - Abrir puerta
  Future<Map<String, dynamic>> abrirPuerta(int habitacionId, String? token) async {
    try {
      final url = '${_getHabitacionesUrl()}/Habitacion/$habitacionId/unlock';
      debugPrint('[PermissionService] POST $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[PermissionService] abrirPuerta status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'exitoso': true,
          'mensaje': 'Puerta abierta correctamente',
        };
      } else {
        return {
          'exitoso': false,
          'mensaje': 'Error al abrir puerta: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('[PermissionService] abrirPuerta error: $e');
      return {
        'exitoso': false,
        'mensaje': 'Error de conexion: $e',
      };
    }
  }
}