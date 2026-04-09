enum RequestType {
  towels,
  roomService,
  cleaning,
  maintenance,
  amenities,
  other,
}

enum RequestPriority {
  low,
  normal,
  urgent,
}

enum RequestStatus {
  pending,
  inProgress,
  completed,
}

class ServiceRequest {
  final String id;
  final String roomNumber;
  final String guestName;
  final RequestType type;
  final RequestPriority priority;
  final RequestStatus status;
  final String description;
  final String? notes;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? assignedTo;

  ServiceRequest({
    required this.id,
    required this.roomNumber,
    required this.guestName,
    required this.type,
    required this.priority,
    required this.status,
    required this.description,
    this.notes,
    required this.requestedAt,
    this.completedAt,
    this.assignedTo,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      guestName: json['guestName'] ?? '',
      type: _parseRequestType(json['type']),
      priority: _parseRequestPriority(json['priority']),
      status: _parseRequestStatus(json['status']),
      description: json['description'] ?? '',
      notes: json['notes'],
      requestedAt: DateTime.parse(json['requestedAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assignedTo: json['assignedTo'],
    );
  }

  static RequestType _parseRequestType(String? type) {
    switch (type?.toLowerCase()) {
      case 'towels':
        return RequestType.towels;
      case 'roomservice':
        return RequestType.roomService;
      case 'cleaning':
        return RequestType.cleaning;
      case 'maintenance':
        return RequestType.maintenance;
      case 'amenities':
        return RequestType.amenities;
      default:
        return RequestType.other;
    }
  }

  static RequestPriority _parseRequestPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return RequestPriority.low;
      case 'urgent':
        return RequestPriority.urgent;
      default:
        return RequestPriority.normal;
    }
  }

  static RequestStatus _parseRequestStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'inprogress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'guestName': guestName,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'notes': notes,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'assignedTo': assignedTo,
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? roomNumber,
    String? guestName,
    RequestType? type,
    RequestPriority? priority,
    RequestStatus? status,
    String? description,
    String? notes,
    DateTime? requestedAt,
    DateTime? completedAt,
    String? assignedTo,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      guestName: guestName ?? this.guestName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(requestedAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
