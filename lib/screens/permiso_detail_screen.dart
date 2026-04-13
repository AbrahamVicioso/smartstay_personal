import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/permiso_personal.dart';
import '../providers/permission_provider.dart';
import '../config/theme.dart';

class PermisoDetailScreen extends StatelessWidget {
  final PermisoPersonal permiso;

  const PermisoDetailScreen({super.key, required this.permiso});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(permiso.descripcion),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Informacion del Permiso
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'INFORMACION DEL PERMISO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLight,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(
                      permiso.tieneHabitacion ? Icons.hotel : Icons.event,
                      'Tipo',
                      permiso.tipoPermiso,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.description,
                      'Descripcion',
                      permiso.descripcion,
                    ),
                    if (permiso.piso != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.layers,
                        'Piso',
                        '${permiso.piso}',
                      ),
                    ],
                    if (permiso.justificacion != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.notes,
                        'Justificacion',
                        permiso.justificacion!,
                      ),
                    ],
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.check_circle,
                      'Estado',
                      permiso.estaActivo ? 'Activo' : 'Inactivo',
                    ),
                    if (permiso.fechaExpiracion != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.schedule,
                        'Expira',
                        DateFormat('dd/MM/yyyy HH:mm').format(permiso.fechaExpiracion!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Boton Abrir Puerta (solo si es habitacion)
            if (permiso.tieneHabitacion && permiso.estaActivo) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirPuerta(context),
                    icon: const Icon(Icons.lock_open, size: 24),
                    label: const Text('ABRIR PUERTA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.statusGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Boton Marcar como Completada
            if (permiso.estaActivo) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _marcarCompletado(context),
                    icon: const Icon(Icons.check),
                    label: const Text('MARCAR TAREA COMPLETADA'),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.navyBlue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

 Future<void> _abrirPuerta(BuildContext context) async {
  if (permiso.habitacionId == null) return;

  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Abrir Puerta'),
      content: Text('Esta a punto de abrir la puerta de la ${permiso.descripcion}. Continuar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusGreen),
          child: const Text('ABRIR'),
        ),
      ],
    ),
  );

  if (confirmar != true || !context.mounted) return;

  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Abriendo puerta...'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    // CORREGIDO: Obtener token del AuthProvider
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    
    final resultado = await context.read<PermissionProvider>().abrirPuerta(
      permiso.habitacionId!,
      token,
    );

    if (context.mounted) {
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                resultado['exitoso'] == true ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(resultado['mensaje'] ?? 'Operacion completada')),
            ],
          ),
          backgroundColor: resultado['exitoso'] == true
              ? AppTheme.statusGreen
              : AppTheme.statusRed,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.statusRed,
        ),
      );
    }
  }
}

  Future<void> _marcarCompletado(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Tarea'),
        content: const Text('Marcar esta tarea como completada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('COMPLETAR'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      // TODO: Implementar logica para marcar completado en el backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea marcada como completada'),
          backgroundColor: AppTheme.statusGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}