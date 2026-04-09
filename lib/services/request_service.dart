import '../models/request.dart';

class RequestService {
  // Mock data - En producción, esto vendría de una API
  List<ServiceRequest> _requests = [];

  RequestService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _requests = [
      ServiceRequest(
        id: '1',
        roomNumber: '302',
        guestName: 'Carlos Méndez',
        type: RequestType.towels,
        priority: RequestPriority.urgent,
        status: RequestStatus.pending,
        description: 'Toallas adicionales',
        notes: 'Cantidad: 4 toallas grandes. Para la piscina',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ServiceRequest(
        id: '2',
        roomNumber: '205',
        guestName: 'María García',
        type: RequestType.roomService,
        priority: RequestPriority.normal,
        status: RequestStatus.pending,
        description: 'Room Service',
        notes: 'Desayuno continental para 2 personas',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ServiceRequest(
        id: '3',
        roomNumber: '410',
        guestName: 'Juan Pérez',
        type: RequestType.maintenance,
        priority: RequestPriority.urgent,
        status: RequestStatus.inProgress,
        description: 'Aire acondicionado no funciona',
        notes: 'El huésped reporta que no enfría',
        requestedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ServiceRequest(
        id: '4',
        roomNumber: '156',
        guestName: 'Ana López',
        type: RequestType.cleaning,
        priority: RequestPriority.low,
        status: RequestStatus.pending,
        description: 'Limpieza adicional',
        notes: 'Solicita limpieza de baño',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ServiceRequest(
        id: '5',
        roomNumber: '289',
        guestName: 'Pedro Sánchez',
        type: RequestType.amenities,
        priority: RequestPriority.normal,
        status: RequestStatus.completed,
        description: 'Amenidades de baño',
        notes: 'Shampoo y acondicionador',
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
    ];
  }

  Future<List<ServiceRequest>> getAllRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_requests);
  }

  Future<List<ServiceRequest>> getRequestsByStatus(RequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests.where((r) => r.status == status).toList();
  }

  Future<List<ServiceRequest>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests.where((r) => r.status == RequestStatus.pending).toList();
  }

  Future<List<ServiceRequest>> getCompletedRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests.where((r) => r.status == RequestStatus.completed).toList();
  }

  Future<ServiceRequest?> getRequestById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateRequestStatus(String id, RequestStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: newStatus,
        completedAt: newStatus == RequestStatus.completed ? DateTime.now() : null,
      );
      return true;
    }
    return false;
  }

  Future<List<ServiceRequest>> searchRequests(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return _requests;
    }

    return _requests.where((r) {
      return r.roomNumber.toLowerCase().contains(query.toLowerCase()) ||
          r.guestName.toLowerCase().contains(query.toLowerCase()) ||
          r.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  int getPendingCount() {
    return _requests.where((r) => r.status == RequestStatus.pending).length;
  }

  int getCompletedCount() {
    return _requests.where((r) => r.status == RequestStatus.completed).length;
  }

  int getInProgressCount() {
    return _requests.where((r) => r.status == RequestStatus.inProgress).length;
  }
}
