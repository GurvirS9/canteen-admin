class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'manager',
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String? ?? 'manager',
    avatarUrl: json['avatarUrl'] as String?,
  );
}
