// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/registro_acceso.dart';
import '../providers/auth_provider.dart';
import '../services/history_service.dart';
import '../config/route_observer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _service = HistoryService();
  List<RegistroAcceso> _registros = [];
  bool _isLoading = true;
  bool _hasNextPage = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

   void recargar() => _cargar(reset: true);

  Future<void> _cargar({bool reset = false}) async {
    if (!mounted) return;

    int pagina = _currentPage;

    if (reset) {
      pagina = 1;
      setState(() {
        _currentPage = 1;
        _registros = [];
        _isLoading = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final auth = context.read<AuthProvider>();
    final usuarioId = auth.empleado?.usuarioId ?? '';
    final token = auth.token;

    debugPrint('[HistoryScreen] cargando página $pagina para $usuarioId');

    final result = await _service.getRegistrosByUsuario(
      usuarioId,
      token: token,
      page: pagina,
    );

    if (!mounted) return;

    final nuevos = result['items'] as List<RegistroAcceso>;

    setState(() {
      if (reset) {
        _registros = nuevos; // reemplazar, no concatenar
      } else {
        _registros = [
          ..._registros,
          ...nuevos,
        ]; // solo concatenar en "cargar más"
      }
      _hasNextPage = result['hasNextPage'] as bool;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Accesos')),
      body: RefreshIndicator(
        onRefresh: () => _cargar(reset: true),
        child: _isLoading && _registros.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _registros.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                itemCount: _registros.length + (_hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _registros.length) {
                    return _buildLoadMore();
                  }
                  return _buildCard(_registros[index]);
                },
              ),
      ),
    );
  }

  Widget _buildCard(RegistroAcceso r) {
    final color = r.fueExitoso ? AppTheme.statusGreen : AppTheme.statusRed;
    final icon = r.fueExitoso ? Icons.lock_open : Icons.lock;
    final fecha = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(r.fechaHoraAcceso.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.motivoAcceso,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r.resultadoAcceso,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: () {
            setState(() => _currentPage++);
            _cargar();
          },
          child: const Text('Cargar más'),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.corporateGray.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay registros de acceso',
            style: TextStyle(color: AppTheme.corporateGray),
          ),
        ],
      ),
    );
  }
}
