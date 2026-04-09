import 'package:flutter/foundation.dart';
import '../models/request.dart';
import '../services/request_service.dart';

class RequestProvider with ChangeNotifier {
  final RequestService _requestService = RequestService();

  List<ServiceRequest> _requests = [];
  List<ServiceRequest> _filteredRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  RequestStatus? _filterStatus;
  String _searchQuery = '';

  List<ServiceRequest> get requests => _filteredRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RequestStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  int get pendingCount => _requestService.getPendingCount();
  int get completedCount => _requestService.getCompletedCount();
  int get inProgressCount => _requestService.getInProgressCount();

  Future<void> loadRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _requestService.getAllRequests();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRequests() async {
    await loadRequests();
  }

  void setFilter(RequestStatus? status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRequests = _requests;

    if (_filterStatus != null) {
      _filteredRequests = _filteredRequests
          .where((r) => r.status == _filterStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredRequests = _filteredRequests.where((r) {
        return r.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.guestName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<bool> updateRequestStatus(String id, RequestStatus newStatus) async {
    try {
      final success = await _requestService.updateRequestStatus(id, newStatus);

      if (success) {
        await loadRequests();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  ServiceRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
