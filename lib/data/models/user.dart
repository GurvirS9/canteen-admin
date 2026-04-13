class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? rollNumber;
  final String? fcmToken;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'shop_owner',
    this.avatarUrl,
    this.rollNumber,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (rollNumber != null) 'rollNumber': rollNumber,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'shop_owner',
    avatarUrl: json['avatarUrl'] as String?,
    rollNumber: json['rollNumber'] as String?,
    fcmToken: json['fcmToken'] as String?,
  );
}
