class User {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final String role; // Add role field

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.role, // Make role required
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      role: json['roleUser'] ?? 'REGULAR_USER', // Get role from JSON
    );
  }

  bool isPremiumUser() {
    return role == 'PREMIUM_USER';
  }
}