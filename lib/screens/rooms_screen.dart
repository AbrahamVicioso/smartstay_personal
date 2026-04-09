import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/room_provider.dart';
import '../models/room.dart';
import '../config/theme.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _unlockDoor(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_open, color: AppTheme.navyBlue),
            const SizedBox(width: 12),
            Text('Abrir Habitación ${room.numeroHabitacion}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Desea abrir la puerta de la habitación ${room.numeroHabitacion}?'),
            const SizedBox(height: 12),
            if (room.guestName != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Huésped: ${room.guestName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, size: 18),
                SizedBox(width: 4),
                Text('ABRIR'),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Mostrar indicador de carga
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
        final resultado = await context.read<RoomProvider>().unlockDoor(
              room,
              'Acceso Personal',
            );

        if (mounted) {
          Navigator.of(context).pop(); // Cerrar indicador de carga

          final color = resultado['exitoso'] == true
              ? AppTheme.statusGreen
              : AppTheme.statusRed;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    resultado['exitoso'] == true ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(resultado['mensaje'] ?? 'Operación completada'),
                  ),
                ],
              ),
              backgroundColor: color,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar indicador de carga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.statusRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitaciones'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar habitación, huésped...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              context.read<RoomProvider>().setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<RoomProvider>().setSearchQuery(value);
                  },
                ),
              ),

              // Filter Pills
              Consumer<RoomProvider>(
                builder: (context, roomProvider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'Todas',
                          roomProvider.filterEstado == null,
                          () => roomProvider.setFilterEstado(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Ocupadas',
                          roomProvider.filterEstado == 'Ocupada',
                          () => roomProvider.setFilterEstado('Ocupada'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Disponibles',
                          roomProvider.filterEstado == 'Disponible',
                          () => roomProvider.setFilterEstado('Disponible'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Limpieza',
                          roomProvider.filterEstado == 'Limpieza',
                          () => roomProvider.setFilterEstado('Limpieza'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Consumer<RoomProvider>(
        builder: (context, roomProvider, child) {
          if (roomProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.navyBlue),
              ),
            );
          }

          if (roomProvider.rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_outlined,
                    size: 64,
                    color: AppTheme.corporateGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron habitaciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.corporateGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: roomProvider.refreshRooms,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: roomProvider.rooms.length,
              itemBuilder: (context, index) {
                final room = roomProvider.rooms[index];
                return _buildRoomCard(room);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.navyBlue : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    Color statusColor;
    IconData statusIcon;

    switch (room.estado) {
      case 'Ocupada':
        statusColor = AppTheme.statusRed;
        statusIcon = Icons.person;
        break;
      case 'Disponible':
        statusColor = AppTheme.statusGreen;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Limpieza':
        statusColor = AppTheme.statusYellow;
        statusIcon = Icons.cleaning_services;
        break;
      default:
        statusColor = AppTheme.corporateGray;
        statusIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hotel,
                  color: AppTheme.navyBlue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Habitación ${room.numeroHabitacion}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (room.tieneCerradura)
                            Icon(
                              room.estaCerrada ? Icons.lock : Icons.lock_open,
                              size: 16,
                              color: room.estaCerrada
                                  ? AppTheme.navyBlue
                                  : AppTheme.statusGreen,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.tipoHabitacion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.corporateGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        room.estado,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (room.guestName != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppTheme.corporateGray),
                  const SizedBox(width: 8),
                  Text(
                    room.guestName!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.corporateGray,
                    ),
                  ),
                ],
              ),
              if (room.checkInDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        'Check-in: ${DateFormat('dd/MM/yyyy').format(room.checkInDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 12),

            // Botón de abrir puerta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: room.tieneCerradura
                    ? () => _unlockDoor(room)
                    : null,
                icon: const Icon(Icons.lock_open, size: 20),
                label: Text(
                  room.tieneCerradura
                      ? 'ABRIR PUERTA'
                      : 'SIN CERRADURA INTELIGENTE',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
