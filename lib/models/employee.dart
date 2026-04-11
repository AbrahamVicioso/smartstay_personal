class Employee {
  final String personalId;
  final String usuarioId;
  final String nombreCompleto;
  final String puesto;
  final String departamento;

  Employee({
    required this.personalId,
    required this.usuarioId,
    required this.nombreCompleto,
    required this.puesto,
    required this.departamento,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      personalId: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      puesto: json['puesto'] ?? '',
      departamento: json['departamento'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': personalId,
      'usuarioId': usuarioId,
      'nombreCompleto': nombreCompleto,
      'puesto': puesto,
      'departamento': departamento,
    };
  }
}