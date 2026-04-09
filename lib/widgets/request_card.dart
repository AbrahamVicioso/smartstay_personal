import 'package:flutter/material.dart';
import '../models/request.dart';
import '../config/theme.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getPriorityColor(request.priority),
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
                    _getTypeIcon(request.type),
                    color: AppTheme.navyBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hab. ${request.roomNumber} - ${request.description}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.guestName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.corporateGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.getTimeAgo(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    const Text(
                      'ATENDER',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case RequestStatus.completed:
        backgroundColor = AppTheme.statusGreen;
        text = 'Completada';
        break;
      case RequestStatus.inProgress:
        backgroundColor = AppTheme.statusYellow;
        text = 'En proceso';
        break;
      case RequestStatus.pending:
        backgroundColor = AppTheme.statusRed;
        text = 'Pendiente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
      ),
    );
  }

  Color _getPriorityColor(RequestPriority priority) {
    switch (priority) {
      case RequestPriority.urgent:
        return AppTheme.statusRed;
      case RequestPriority.normal:
        return AppTheme.statusYellow;
      case RequestPriority.low:
        return AppTheme.statusGreen;
    }
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
}
