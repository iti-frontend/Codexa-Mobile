// lib/src/ui/auth/register/register_screen.dart

import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_bloc.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_state.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_text_field.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_social_icon.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showRePassword = false;

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String;

    return BlocConsumer<RegisterViewModel, RegisterStates>(
      listener: (context, state) {
        if (state is StudentRegisterSuccessState ||
            state is InstructorRegisterSuccessState) {
          final token = (state is StudentRegisterSuccessState)
              ? state.student.token
              : (state as InstructorRegisterSuccessState).instructor.token;

          final user = (state is StudentRegisterSuccessState)
              ? state.student
              : (state as InstructorRegisterSuccessState).instructor;

          final role =
              state is StudentRegisterSuccessState ? 'student' : 'instructor';
          Provider.of<UserProvider>(context, listen: false).saveUser(
            token: token ?? "",
            role: role,
            user: user,
          );

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Registration Successful! Redirecting...'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
        } else if (state is RegisterLoadingState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RegisterErrorState) {
          final err = state.failure.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final authViewModel = context.read<RegisterViewModel>();
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDarkMode
            ? AppColorsDark.primaryBackground
            : AppColorsLight.primaryBackground;
        final cardColor = isDarkMode
            ? AppColorsDark.cardBackground
            : AppColorsLight.cardBackground;
        final textColor =
            isDarkMode ? AppColorsDark.primaryText : AppColorsLight.primaryText;
        final secondaryTextColor = isDarkMode
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText;
        final buttonColor =
            isDarkMode ? AppColorsDark.accentGreen : AppColorsLight.accentBlue;
        final accentColor =
            isDarkMode ? AppColorsDark.accentGreen : AppColorsLight.accentBlue;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 20),

                        // Avatar
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: isDarkMode
                                    ? Colors.white24
                                    : Colors.black12,
                                child: Icon(Icons.person,
                                    size: 50,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: accentColor,
                                  child: const Icon(Icons.edit,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        Text('Full Name',
                            style: TextStyle(color: secondaryTextColor)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Full Name',
                          controller: authViewModel.nameController,
                          validator: (v) => v == null || v.trim().length < 3
                              ? 'Enter valid full name'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text('Email',
                            style: TextStyle(color: secondaryTextColor)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'username@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: authViewModel.emailController,
                          validator: (value) => value != null &&
                                  RegExp(r"^[^@]+@[^@]+\.[^@]+$")
                                      .hasMatch(value)
                              ? null
                              : 'Enter valid email',
                        ),
                        const SizedBox(height: 16),

                        // Password
                        Text('Password',
                            style: TextStyle(color: secondaryTextColor)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Password',
                          obscureText: !_showPassword,
                          controller: authViewModel.passwordController,
                          validator: (v) => v == null || v.length < 6
                              ? 'Password too short'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Confirm Password
                        Text('Confirm Password',
                            style: TextStyle(color: secondaryTextColor)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Confirm Password',
                          obscureText: !_showRePassword,
                          controller: authViewModel.rePasswordController,
                          validator: (v) => v == null ||
                                  v != authViewModel.passwordController.text
                              ? 'Passwords do not match'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showRePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showRePassword = !_showRePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Register button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: state is RegisterLoadingState
                              ? null
                              : () => _submitRegister(role),
                          child: state is RegisterLoadingState
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text('Register',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),

                        Center(
                            child: Text('or continue with',
                                style: TextStyle(
                                    color: isDarkMode
                                        ? AppColorsDark.secondaryText
                                        : AppColorsLight.secondaryText))),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomSocialIcon(
                              assetPath: 'assets/images/google.png',
                              onTap: () => _googleSignIn(role),
                            ),
                            const SizedBox(width: 24),
                            CustomSocialIcon(
                              assetPath: 'assets/images/github.png',
                              onTap: () => _githubSignIn(role),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already Have An Account ? ",
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                          context, LoginScreen.routeName);
                                    },
                                    child: Text('Login Now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                            color: isDarkMode
                                                ? AppColorsDark.accentBlueAuth
                                                : Color(0xFF1A73E8))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ].animate(interval: 50.ms).fade(duration: 400.ms).slideY(
                          begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitRegister(String role) {
    if (_formKey.currentState?.validate() != true) return;

    final authViewModel = context.read<RegisterViewModel>();

    if (role == 'student') {
      authViewModel.registerStudent();
    } else {
      authViewModel.registerInstructor();
    }
  }

  void _googleSignIn(String role) async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get Google ID Token')));
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user!.getIdToken();

      final authViewModel = context.read<RegisterViewModel>();

      if (role == 'student') {
        authViewModel.socialRegisterStudent(token: firebaseIdToken ?? "");
      } else {
        authViewModel.socialRegisterInstructor(token: firebaseIdToken ?? "");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Social login failed: $e')));
    }
  }

  Future<void> _githubSignIn(String role) async {
    try {
      final githubProvider = GithubAuthProvider();
      final userCredential =
          await FirebaseAuth.instance.signInWithProvider(githubProvider);

      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get Firebase ID Token')),
        );
        return;
      }

      final authViewModel = context.read<RegisterViewModel>();

      if (role == 'student') {
        authViewModel.socialRegisterStudent(
          token: firebaseIdToken,
        );
      } else {
        authViewModel.socialRegisterInstructor(
          token: firebaseIdToken,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GitHub login failed: $e')),
      );
    }
  }
}
