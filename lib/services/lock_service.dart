import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/room.dart';

class LockService {
  
  String _getBaseUrl() {
    return AppConstants.habitacionesBaseUrl; // http://localhost:7279
  }

  Future<List<Room>> getRooms({int? hotelId}) async {
    try {
      String url;
      if (hotelId != null) {
        url = '${_getBaseUrl()}/Habitacion/hotel/$hotelId';
      } else {
        url = '${_getBaseUrl()}/Habitacion';
      }
      
      debugPrint('[LockService] GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[LockService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[LockService] Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> unlockDoor({
    required int cerraduraId,
    required int habitacionId,
    required String numeroHabitacion,
    required String motivo,
  }) async {
    try {
      final url = '${_getBaseUrl()}/Habitacion/$habitacionId/unlock';
      debugPrint('[LockService] POST $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'exitoso': true,
          'mensaje': 'Puerta de habitacion $numeroHabitacion abierta',
        };
      } else {
        return {
          'exitoso': false,
          'mensaje': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'exitoso': false,
        'mensaje': 'Error de conexion: $e',
      };
    }
  }
}