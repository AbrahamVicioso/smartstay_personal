import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'dashboard_screen.dart';
import 'rooms_screen.dart';
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

final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();


  late final List<Widget> _screens = [
    const DashboardScreen(),
    HistoryScreen(key: _historyKey),   // <-- agrega la key aquí
    const RoomsScreen(),
    const ProfileScreen(),
  ];

   void _onTabTapped(int index) {
    // Si ya estás en historial y lo tocas de nuevo, recarga
    // Si navegas AL historial desde otro tab, también recarga
    if (index == 1) {
      _historyKey.currentState?.recargar();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NfcUnlockScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.navyBlue,
        child: const Icon(Icons.nfc, color: Colors.white, size: 28),
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
              _buildNavItem(
                icon: Icons.home,
                label: 'Inicio',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'Historial',
                index: 1,
              ),
              const SizedBox(width: 48), // Espacio para FAB
              _buildNavItem(
                icon: Icons.hotel,
                label: 'Habitaciones',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Perfil',
                index: 3,
              ),
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
        onTap: () => _onTabTapped(index), // <-- usa el nuevo método
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