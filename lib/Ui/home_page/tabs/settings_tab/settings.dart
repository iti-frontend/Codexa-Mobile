import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_grid_item.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_option_tile.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_tab_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_settings_screen.dart';

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
                children: [
                  SettingsGridItem(
                      icon: Icons.notifications, label: 'Notifications'),
                  SettingsGridItem(icon: Icons.lock, label: 'Privacy'),
                  SettingsGridItem(icon: Icons.language, label: 'Language'),
                  SettingsGridItem(
                    icon: Icons.color_lens,
                    label: 'Theme',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ThemeSettingsScreen(),
                        ),
                      );
                    },
                  ),
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
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                userProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  OnboardingScreen.routeName,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
            SettingsOptionTile(
              leading: const Icon(Icons.delete_forever),
              title: 'Delete Account',
              onTap: () {},
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
