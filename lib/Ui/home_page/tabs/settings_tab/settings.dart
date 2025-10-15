import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_grid_item.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_option_tile.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_tab_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ProfileHeader(
                name: 'Codexa',
                email: 'codexa@example.com',
                image: 'assets/images/review-1.jpg',
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: const [
                    SettingsGridItem(
                      icon: Icons.notifications,
                      label: 'Notifications',
                    ),
                    SettingsGridItem(
                      icon: Icons.lock,
                      label: 'Privacy',
                    ),
                    SettingsGridItem(
                      icon: Icons.language,
                      label: 'Language',
                    ),
                    SettingsGridItem(
                      icon: Icons.color_lens,
                      label: 'Theme',
                    ),
                    SettingsGridItem(
                      icon: Icons.help_outline,
                      label: 'Help',
                    ),
                    SettingsGridItem(
                      icon: Icons.info_outline,
                      label: 'About',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SettingsOptionTile(
                icon: Icons.logout,
                label: 'Logout',
              ),
              const SizedBox(height: 10),
              const SettingsOptionTile(
                icon: Icons.delete_forever,
                label: 'Delete Account',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
