import 'package:flutter/material.dart';
import '../services/nfc_service.dart';
import '../config/theme.dart';

class NfcUnlockScreen extends StatefulWidget {
  const NfcUnlockScreen({super.key});

  @override
  State<NfcUnlockScreen> createState() => _NfcUnlockScreenState();
}

class _NfcUnlockScreenState extends State<NfcUnlockScreen>
    with SingleTickerProviderStateMixin {
  final NfcService _nfcService = NfcService();
  bool _isScanning = false;
  bool _isAvailable = false;
  String _statusMessage = 'Iniciando NFC...';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initNfc();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initNfc() async {
    try {
      await _nfcService.initialize();
      setState(() {
        _isAvailable = _nfcService.isAvailable;
        _statusMessage = _isAvailable
            ? 'Toque el botón para escanear una puerta'
            : 'NFC no está disponible en este dispositivo';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al inicializar NFC: $e';
      });
    }
  }

  Future<void> _startScanning() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC no está disponible'),
          backgroundColor: AppTheme.statusRed,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Acerque el dispositivo a la puerta...';
    });

    try {
      final tagId = await _nfcService.readNfcTag();

      if (tagId != null && mounted) {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Puerta desbloqueada correctamente';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Puerta desbloqueada'),
            backgroundColor: AppTheme.statusGreen,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _statusMessage = 'Toque el botón para escanear una puerta';
          });
        }
      } else {
        setState(() {
          _isScanning = false;
          _statusMessage = 'No se pudo leer la tarjeta NFC';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Error al leer NFC: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.statusRed,
          ),
        );
      }
    }
  }

  void _cancelScanning() {
    _nfcService.stopSession(errorMessage: 'Escaneo cancelado');
    setState(() {
      _isScanning = false;
      _statusMessage = 'Escaneo cancelado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.navyBlue,
              AppTheme.navyBlueDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Desbloquear Puerta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // NFC Icon with Animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: _isScanning
                                    ? Colors.white.withOpacity(_animationController.value)
                                    : Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.nfc,
                                size: 80,
                                color: _isScanning
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 48),

                      // Status Message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Action Button
                      if (_isAvailable) ...[
                        if (!_isScanning)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _startScanning,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.navyBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.nfc),
                                    SizedBox(width: 8),
                                    Text(
                                      'Escanear Puerta',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: _cancelScanning,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Instructions
              Container(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instrucciones',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInstruction('1. Toque el botón "Escanear Puerta"'),
                        _buildInstruction('2. Acerque el dispositivo a la cerradura NFC'),
                        _buildInstruction('3. Espere la confirmación de desbloqueo'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
