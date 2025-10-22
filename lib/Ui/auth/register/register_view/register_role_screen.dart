import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);
  static const routeName = '/select-role';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 90,
              color: Colors.yellowAccent,
            ),
            const SizedBox(height: 18),

            const Text(
              'Choose Your Role',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Select how you want to join our platform',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 40),

            _roleButton(
              context,
              title: 'Register as Student',
              icon: FontAwesomeIcons.userGraduate,
              color: Colors.blueAccent,
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
              color: Colors.orangeAccent,
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
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
