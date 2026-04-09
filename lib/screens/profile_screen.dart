import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile Header
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.lightBlue,
                      child: user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoUrl!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 48,
                              color: AppTheme.navyBlue,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.corporateGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        user?.department ?? 'Personal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Statistics
            Consumer<RequestProvider>(
              builder: (context, requestProvider, child) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas Personales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Pendientes',
                              '${requestProvider.pendingCount}',
                              AppTheme.statusRed,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppTheme.corporateGray.withOpacity(0.2),
                            ),
                            _buildStatItem(
                              'En Proceso',
                              '${requestProvider.inProgressCount}',
                              AppTheme.statusYellow,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppTheme.corporateGray.withOpacity(0.2),
                            ),
                            _buildStatItem(
                              'Completadas',
                              '${requestProvider.completedCount}',
                              AppTheme.statusGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Settings Options
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Gestionar alertas y sonidos',
                    onTap: () {
                      // TODO: Implementar configuración de notificaciones
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.nfc,
                    title: 'Configuración NFC',
                    subtitle: 'Configurar acceso a puertas',
                    onTap: () {
                      // TODO: Implementar configuración NFC
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.language,
                    title: 'Idioma',
                    subtitle: 'Español',
                    onTap: () {
                      // TODO: Implementar cambio de idioma
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    subtitle: 'Versión ${AppConstants.appVersion}',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationIcon: const Icon(
                          Icons.hotel,
                          size: 48,
                          color: AppTheme.navyBlue,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () => _handleLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.statusRed,
                  side: const BorderSide(color: AppTheme.statusRed, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.corporateGray,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.navyBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.navyBlue,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.corporateGray,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.corporateGray),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRed,
            ),
            child: const Text('CERRAR SESIÓN'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
