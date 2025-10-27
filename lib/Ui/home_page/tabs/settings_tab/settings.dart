import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_grid_item.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_option_tile.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_tab_profile.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Profile header
            const ProfileHeader(
              name: 'Codexa',
              email: 'codexa@example.com',
              image: 'assets/images/review-1.jpg',
            ),

            const SizedBox(height: 20),

            // Grid items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2, // fixes overflow
                children: const [
                  SettingsGridItem(
                      icon: Icons.notifications, label: 'Notifications'),
                  SettingsGridItem(icon: Icons.lock, label: 'Privacy'),
                  SettingsGridItem(icon: Icons.language, label: 'Language'),
                  SettingsGridItem(icon: Icons.color_lens, label: 'Theme'),
                  SettingsGridItem(icon: Icons.help_outline, label: 'Help'),
                  SettingsGridItem(icon: Icons.info_outline, label: 'About'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Option tiles
            SettingsOptionTile(
              leading: const Icon(Icons.logout),
              title: 'Logout',
              onTap: () {
                // logout logic
              },
            ),
            const SizedBox(height: 10),
            SettingsOptionTile(
              leading: const Icon(Icons.delete_forever),
              title: 'Delete Account',
              onTap: () {
                // delete account logic
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
