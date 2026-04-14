class RegistroAcceso {
  final int registroId;
  final int cerraduraId;
  final String usuarioId;
  final DateTime fechaHoraAcceso;
  final String tipoAcceso;
  final String resultadoAcceso;
  final String motivoAcceso;
  final String? infoDispositivo;
  final bool fueExitoso;
  final String? codigoError;

  RegistroAcceso({
    required this.registroId,
    required this.cerraduraId,
    required this.usuarioId,
    required this.fechaHoraAcceso,
    required this.tipoAcceso,
    required this.resultadoAcceso,
    required this.motivoAcceso,
    this.infoDispositivo,
    required this.fueExitoso,
    this.codigoError,
  });

  factory RegistroAcceso.fromJson(Map<String, dynamic> json) {
    return RegistroAcceso(
      registroId: json['registroId'] ?? 0,
      cerraduraId: json['cerraduraId'] ?? 0,
      usuarioId: json['usuarioId'] ?? '',
      fechaHoraAcceso:
          DateTime.tryParse(json['fechaHoraAcceso'] ?? '') ?? DateTime.now(),
      tipoAcceso: json['tipoAcceso'] ?? '',
      resultadoAcceso: json['resultadoAcceso'] ?? '',
      motivoAcceso: json['motivoAcceso'] ?? '',
      infoDispositivo: json['infoDispositivo'],
      fueExitoso: json['fueExitoso'] ?? false,
      codigoError: json['codigoError'],
    );
  }
}
