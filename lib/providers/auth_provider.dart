import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/employee.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Employee? _empleado;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Employee? get empleado => _empleado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String? get personalId => _empleado?.personalId;
  String? get nombreCompleto => _empleado?.nombreCompleto;
  String? get puesto => _empleado?.puesto;
  String? get departamento => _empleado?.departamento;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      _user = await _authService.getUserInfo();
      
      // Verificar si se obtuvo el usuario correctamente
      if (_user == null) {
        _errorMessage = "No se pudo obtener la información del usuario";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validar si el usuario es empleado
      final user = _user;

if (user == null) {
  _errorMessage = "No se pudo obtener la información del usuario";
  _isLoading = false;
  notifyListeners();
  return false;
}

final empleado = await _authService.getEmpleado(user.id, user.email);
      if (empleado == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _errorMessage = "No tienes acceso a esta aplicación";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _empleado = empleado;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      _user = await _authService.getUserInfo();
      
      // Verificar si se obtuvo el usuario correctamente
      if (_user == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Validar si el usuario es empleado
      final user = _user;

if (user == null) {
  await _authService.logout();
  _user = null;
  _empleado = null;
  _isLoading = false;
  notifyListeners();
  return;
}

final empleado = await _authService.getEmpleado(user.id, user.email);
      if (empleado == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      _empleado = empleado;
    } else {
      // No hay sesión, limpiar datos
      _user = null;
      _empleado = null;
      notifyListeners(); // Agregar notificación
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _empleado = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
