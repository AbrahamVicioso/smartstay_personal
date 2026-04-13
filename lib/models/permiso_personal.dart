class PermisoPersonal {
  final int permisoId;
  final int personalId;
  final int? habitacionId;
  final int? actividadId;
  final DateTime fechaOtorgamiento;
  final DateTime? fechaExpiracion;
  final bool esTemporal;
  final String? otorgadoPor;
  final bool estaActivo;
  final String? justificacion;
  final String? nombrePersonal;
  final String? nombreHabitacion;
  final String? nombreActividad;
  final String? otorgadoPorNombre;

  PermisoPersonal({
    required this.permisoId,
    required this.personalId,
    this.habitacionId,
    this.actividadId,
    required this.fechaOtorgamiento,
    this.fechaExpiracion,
    required this.esTemporal,
    this.otorgadoPor,
    required this.estaActivo,
    this.justificacion,
    this.nombrePersonal,
    this.nombreHabitacion,
    this.nombreActividad,
    this.otorgadoPorNombre,
  });

  factory PermisoPersonal.fromJson(Map<String, dynamic> json) {
    return PermisoPersonal(
      permisoId: json['permisoId'] ?? 0,
      personalId: json['personalId'] ?? 0,
      habitacionId: json['habitacionId'],
      actividadId: json['actividadId'],
      fechaOtorgamiento: DateTime.tryParse(json['fechaOtorgamiento'] ?? '') ?? DateTime.now(),
      fechaExpiracion: json['fechaExpiracion'] != null 
          ? DateTime.tryParse(json['fechaExpiracion']) 
          : null,
      esTemporal: json['esTemporal'] ?? false,
      otorgadoPor: json['otorgadoPor'],
      estaActivo: json['estaActivo'] ?? true,
      justificacion: json['justificacion'],
      nombrePersonal: json['nombrePersonal'],
      nombreHabitacion: json['nombreHabitacion'],
      nombreActividad: json['nombreActividad'],
      otorgadoPorNombre: json['otorgadoPorNombre'],
    );
  }

  // Helpers
  bool get tieneHabitacion => habitacionId != null;
  bool get tieneActividad => actividadId != null;
  
  String get tipoPermiso => tieneHabitacion ? 'Habitacion' : 'Actividad';
  
  String get descripcion {
    if (tieneHabitacion && nombreHabitacion != null) {
      return 'Habitacion $nombreHabitacion';
    }
    if (tieneActividad && nombreActividad != null) {
      return nombreActividad!;
    }
    return 'Permiso #$permisoId';
  }

  String? get piso {
    // Si nombreHabitacion es "102", el piso seria "1"
    if (nombreHabitacion != null && nombreHabitacion!.isNotEmpty) {
      return nombreHabitacion![0];
    }
    return null;
  }
}