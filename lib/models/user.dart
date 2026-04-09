class User {
  final String id;
  final String email;
  final String name;
  final String department;
  final String? photoUrl;
  final bool isEmailConfirmed;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    this.photoUrl,
    required this.isEmailConfirmed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      photoUrl: json['photoUrl'],
      isEmailConfirmed: json['isEmailConfirmed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'department': department,
      'photoUrl': photoUrl,
      'isEmailConfirmed': isEmailConfirmed,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    String? photoUrl,
    bool? isEmailConfirmed,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
    );
  }
}
