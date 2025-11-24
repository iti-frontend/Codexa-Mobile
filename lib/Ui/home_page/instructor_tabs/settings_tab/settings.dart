import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_grid_item.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_option_tile.dart';
import 'package:codexa_mobile/Ui/utils/widgets/settings_tab_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsInstructorTab extends StatelessWidget {
  const SettingsInstructorTab({super.key});

  void _navigateToProfileScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final instructor = userProvider.user;

    if (instructor is InstructorEntity) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen<InstructorEntity>(
            user: instructor,
            userType: 'Instructor',
          ),
        ),
      );
    } else {
      // Show error if user data is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final instructor = userProvider.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Profile header - NOW CLICKABLE
            GestureDetector(
              onTap: () => _navigateToProfileScreen(context),
              child: ProfileHeader(
                name: instructor?.name ?? 'Codexa',
                email: instructor?.email ?? 'codexa@example.com',
                image: 'assets/images/review-1.jpg',
              ),
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
                childAspectRatio: 1.2,
                children: [
                  const SettingsGridItem(
                      icon: Icons.notifications, label: 'Notifications'),
                  const SettingsGridItem(icon: Icons.lock, label: 'Privacy'),
                  const SettingsGridItem(
                      icon: Icons.language, label: 'Language'),
                  const SettingsGridItem(
                      icon: Icons.color_lens, label: 'Theme'),
                  SettingsGridItem(
                    icon: Icons.help_outline,
                    label: 'Help',
                  ),
                  const SettingsGridItem(
                      icon: Icons.info_outline, label: 'About'),
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
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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