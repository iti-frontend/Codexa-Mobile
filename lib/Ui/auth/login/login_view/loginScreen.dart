import 'package:codexa_mobile/Ui/home_page/home_screen/homeScreen.dart';
import 'package:flutter/material.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_social_icon.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';
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
                    'Login',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Gilroy'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Email',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(
                      hintText: 'username@gmail.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  const Text(
                    'Password',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const CustomTextField(
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Sign in',
                    onPressed: () {
                      Navigator.pushNamed(context, HomeScreen.routeName);
                    },
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        text: "Don't have an account yet? ",
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Register for free',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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
