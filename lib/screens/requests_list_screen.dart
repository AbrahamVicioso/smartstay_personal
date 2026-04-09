import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../models/request.dart';
import '../config/theme.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
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
                    hintText: 'Buscar por habitación o huésped...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              context.read<RequestProvider>().setSearchQuery('');
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
                    context.read<RequestProvider>().setSearchQuery(value);
                  },
                ),
              ),

              // Filter Pills
              Consumer<RequestProvider>(
                builder: (context, requestProvider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'Todas',
                          requestProvider.filterStatus == null,
                          () => requestProvider.setFilter(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Pendientes',
                          requestProvider.filterStatus == RequestStatus.pending,
                          () => requestProvider.setFilter(RequestStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'En Proceso',
                          requestProvider.filterStatus == RequestStatus.inProgress,
                          () => requestProvider.setFilter(RequestStatus.inProgress),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Completadas',
                          requestProvider.filterStatus == RequestStatus.completed,
                          () => requestProvider.setFilter(RequestStatus.completed),
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
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.navyBlue),
              ),
            );
          }

          if (requestProvider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppTheme.corporateGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron solicitudes',
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
            itemCount: requestProvider.requests.length,
            itemBuilder: (context, index) {
              final request = requestProvider.requests[index];
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
}
