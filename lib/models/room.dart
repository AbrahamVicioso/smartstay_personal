class Room {
  final int habitacionId;
  final int hotelId;
  final String numeroHabitacion;
  final String tipoHabitacion;
  final String estado; // Disponible, Ocupada, Limpieza, Mantenimiento
  final int? cerraduraId;
  final String? estadoPuerta; // Abierta, Cerrada, Bloqueada
  final String? guestName;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final bool estaDisponible;

  Room({
    required this.habitacionId,
    required this.hotelId,
    required this.numeroHabitacion,
    required this.tipoHabitacion,
    required this.estado,
    this.cerraduraId,
    this.estadoPuerta,
    this.guestName,
    this.checkInDate,
    this.checkOutDate,
    required this.estaDisponible,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      habitacionId: json['habitacionId'] ?? 0,
      hotelId: json['hotelId'] ?? 0,
      numeroHabitacion: json['numeroHabitacion'] ?? '',
      tipoHabitacion: json['tipoHabitacion'] ?? '',
      estado: json['estado'] ?? 'Disponible',
      cerraduraId: json['cerraduraId'],
      estadoPuerta: json['estadoPuerta'],
      guestName: json['guestName'],
      checkInDate: json['checkInDate'] != null ? DateTime.parse(json['checkInDate']) : null,
      checkOutDate: json['checkOutDate'] != null ? DateTime.parse(json['checkOutDate']) : null,
      estaDisponible: json['estaDisponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitacionId': habitacionId,
      'hotelId': hotelId,
      'numeroHabitacion': numeroHabitacion,
      'tipoHabitacion': tipoHabitacion,
      'estado': estado,
      'cerraduraId': cerraduraId,
      'estadoPuerta': estadoPuerta,
      'guestName': guestName,
      'checkInDate': checkInDate?.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'estaDisponible': estaDisponible,
    };
  }

  bool get estaCerrada => estadoPuerta == 'Cerrada' || estadoPuerta == 'Bloqueada';
  bool get estaOcupada => estado == 'Ocupada';
  bool get tieneCerradura => cerraduraId != null;
}
