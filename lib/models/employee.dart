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
      personalId: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      puestoId: json['puestoId'] is int 
    ? json['puestoId'] 
    : int.parse(json['puestoId'].toString()),

departamentoId: json['departamentoId'] is int 
    ? json['departamentoId'] 
    : int.parse(json['departamentoId'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': personalId,
      'usuarioId': usuarioId,
      'nombreCompleto': nombreCompleto,
      'puestoId': puestoId,
      'departamentoId': departamentoId,
    };
  }
}