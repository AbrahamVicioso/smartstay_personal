import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/request.dart';
import '../providers/request_provider.dart';
import '../config/theme.dart';

class RequestDetailScreen extends StatelessWidget {
  final ServiceRequest request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habitación ${request.roomNumber}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Guest Information
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'INFORMACIÓN DEL HUÉSPED',
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
                      Icons.person,
                      'Huésped',
                      request.guestName,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.hotel,
                      'Habitación',
                      request.roomNumber,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha',
                      DateFormat('dd/MM/yyyy').format(request.requestedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Request Information
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SOLICITUD',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(request.type),
                          color: AppTheme.navyBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getTypeName(request.type),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.corporateGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPriorityBadge(request.priority),
                      ],
                    ),
                    if (request.notes != null) ...[
                      const Divider(height: 24),
                      const Text(
                        'Notas:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.corporateGray,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Solicitado: ${DateFormat('HH:mm').format(request.requestedAt)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (request.status != RequestStatus.completed) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => _completeRequest(context),
                  child: const Text('MARCAR COMO COMPLETADA'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implementar asistencia
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitando asistencia...'),
                        backgroundColor: AppTheme.statusYellow,
                      ),
                    );
                  },
                  child: const Text('REQUIERE ASISTENCIA'),
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
      children: [
        Icon(icon, color: AppTheme.navyBlue, size: 24),
        const SizedBox(width: 12),
        Column(
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
      ],
    );
  }

  Widget _buildPriorityBadge(RequestPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case RequestPriority.urgent:
        color = AppTheme.statusRed;
        text = 'Urgente';
        break;
      case RequestPriority.normal:
        color = AppTheme.statusYellow;
        text = 'Normal';
        break;
      case RequestPriority.low:
        color = AppTheme.statusGreen;
        text = 'Baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _getTypeIcon(RequestType type) {
    switch (type) {
      case RequestType.towels:
        return Icons.bathroom;
      case RequestType.roomService:
        return Icons.room_service;
      case RequestType.cleaning:
        return Icons.cleaning_services;
      case RequestType.maintenance:
        return Icons.build;
      case RequestType.amenities:
        return Icons.shopping_bag;
      case RequestType.other:
        return Icons.help_outline;
    }
  }

  String _getTypeName(RequestType type) {
    switch (type) {
      case RequestType.towels:
        return 'Toallas';
      case RequestType.roomService:
        return 'Room Service';
      case RequestType.cleaning:
        return 'Limpieza';
      case RequestType.maintenance:
        return 'Mantenimiento';
      case RequestType.amenities:
        return 'Amenidades';
      case RequestType.other:
        return 'Otro';
    }
  }

  Future<void> _completeRequest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Solicitud'),
        content: const Text('¿Está seguro de marcar esta solicitud como completada?'),
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

    if (confirmed == true && context.mounted) {
      final success = await context.read<RequestProvider>().updateRequestStatus(
            request.id,
            RequestStatus.completed,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Solicitud marcada como completada'),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
