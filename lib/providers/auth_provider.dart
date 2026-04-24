import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
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

  // Estado 2FA
  bool _requiresTwoFactor = false;
  String? _pendingEmail;

  // Getters
  String? get token => _token;
  User? get user => _user;
  Employee? get empleado => _empleado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get requiresTwoFactor => _requiresTwoFactor;
  String? get pendingEmail => _pendingEmail;
  String? get personalId => _empleado?.personalId;
  String? get nombreCompleto => _empleado?.nombreCompleto;
  int? get puestoId => _empleado?.puestoId;
  int? get departamentoId => _empleado?.departamentoId;

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _requiresTwoFactor = false;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result.status == LoginStatus.requiresTwoFactor) {
        _pendingEmail = email;
        _requiresTwoFactor = true;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.status == LoginStatus.emailNotConfirmed) {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!result.isSuccess) {
        _errorMessage = result.errorMessage ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      return await _finishLogin(result);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── 2FA ──────────────────────────────────────────────────────────────────

  Future<void> send2FACode() async {
    if (_pendingEmail == null) return;
    try {
      await _authService.send2FACode(_pendingEmail!);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> verify2FA(String code) async {
    if (_pendingEmail == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verify2FA(_pendingEmail!, code);
      return await _finishLogin(result);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void cancel2FA() {
    _requiresTwoFactor = false;
    _pendingEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      _token = await _authService.getAccessToken();

      _user = await _authService.getUserInfo();

      if (_user == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _token = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final empleado = await _authService.getEmpleado(_user!.id, _user!.email);

      if (empleado == null) {
        await _authService.logout();
        _user = null;
        _empleado = null;
        _token = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _empleado = empleado;
    } else {
      _user = null;
      _empleado = null;
      _token = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _empleado = null;
    _token = null;
    _requiresTwoFactor = false;
    _pendingEmail = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<bool> _finishLogin(AuthResponse result) async {
    _token = result.accessToken;
    _requiresTwoFactor = false;
    _pendingEmail = null;

    _user = await _authService.getUserInfo();
    if (_user == null) {
      _errorMessage = 'No se pudo obtener la información del usuario';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final empleado = await _authService.getEmpleado(_user!.id, _user!.email);
    if (empleado == null) {
      await _authService.logout();
      _user = null;
      _errorMessage = 'No tienes acceso a esta aplicación';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _empleado = empleado;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
