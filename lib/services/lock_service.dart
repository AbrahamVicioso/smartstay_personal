import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/cerradura.dart';
import '../config/constants.dart';

class LockService {
  // Obtener lista de habitaciones
  Future<List<Room>> getRooms({int? hotelId}) async {
    // Mock data - Reemplazar con llamada API real
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Room(
        habitacionId: 1,
        hotelId: 1,
        numeroHabitacion: '101',
        tipoHabitacion: 'Suite',
        estado: 'Ocupada',
        cerraduraId: 1,
        estadoPuerta: 'Cerrada',
        guestName: 'Carlos Méndez',
        checkInDate: DateTime.now().subtract(const Duration(days: 2)),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        estaDisponible: false,
      ),
      Room(
        habitacionId: 2,
        hotelId: 1,
        numeroHabitacion: '102',
        tipoHabitacion: 'Doble',
        estado: 'Disponible',
        cerraduraId: 2,
        estadoPuerta: 'Cerrada',
        estaDisponible: true,
      ),
      Room(
        habitacionId: 3,
        hotelId: 1,
        numeroHabitacion: '103',
        tipoHabitacion: 'Individual',
        estado: 'Ocupada',
        cerraduraId: 3,
        estadoPuerta: 'Cerrada',
        guestName: 'María García',
        checkInDate: DateTime.now().subtract(const Duration(days: 1)),
        checkOutDate: DateTime.now().add(const Duration(days: 5)),
        estaDisponible: false,
      ),
      Room(
        habitacionId: 4,
        hotelId: 1,
        numeroHabitacion: '201',
        tipoHabitacion: 'Suite Presidencial',
        estado: 'Ocupada',
        cerraduraId: 4,
        estadoPuerta: 'Cerrada',
        guestName: 'Juan Pérez',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 7)),
        estaDisponible: false,
      ),
      Room(
        habitacionId: 5,
        hotelId: 1,
        numeroHabitacion: '202',
        tipoHabitacion: 'Doble',
        estado: 'Limpieza',
        cerraduraId: 5,
        estadoPuerta: 'Cerrada',
        estaDisponible: false,
      ),
      Room(
        habitacionId: 6,
        hotelId: 1,
        numeroHabitacion: '203',
        tipoHabitacion: 'Individual',
        estado: 'Disponible',
        cerraduraId: 6,
        estadoPuerta: 'Cerrada',
        estaDisponible: true,
      ),
    ];

    /* API Real - Descomentar cuando esté lista
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/habitaciones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener habitaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    */
  }

  // Abrir puerta de habitación
  Future<Map<String, dynamic>> unlockDoor({
    required int cerraduraId,
    required int habitacionId,
    required String numeroHabitacion,
    String motivo = 'Acceso Personal',
  }) async {
    // Simular apertura de puerta - Reemplazar con llamada API real
    await Future.delayed(const Duration(seconds: 1));

    // Simular éxito (90% de probabilidad)
    final bool exito = DateTime.now().millisecond % 10 != 0;

    return {
      'exitoso': exito,
      'mensaje': exito
          ? 'Puerta de habitación $numeroHabitacion desbloqueada correctamente'
          : 'Error al desbloquear puerta de habitación $numeroHabitacion',
      'cerraduraId': cerraduraId,
      'habitacionId': habitacionId,
      'fechaHora': DateTime.now().toIso8601String(),
    };

    /* API Real - Descomentar cuando esté lista
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/cerraduras/$cerraduraId/abrir'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'habitacionId': habitacionId,
          'motivo': motivo,
          'tipoAcceso': 'AccesoPersonalLimpieza', // Ajustar según tipo de personal
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al abrir puerta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    */
  }

  // Obtener información de cerradura específica
  Future<Cerradura?> getCerradura(int cerraduraId) async {
    // Mock data
    await Future.delayed(const Duration(milliseconds: 300));

    return Cerradura(
      cerraduraId: cerraduraId,
      habitacionId: 1,
      dispositivoId: 101,
      numeroHabitacion: '101',
      estadoPuerta: 'Cerrada',
      modoOperacion: 'Normal',
      contadorAperturas: 45,
      estaActiva: true,
      ultimaApertura: DateTime.now().subtract(const Duration(hours: 2)),
    );

    /* API Real
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/cerraduras/$cerraduraId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Cerradura.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
    */
  }

  // Obtener historial de accesos de una habitación
  Future<List<Map<String, dynamic>>> getAccessHistory(int habitacionId) async {
    // Mock data
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'registroId': 1,
        'fechaHora': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'tipoAcceso': 'AccesoPersonalLimpieza',
        'resultado': 'Exitoso',
        'usuario': 'Personal Limpieza',
      },
      {
        'registroId': 2,
        'fechaHora': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'tipoAcceso': 'AccesoHuesped',
        'resultado': 'Exitoso',
        'usuario': 'Huésped',
      },
    ];

    /* API Real
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/habitaciones/$habitacionId/accesos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
    */
  }
}
