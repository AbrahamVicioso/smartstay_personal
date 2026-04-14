import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/nfc_service.dart';
import '../config/theme.dart';
import '../models/permiso_personal.dart';
import '../providers/auth_provider.dart';

// Estados de la pantalla
enum _NfcState { idle, scanning, success, error }

class NfcUnlockScreen extends StatefulWidget {
  /// Si viene desde una tarea específica, se pasa el permiso.
  /// Si viene desde el FAB global, permiso es null.
  final PermisoPersonal? permiso;

  const NfcUnlockScreen({super.key, this.permiso});

  @override
  State<NfcUnlockScreen> createState() => _NfcUnlockScreenState();
}

class _NfcUnlockScreenState extends State<NfcUnlockScreen>
    with SingleTickerProviderStateMixin {
  final NfcService _nfcService = NfcService();
  _NfcState _state = _NfcState.idle;
  bool _isAvailable = false;
  String _errorMsg = '';
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initNfc();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _initNfc() async {
    try {
      await _nfcService.initialize();
      setState(() => _isAvailable = _nfcService.isAvailable);
    } catch (_) {
      setState(() => _isAvailable = false);
    }
  }

  Future<void> _startScanning() async {
    if (!_isAvailable) return;
    setState(() => _state = _NfcState.scanning);

    try {
      final tagId = await _nfcService.readNfcTag();

      if (!mounted) return;

      if (tagId != null) {
        HapticFeedback.heavyImpact();
        setState(() => _state = _NfcState.success);
        // Auto cerrar después de 2.5s
        await Future.delayed(const Duration(milliseconds: 2500));
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _state = _NfcState.error;
          _errorMsg = 'No se pudo leer el dispositivo NFC';
        });
        HapticFeedback.vibrate();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _NfcState.error;
        _errorMsg = e.toString();
      });
      HapticFeedback.vibrate();
    }
  }

  void _cancelar() {
    _nfcService.stopSession(errorMessage: 'Cancelado');
    setState(() => _state = _NfcState.idle);
  }

  void _reintentar() => setState(() => _state = _NfcState.idle);

  @override
  Widget build(BuildContext context) {
    final permiso = widget.permiso;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.navyBlue, AppTheme.navyBlueDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acceder a habitación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (permiso != null)
                            Text(
                              '${permiso.descripcion}${permiso.piso != null ? ' · Piso ${permiso.piso}' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info card del permiso (solo si viene con contexto) ────────
              if (permiso != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hotel, color: Colors.white70, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            permiso.justificacion ?? permiso.tipoPermiso,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        if (permiso.esTemporal)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Temporal',
                              style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // ── Zona central ──────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: _buildCentral(),
                ),
              ),

              // ── Botones de acción ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: _buildActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentral() {
    switch (_state) {
      case _NfcState.idle:
        return _buildIdle();
      case _NfcState.scanning:
        return _buildScanning();
      case _NfcState.success:
        return _buildSuccess();
      case _NfcState.error:
        return _buildError();
    }
  }

  Widget _buildIdle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.nfc, size: 80, color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Listo para escanear',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          _isAvailable
              ? 'Toca el botón y acerca el dispositivo\na la cerradura NFC'
              : 'NFC no disponible en este dispositivo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildScanning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            final v = _pulse.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180 + (v * 40),
                  height: 180 + (v * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(1 - v),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: const Center(
                    child: Icon(Icons.nfc, size: 80, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'Esperando NFC...',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Acerca el teléfono a la cerradura',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.statusGreen.withOpacity(0.2),
            border: Border.all(color: AppTheme.statusGreen, width: 3),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, size: 80, color: AppTheme.statusGreen),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Acceso concedido',
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Puerta abierta',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.statusRed.withOpacity(0.2),
            border: Border.all(color: AppTheme.statusRed, width: 3),
          ),
          child: const Center(
            child: Icon(Icons.lock_rounded, size: 80, color: AppTheme.statusRed),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Acceso denegado',
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMsg.isNotEmpty ? _errorMsg : 'No tienes permiso para este acceso',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75)),
        ),
      ],
    );
  }

  Widget _buildActions() {
    switch (_state) {
      case _NfcState.idle:
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isAvailable ? _startScanning : null,
            icon: const Icon(Icons.nfc),
            label: const Text('Escanear Puerta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.navyBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
            ),
          ),
        );

      case _NfcState.scanning:
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _cancelar,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        );

      case _NfcState.success:
        return const SizedBox.shrink(); // Auto cierra

      case _NfcState.error:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _reintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de nuevo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.navyBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ],
        );
    }
  }
}