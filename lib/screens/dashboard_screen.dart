import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../models/request.dart';
import '../config/theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';
import 'profile_screen.dart';

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
      context.read<RequestProvider>().loadRequests();
    });
  }

  Future<void> _refreshData() async {
    await context.read<RequestProvider>().refreshRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.hotel, size: 24),
            const SizedBox(width: 8),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<RequestProvider>(
          builder: (context, requestProvider, child) {
            if (requestProvider.isLoading) {
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

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            icon: Icons.pending_actions,
                            title: 'Pendientes',
                            count: '${requestProvider.pendingCount}',
                            color: AppTheme.statusRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            icon: Icons.check_circle_outline,
                            title: 'Completadas',
                            count: '${requestProvider.completedCount}',
                            color: AppTheme.statusGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Requests Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Solicitudes Activas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Active Requests List
                  ...requestProvider.requests
                      .where((r) => r.status != RequestStatus.completed)
                      .map((request) => RequestCard(
                            request: request,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RequestDetailScreen(request: request),
                                ),
                              );
                            },
                          )),

                  if (requestProvider.requests
                      .where((r) => r.status != RequestStatus.completed)
                      .isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: AppTheme.statusGreen.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay solicitudes activas',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.corporateGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
