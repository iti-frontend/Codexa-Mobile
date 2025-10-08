import 'package:codexa_mobile/Ui/auth/login/login_view/loginScreen.dart';
import 'package:flutter/material.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_social_icon.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  static const String routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAEC9FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF94B9F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  const Text(
                    'Full Name',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(hintText: 'Full Name'),
                  const SizedBox(height: 16),

                  // User Name
                  const Text(
                    'User Name',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(hintText: 'User Name'),
                  const SizedBox(height: 16),

                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(
                      hintText: 'username@gmail.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  // Password
                  const Text(
                    'Password',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(
                      hintText: 'Password', obscureText: true),
                  const SizedBox(height: 16),

                  // Register Button
                  CustomButton(
                    text: 'Register',
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.routeName);
                    },
                  ),
                  const SizedBox(height: 20),

                  // OR text
                  const Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      CustomSocialIcon(assetPath: 'assets/images/google.png'),
                      CustomSocialIcon(assetPath: 'assets/images/github.png'),
                      CustomSocialIcon(assetPath: 'assets/images/facebook.png'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already Have An Account ? ",
                        style: const TextStyle(color: Colors.white),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Login Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
