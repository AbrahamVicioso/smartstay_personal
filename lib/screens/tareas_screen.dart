import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/permiso_personal.dart';
import '../providers/auth_provider.dart';
import '../providers/permission_provider.dart';
import 'nfc_unlock_screen.dart';
import 'permiso_detail_screen.dart';

enum _Filtro { todas, habitaciones, actividades, temporales }

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  _Filtro _filtroActual = _Filtro.todas;

  List<PermisoPersonal> _filtrar(List<PermisoPersonal> lista) {
    switch (_filtroActual) {
      case _Filtro.habitaciones:
        return lista.where((p) => p.tieneHabitacion).toList();
      case _Filtro.actividades:
        return lista.where((p) => p.tieneActividad).toList();
      case _Filtro.temporales:
        return lista.where((p) => p.esTemporal).toList();
      case _Filtro.todas:
        return lista;
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final permisos = context.read<PermissionProvider>();
    final id = auth.empleado?.personalId?.toString() ?? '';
    if (id.isNotEmpty) await permisos.cargarPermisos(id, auth.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<AuthProvider, PermissionProvider>(
        builder: (context, auth, permProvider, _) {
          final permisos = _filtrar(permProvider.permisosActivos);
          final total = permProvider.permisosActivos.length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con contador
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Hoy, ${DateFormat('d MMM', 'es').format(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.navyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$total tareas',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filtros tipo chip
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      _chip('Todas', _Filtro.todas),
                      const SizedBox(width: 8),
                      _chip('Habitaciones', _Filtro.habitaciones),
                      const SizedBox(width: 8),
                      _chip('Actividades', _Filtro.actividades),
                      const SizedBox(width: 8),
                      _chip('Temporales', _Filtro.temporales),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista
                Expanded(
                  child: permProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : permisos.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: permisos.length,
                          itemBuilder: (ctx, i) => _TareaCard(
                            permiso: permisos[i],
                            onAcceder: () => _irANfc(permisos[i]),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _irANfc(PermisoPersonal permiso) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PermisoDetailScreen(permiso: permiso)),
    );
  }

  Widget _chip(String label, _Filtro filtro) {
    final selected = _filtroActual == filtro;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filtroActual = filtro),
      selectedColor: AppTheme.navyBlue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.navyBlue,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppTheme.navyBlue.withOpacity(0.08),
      checkmarkColor: Colors.white,
      side: BorderSide(color: AppTheme.navyBlue.withOpacity(0.3)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: AppTheme.corporateGray.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay tareas en esta categoría',
            style: TextStyle(color: AppTheme.corporateGray, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─── Card de tarea ────────────────────────────────────────────────────────────
class _TareaCard extends StatelessWidget {
  final PermisoPersonal permiso;
  final VoidCallback onAcceder;

  const _TareaCard({required this.permiso, required this.onAcceder});

  @override
  Widget build(BuildContext context) {
    final esHabitacion = permiso.tieneHabitacion;
    final color = esHabitacion ? AppTheme.navyBlue : AppTheme.statusGreen;
    final icon = esHabitacion ? Icons.hotel : Icons.event;

    // Badge de tipo temporal
    final bool temporal = permiso.esTemporal;

    // Fecha expiración legible
    String? expira;
    if (permiso.fechaExpiracion != null) {
      expira =
          'Vence ${DateFormat('dd/MM HH:mm', 'es').format(permiso.fechaExpiracion!.toLocal())}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 5)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: icono + habitación + badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permiso.descripcion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      if (permiso.piso != null)
                        Text(
                          'Piso ${permiso.piso}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge temporal
                if (temporal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'Temporal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Justificación / descripción
            if (permiso.justificacion != null &&
                permiso.justificacion!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                permiso.justificacion!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.corporateGray,
                ),
              ),
            ],

            // Fecha expiración
            if (expira != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    expira,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Botón Acceder (solo habitaciones tienen NFC)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: permiso.tieneHabitacion ? onAcceder : null,
                icon: Icon(
                  permiso.tieneHabitacion ? Icons.nfc : Icons.event_available,
                  size: 18,
                ),
                label: Text(permiso.tieneHabitacion ? 'Ver' : 'ACTIVIDAD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: color.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
