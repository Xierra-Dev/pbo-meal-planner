import 'user.dart';

class RegularUser extends User {
  final int maxSavedRecipes;
  final int maxMealPlans;

  RegularUser({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? bio,
    String? profilePictureUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.maxSavedRecipes = 10,
    this.maxMealPlans = 7,
  }) : super(
          id: id,
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          bio: bio,
          profilePictureUrl: profilePictureUrl,
          userType: 'REGULAR',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory RegularUser.fromJson(Map<String, dynamic> json) {
    return RegularUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      maxSavedRecipes: json['maxSavedRecipes'] ?? 10,
      maxMealPlans: json['maxMealPlans'] ?? 7,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'userType': userType,
      'maxSavedRecipes': maxSavedRecipes,
      'maxMealPlans': maxMealPlans,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}