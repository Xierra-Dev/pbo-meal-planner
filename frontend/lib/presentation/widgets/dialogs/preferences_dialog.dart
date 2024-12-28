import 'package:flutter/material.dart';
import 'settings_dialog.dart';
import 'health_data_dialog.dart';
import 'personalized_goals_dialog.dart';
import 'allergies_dialog.dart';

class PreferencesDialog extends StatelessWidget {
  const PreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      showDialog(
                        context: context,
                        builder: (context) => const SettingsDialog(),
                        barrierDismissible: true,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreferenceItem(
              'Health Data',
              '',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const HealthDataDialog(),
                  barrierDismissible: true,
                );
              },
            ),
            _buildPreferenceItem(
              'Personalized Goals',
              '',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const PersonalizedGoalsDialog(),
                  barrierDismissible: true,
                );
              },
            ),
            _buildPreferenceItem(
              'Allergies',
              '',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AllergiesDialog(),
                  barrierDismissible: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String value, {
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
      ),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}