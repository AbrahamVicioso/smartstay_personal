class Employee {
  final String personalId;
  final String usuarioId;
  final String nombreCompleto;
  final int puestoId;
  final int departamentoId;

  Employee({
    required this.personalId,
    required this.usuarioId,
    required this.nombreCompleto,
    required this.puestoId,
    required this.departamentoId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // Convertir a String siempre
      personalId: (json['personalId'] ?? json['id'] ?? 0).toString(),
      usuarioId: (json['usuarioId'] ?? '').toString(),
      nombreCompleto: (json['nombreCompleto'] ?? '').toString(),
      puestoId: json['puestoId'] is int
          ? json['puestoId']
          : int.tryParse(json['puestoId'].toString()) ?? 0,
      departamentoId: json['departamentoId'] is int
          ? json['departamentoId']
          : int.tryParse(json['departamentoId'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalId': personalId,
      'usuarioId': usuarioId,
      'nombreCompleto': nombreCompleto,
      'puestoId': puestoId,
      'departamentoId': departamentoId,
    };
  }
}
