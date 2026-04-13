import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/employee.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Employee? _empleado;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  User? get user => _user;
  Employee? get empleado => _empleado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String? get personalId => _empleado?.personalId;
  String? get nombreCompleto => _empleado?.nombreCompleto;
  int? get puestoId => _empleado?.puestoId;
  int? get departamentoId => _empleado?.departamentoId;

Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
   
    final authResponse = await _authService.login(email, password);
    
  
    _token = authResponse.accessToken;
      _user = await _authService.getUserInfo();
      
      if (_user == null) {
        _errorMessage = "No se pudo obtener la información del usuario";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final currentUser = _user;

if (currentUser == null) {
  _errorMessage = "No se pudo obtener la información del usuario";
  _isLoading = false;
  notifyListeners();
  return false;
}

final empleado = await _authService.getEmpleado(
  currentUser.id,
  currentUser.email,
);
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      
      if (_user == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final currentUser = _user;

if (currentUser == null) {
  _errorMessage = "No se pudo obtener la información del usuario";
  _isLoading = false;
  notifyListeners();
  return;
}

final empleado = await _authService.getEmpleado(
  currentUser.id,
  currentUser.email,
);

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
      _user = null;
      _empleado = null;
      notifyListeners();
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
