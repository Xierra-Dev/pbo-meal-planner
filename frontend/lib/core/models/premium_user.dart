import 'user.dart';

class PremiumUser extends User {
  final DateTime subscriptionEndDate;
  final bool hasAiRecommendations;
  final bool hasAdvancedAnalytics;
  final bool unlimitedSavedRecipes;
  final bool unlimitedMealPlans;

  PremiumUser({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? bio,
    String? profilePictureUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.subscriptionEndDate,
    this.hasAiRecommendations = true,
    this.hasAdvancedAnalytics = true,
    this.unlimitedSavedRecipes = true,
    this.unlimitedMealPlans = true,
  }) : super(
          id: id,
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          bio: bio,
          profilePictureUrl: profilePictureUrl,
          userType: 'PREMIUM',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PremiumUser.fromJson(Map<String, dynamic> json) {
    return PremiumUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      subscriptionEndDate: DateTime.parse(json['subscriptionEndDate']),
      hasAiRecommendations: json['hasAiRecommendations'] ?? true,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] ?? true,
      unlimitedSavedRecipes: json['unlimitedSavedRecipes'] ?? true,
      unlimitedMealPlans: json['unlimitedMealPlans'] ?? true,
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
      'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
      'hasAiRecommendations': hasAiRecommendations,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'unlimitedSavedRecipes': unlimitedSavedRecipes,
      'unlimitedMealPlans': unlimitedMealPlans,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}