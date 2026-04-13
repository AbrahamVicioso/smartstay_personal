import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../providers/auth_provider.dart';
import '../models/permiso_personal.dart';
import '../config/theme.dart';
import 'permiso_detail_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarPermisos();
    });
  }

  Future<void> _cargarPermisos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
  
  final personalId = authProvider.empleado?.personalId?.toString() ?? '';
  final token = authProvider.token;
  
  debugPrint('[v0] Dashboard - personalId: $personalId');
  debugPrint('[v0] Dashboard - token: ${token?.substring(0, 20)}...');
  
  if (personalId.isNotEmpty) {
    await permissionProvider.cargarPermisos(personalId, token);
    debugPrint('[v0] Dashboard - permisos cargados: ${permissionProvider.permisosActivos.length}');
  } else {
    debugPrint('[v0] Dashboard - ERROR: personalId vacio!');
  }
  }

  Future<void> _refreshData() async {
    await _cargarPermisos();
  }

  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.hotel, size: 24, color: AppTheme.navyBlue),
            const SizedBox(width: 8),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer2<AuthProvider, PermissionProvider>(
          builder: (context, authProvider, permissionProvider, child) {
            if (permissionProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Welcome Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Hola, ${authProvider.nombreCompleto ?? 'Usuario'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildNavigationCard(
                            context,
                            icon: Icons.history,
                            title: 'Historial',
                            onTap: _navigateToHistory,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNavigationCard(
                            context,
                            icon: Icons.person,
                            title: 'Perfil',
                            onTap: _navigateToProfile,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.hotel,
                            title: 'Habitaciones',
                            count: '${permissionProvider.totalHabitaciones}',
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.event,
                            title: 'Actividades',
                            count: '${permissionProvider.totalActividades}',
                            color: AppTheme.statusGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mis Permisos Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Mis Tareas / Permisos Activos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Permisos List
                  if (permissionProvider.permisosActivos.isNotEmpty)
                    ...permissionProvider.permisosActivos.map((permiso) =>
                        _buildPermisoCard(permiso))
                  else
                    _buildEmptyState(),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navyBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppTheme.navyBlue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.navyBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermisoCard(PermisoPersonal permiso) {
    final bool esHabitacion = permiso.tieneHabitacion;
    final Color cardColor = esHabitacion ? AppTheme.navyBlue : AppTheme.statusGreen;
    final IconData icon = esHabitacion ? Icons.hotel : Icons.event;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PermisoDetailScreen(permiso: permiso),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: cardColor, width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cardColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permiso.descripcion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permiso.justificacion ?? permiso.tipoPermiso,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.corporateGray,
                      ),
                    ),
                    if (permiso.piso != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Piso ${permiso.piso}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.corporateGray.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: AppTheme.statusGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes tareas o permisos asignados',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.corporateGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

  }

  
}