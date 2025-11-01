import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);
  static const routeName = '/select-role';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 90,
            ),
            const SizedBox(height: 18),
            Text(
              'Choose Your Role',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you want to join our platform',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            _roleButton(
              context,
              title: 'Register as Student',
              icon: FontAwesomeIcons.userGraduate,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RegisterScreen.routeName,
                  arguments: 'student',
                );
              },
            ),
            const SizedBox(height: 18),
            _roleButton(
              context,
              title: 'Register as Instructor',
              icon: FontAwesomeIcons.chalkboardTeacher,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RegisterScreen.routeName,
                  arguments: 'instructor',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: theme.cardTheme.elevation ?? 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
              ), // inherits iconTheme.color
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ), // inherits textTheme color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
