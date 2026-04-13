import 'package:flutter/foundation.dart';
import '../models/permiso_personal.dart';
import '../services/permission_service.dart';

class PermissionProvider with ChangeNotifier {
  final PermissionService _permissionService = PermissionService();
  
  List<PermisoPersonal> _permisos = [];
  List<PermisoPersonal> _permisosActivos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PermisoPersonal> get permisos => _permisos;
  List<PermisoPersonal> get permisosActivos => _permisosActivos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PermisoPersonal> get permisosHabitaciones => 
      _permisosActivos.where((p) => p.tieneHabitacion).toList();
  
  List<PermisoPersonal> get permisosActividades => 
      _permisosActivos.where((p) => p.tieneActividad).toList();

  int get totalActivos => _permisosActivos.length;
  int get totalHabitaciones => permisosHabitaciones.length;
  int get totalActividades => permisosActividades.length;

 Future<void> cargarPermisos(String personalId, String? token) async {
  if (personalId.isEmpty) return;

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _permisos = await _permissionService.getPermisosByPersonal(personalId, token);
    
    // Intenta cargar activos, pero no bloquea si falla
    try {
      _permisosActivos = await _permissionService.getPermisosActivos(personalId, token);
    } catch (e) {
      debugPrint('[PermissionProvider] Endpoint activos falló, usando fallback: $e');
      // Fallback: filtrar de la lista completa
      _permisosActivos = _permisos.where((p) => p.estaActivo).toList();
    }

    // Si activos vino vacío pero hay permisos, también usar fallback
    if (_permisosActivos.isEmpty && _permisos.isNotEmpty) {
      debugPrint('[PermissionProvider] Activos vacío, aplicando fallback local');
      _permisosActivos = _permisos.where((p) => p.estaActivo).toList();
    }

    debugPrint('[PermissionProvider] Permisos activos: ${_permisosActivos.length}');
    debugPrint('[PermissionProvider] Total permisos: ${_permisos.length}');
  } catch (e) {
    _error = 'Error al cargar permisos: $e';
    debugPrint('[PermissionProvider] Error: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> refrescarPermisos(String personalId, String? token) async {
    await cargarPermisos(personalId, token);
  }

  /// Solicitar acceso a habitacion o actividad
  Future<Map<String, dynamic>> solicitarAcceso({
    required String personalId,
    String? token,
    int? habitacionId,
    int? actividadId,
    String? justificacion,
    DateTime? fechaExpiracion,
    bool esTemporal = true,
  }) async {
    final resultado = await _permissionService.solicitarAcceso(
      personalId: personalId,
      token: token,
      habitacionId: habitacionId,
      actividadId: actividadId,
      justificacion: justificacion,
      fechaExpiracion: fechaExpiracion,
      esTemporal: esTemporal,
    );

    if (resultado['exitoso'] == true) {
      await cargarPermisos(personalId, token);
    }

    return resultado;
  }

  /// Abrir puerta de habitacion
  Future<Map<String, dynamic>> abrirPuerta(int habitacionId, String? token) async {
    return await _permissionService.abrirPuerta(habitacionId, token);
  }

  void limpiar() {
    _permisos = [];
    _permisosActivos = [];
    _error = null;
    notifyListeners();
  }
}