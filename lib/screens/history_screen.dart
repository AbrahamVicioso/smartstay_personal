import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/request_provider.dart';
import '../models/request.dart';
import '../config/theme.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            color: AppTheme.lightBlue,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.navyBlue),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEEE', 'es').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.corporateGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMMM yyyy', 'es').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.navyBlue),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppTheme.navyBlue),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),

          // Statistics
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Consumer<RequestProvider>(
              builder: (context, requestProvider, child) {
                final completedRequests = requestProvider.requests
                    .where((r) => r.status == RequestStatus.completed)
                    .toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Total',
                      '${completedRequests.length}',
                      Icons.list,
                    ),
                    _buildStat(
                      'Tiempo Promedio',
                      _calculateAverageTime(completedRequests),
                      Icons.timer,
                    ),
                    _buildStat(
                      'Completadas',
                      '${completedRequests.length}',
                      Icons.check_circle,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Completed Requests List
          Expanded(
            child: Consumer<RequestProvider>(
              builder: (context, requestProvider, child) {
                final completedRequests = requestProvider.requests
                    .where((r) => r.status == RequestStatus.completed)
                    .toList();

                if (completedRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppTheme.corporateGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay solicitudes completadas',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.corporateGray,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: completedRequests.length,
                  itemBuilder: (context, index) {
                    final request = completedRequests[index];
                    return RequestCard(
                      request: request,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RequestDetailScreen(request: request),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.navyBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.navyBlue,
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

  String _calculateAverageTime(List<ServiceRequest> requests) {
    if (requests.isEmpty) return '0 min';

    int totalMinutes = 0;
    int count = 0;

    for (final request in requests) {
      if (request.completedAt != null) {
        final duration = request.completedAt!.difference(request.requestedAt);
        totalMinutes += duration.inMinutes;
        count++;
      }
    }

    if (count == 0) return '0 min';

    final average = (totalMinutes / count).round();
    return '$average min';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.navyBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
