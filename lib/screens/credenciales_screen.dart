import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/credencial_acceso.dart';
import '../providers/auth_provider.dart';
import '../services/credencial_service.dart';

class CredencialesScreen extends StatefulWidget {
  const CredencialesScreen({super.key});

  @override
  State<CredencialesScreen> createState() => _CredencialesScreenState();
}

class _CredencialesScreenState extends State<CredencialesScreen> {
  final _service = CredencialService();
  List<CredencialAcceso> _credenciales = [];
  bool _isLoading = true;
  String? _error;
  final Set<int> _toggling = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final token = context.read<AuthProvider>().token ?? '';
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await _service.getMisCredenciales(token);
    if (!mounted) return;
    setState(() {
      _credenciales = result;
      _isLoading = false;
    });
  }

  Future<void> _toggle(CredencialAcceso cred) async {
    final token = context.read<AuthProvider>().token ?? '';
    setState(() => _toggling.add(cred.credencialId));

    final ok = await _service.toggleCredencial(token, cred.credencialId);

    if (!mounted) return;
    setState(() => _toggling.remove(cred.credencialId));

    if (ok) {
      await _cargar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cambiar estado de la credencial')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Credenciales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _cargar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _credenciales.isEmpty
                  ? const Center(child: Text('No tienes credenciales asignadas'))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _credenciales.length,
                        itemBuilder: (context, i) => _CredencialCard(
                          credencial: _credenciales[i],
                          toggling: _toggling.contains(_credenciales[i].credencialId),
                          onToggle: () => _toggle(_credenciales[i]),
                        ),
                      ),
                    ),
    );
  }
}

class _CredencialCard extends StatelessWidget {
  final CredencialAcceso credencial;
  final bool toggling;
  final VoidCallback onToggle;

  const _CredencialCard({
    required this.credencial,
    required this.toggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final activa = credencial.estaActiva;
    final expirada = credencial.expirada;

    Color statusColor;
    String statusLabel;
    if (expirada) {
      statusColor = AppTheme.textLight;
      statusLabel = 'Expirada';
    } else if (activa) {
      statusColor = AppTheme.statusGreen;
      statusLabel = 'Activa';
    } else {
      statusColor = AppTheme.statusRed;
      statusLabel = 'Inactiva';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${credencial.credencialId}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (credencial.tipoCredencial != null)
              _Row(
                icon: Icons.badge_outlined,
                label: 'Tipo',
                value: credencial.tipoCredencial!,
              ),
            if (credencial.codigoPin != null && credencial.codigoPin!.isNotEmpty)
              _Row(
                icon: Icons.pin_outlined,
                label: 'PIN',
                value: credencial.codigoPin!,
              ),
            if (credencial.numeroUsos != null)
              _Row(
                icon: Icons.repeat,
                label: 'Usos',
                value: '${credencial.numeroUsos}',
              ),
            if (credencial.fechaActivacion != null)
              _Row(
                icon: Icons.calendar_today_outlined,
                label: 'Activacion',
                value: _fmt(credencial.fechaActivacion!),
              ),
            if (credencial.fechaExpiracion != null)
              _Row(
                icon: Icons.event_busy_outlined,
                label: 'Expiracion',
                value: _fmt(credencial.fechaExpiracion!),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: expirada || toggling ? null : onToggle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: activa ? AppTheme.statusRed : AppTheme.statusGreen,
                  side: BorderSide(
                    color: activa ? AppTheme.statusRed : AppTheme.statusGreen,
                    width: 1.5,
                  ),
                  minimumSize: const Size(0, 40),
                ),
                child: toggling
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(activa ? 'Desactivar' : 'Activar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textLight),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
