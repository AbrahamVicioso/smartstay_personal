class CredencialAcceso {
  final int credencialId;
  final int? personalId;
  final int? huespedId;
  final int? reservaId;
  final int? reservaActividadId;
  final String? codigoPin;
  final DateTime? fechaActivacion;
  final DateTime? fechaExpiracion;
  final bool estaActiva;
  final String? tipoCredencial;
  final int? numeroUsos;

  CredencialAcceso({
    required this.credencialId,
    this.personalId,
    this.huespedId,
    this.reservaId,
    this.reservaActividadId,
    this.codigoPin,
    this.fechaActivacion,
    this.fechaExpiracion,
    required this.estaActiva,
    this.tipoCredencial,
    this.numeroUsos,
  });

  factory CredencialAcceso.fromJson(Map<String, dynamic> json) {
    return CredencialAcceso(
      credencialId: json['credencialId'] ?? 0,
      personalId: json['personalId'],
      huespedId: json['huespedId'],
      reservaId: json['reservaId'],
      reservaActividadId: json['reservaActividadId'],
      codigoPin: json['codigoPin'],
      fechaActivacion: json['fechaActivacion'] != null
          ? DateTime.tryParse(json['fechaActivacion'])
          : null,
      fechaExpiracion: json['fechaExpiracion'] != null
          ? DateTime.tryParse(json['fechaExpiracion'])
          : null,
      estaActiva: json['estaActiva'] ?? false,
      tipoCredencial: json['tipoCredencial'],
      numeroUsos: json['numeroUsos'],
    );
  }

  bool get expirada =>
      fechaExpiracion != null && fechaExpiracion!.isBefore(DateTime.now());
}
