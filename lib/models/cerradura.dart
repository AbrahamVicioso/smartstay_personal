class Cerradura {
  final int cerraduraId;
  final int habitacionId;
  final int? dispositivoId;
  final String numeroHabitacion;
  final String estadoPuerta; // Abierta, Cerrada, Bloqueada
  final String modoOperacion; // Normal, Mantenimiento, Emergencia
  final int contadorAperturas;
  final bool estaActiva;
  final DateTime? ultimaApertura;

  Cerradura({
    required this.cerraduraId,
    required this.habitacionId,
    this.dispositivoId,
    required this.numeroHabitacion,
    required this.estadoPuerta,
    required this.modoOperacion,
    required this.contadorAperturas,
    required this.estaActiva,
    this.ultimaApertura,
  });

  factory Cerradura.fromJson(Map<String, dynamic> json) {
    return Cerradura(
      cerraduraId: json['cerraduraId'] ?? 0,
      habitacionId: json['habitacionId'] ?? 0,
      dispositivoId: json['dispositivoId'],
      numeroHabitacion: json['numeroHabitacion'] ?? '',
      estadoPuerta: json['estadoPuerta'] ?? 'Cerrada',
      modoOperacion: json['modoOperacion'] ?? 'Normal',
      contadorAperturas: json['contadorAperturas'] ?? 0,
      estaActiva: json['estaActiva'] ?? true,
      ultimaApertura: json['ultimaApertura'] != null
          ? DateTime.parse(json['ultimaApertura'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cerraduraId': cerraduraId,
      'habitacionId': habitacionId,
      'dispositivoId': dispositivoId,
      'numeroHabitacion': numeroHabitacion,
      'estadoPuerta': estadoPuerta,
      'modoOperacion': modoOperacion,
      'contadorAperturas': contadorAperturas,
      'estaActiva': estaActiva,
      'ultimaApertura': ultimaApertura?.toIso8601String(),
    };
  }

  bool get estaCerrada => estadoPuerta == 'Cerrada' || estadoPuerta == 'Bloqueada';
  bool get estaAbierta => estadoPuerta == 'Abierta';
}
