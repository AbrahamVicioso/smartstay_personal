import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/permission_provider.dart';
import 'dashboard_screen.dart' show DashboardScreen, DashboardScreenState;
import 'tareas_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'nfc_unlock_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  late final List<Widget> _screens = [
    DashboardScreen(key: _dashboardKey),
    const TareasScreen(),
    HistoryScreen(key: _historyKey),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 0) _dashboardKey.currentState?.recargar();
    if (index == 2) _historyKey.currentState?.recargar();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: Consumer<PermissionProvider>(
        builder: (context, permisos, _) {
          if (permisos.permisosHabitaciones.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NfcUnlockScreen()),
              );
            },
            backgroundColor: AppTheme.navyBlue,
            child: const Icon(Icons.nfc, color: Colors.white, size: 28),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppTheme.navyBlue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home,         label: 'Inicio',    index: 0),
              _buildNavItem(icon: Icons.task_alt,     label: 'Tareas',    index: 1),
              const SizedBox(width: 48),
              _buildNavItem(icon: Icons.history,      label: 'Historial', index: 2),
              _buildNavItem(icon: Icons.person,       label: 'Perfil',    index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}