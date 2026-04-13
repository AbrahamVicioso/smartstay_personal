import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../services/lock_service.dart';
import '../services/permission_service.dart';

class RoomProvider with ChangeNotifier {
  final LockService _lockService = LockService();
  final PermissionService _permissionService = PermissionService();

  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _filterEstado;

  List<Room> get rooms => _filteredRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get filterEstado => _filterEstado;

  Future<void> loadRooms({int? hotelId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _lockService.getRooms(hotelId: hotelId);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRooms() async {
    await loadRooms();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterEstado(String? estado) {
    _filterEstado = estado;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRooms = _rooms;

    if (_filterEstado != null && _filterEstado!.isNotEmpty) {
      _filteredRooms = _filteredRooms
          .where((r) => r.estado == _filterEstado)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredRooms = _filteredRooms.where((r) {
        return r.numeroHabitacion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (r.guestName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            r.tipoHabitacion.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<Map<String, dynamic>> unlockDoor(Room room, String motivo) async {
    if (room.cerraduraId == null) {
      return {
        'exitoso': false,
        'mensaje': 'Esta habitación no tiene cerradura inteligente',
      };
    }

    try {
      final resultado = await _lockService.unlockDoor(
        cerraduraId: room.cerraduraId!,
        habitacionId: room.habitacionId,
        numeroHabitacion: room.numeroHabitacion,
        motivo: motivo,
      );

      // Actualizar el estado local de la habitación
      if (resultado['exitoso'] == true) {
        await refreshRooms();
      }

      return resultado;
    } catch (e) {
      return {
        'exitoso': false,
        'mensaje': 'Error: $e',
      };
    }
  }

  Room? getRoomById(int habitacionId) {
    try {
      return _rooms.firstWhere((r) => r.habitacionId == habitacionId);
    } catch (e) {
      return null;
    }
  }

  int get totalRooms => _rooms.length;
  int get occupiedRooms => _rooms.where((r) => r.estado == 'Ocupada').length;
  int get availableRooms => _rooms.where((r) => r.estaDisponible).length;
  int get cleaningRooms => _rooms.where((r) => r.estado == 'Limpieza').length;

  Future<Map<String, dynamic>> requestAccess({
    required String personalId, // <--- CAMBIAR DE int A String
    required int habitacionId,
    required String motivo,
  }) async {
    try {
      final resultado = await _permissionService.solicitarAcceso(
        personalId: personalId, // Ahora ambos son String y Dart estará feliz
        habitacionId: habitacionId,
        justificacion: motivo,
      );

      return resultado;
    } catch (e) {
      return {
        'exitoso': false,
        'mensaje': 'Error: $e',
      };
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
