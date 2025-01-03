import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/services/saved_recipe_service.dart';
import '/core/models/recipe.dart';
import '/core/services/auth_service.dart';
import '/core/services/planner_service.dart';
import '/core/models/planner.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Section
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
              const SizedBox(height: 16),
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  return Column(
                    children: [
                      FutureBuilder<String?>(
                        future: authService.getUsername(),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Guest',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      if (authService.isPremiumUser())
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber[700], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'REGULAR',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Food enthusiast | Healthy lifestyle',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Recipe Stats
              Consumer2<SavedRecipeService, PlannerService>(
                builder: (context, savedRecipeService, plannerService, _) {
                  return Column(
                    children: [
                      FutureBuilder<List<Recipe>>(
                        future: savedRecipeService.getSavedRecipes(),
                        builder: (context, snapshot) {
                          return _buildQuickStat(
                            icon: Icons.bookmark,
                            title: 'Saved Recipes',
                            value: '${snapshot.data?.length ?? 0}',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Planner>>(
                        future: plannerService.getTodayMeals(),
                        builder: (context, snapshot) {
                          return _buildQuickStat(
                            icon: Icons.calendar_today,
                            title: 'Planned Today',
                            value: '${snapshot.data?.length ?? 0}',
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}