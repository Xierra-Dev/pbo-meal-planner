import 'premium_user.dart';
import 'regular_user.dart';

abstract class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePictureUrl;
  final String userType;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profilePictureUrl,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userType = json['userType'];
    if (userType == 'PREMIUM') {
      return PremiumUser.fromJson(json);
    }
    return RegularUser.fromJson(json);
  }

  Map<String, dynamic> toJson();
}