// lib/src/ui/auth/register/register_screen.dart

import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/Repository/auth_repository.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_bloc.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_state.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterViewModel authViewModel;
  bool _showPassword = false;
  bool _showRePassword = false;

  @override
  void initState() {
    super.initState();
    final apiManager = ApiManager();
    final authRepo = AuthRepoImpl(apiManager);

    authViewModel = RegisterViewModel(
      registerStudentUseCase: RegisterStudentUseCase(authRepo),
      socialLoginStudentUseCase: SocialLoginStudentUseCase(authRepo),
      registerInstructorUseCase: RegisterInstructorUseCase(authRepo),
      socialLoginInstructorUseCase: SocialLoginInstructorUseCase(authRepo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider<RegisterViewModel>.value(
      value: authViewModel,
      child: BlocListener<RegisterViewModel, RegisterStates>(
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

            print("Registered and logged in as: $role");

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
        child: Scaffold(
          backgroundColor: AppColorsDark.accentBlue,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColorsDark.accentBlueAuth,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        // Avatar
                        Center(
                          child: Stack(
                            children: [
                              const CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person,
                                    size: 50, color: Colors.white70),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.edit,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        const Text('Full Name',
                            style: TextStyle(color: Colors.white70)),
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
                        const Text('Email',
                            style: TextStyle(color: Colors.white70)),
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
                        const Text('Password',
                            style: TextStyle(color: Colors.white70)),
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
                        const Text('Confirm Password',
                            style: TextStyle(color: Colors.white70)),
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
                            backgroundColor: AppColorsDark.accentBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () => _submitRegister(role),
                          child: const Text('Register',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),

                        const Center(
                            child: Text('or continue with',
                                style: TextStyle(color: Colors.white))),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _googleSignIn(role),
                              child: const CustomSocialIcon(
                                  assetPath: 'assets/images/google.png'),
                            ),
                            // GitHub button placeholder (implement flow if available)
                            GestureDetector(
                              onTap: () => _githubSignIn(role),
                              child: const CustomSocialIcon(
                                  assetPath: 'assets/images/github.png'),
                            ),
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
                                      Navigator.pushReplacementNamed(
                                          context, LoginScreen.routeName);
                                    },
                                    child: const Text('Login Now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Color(0xFF1A73E8))),
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
          ),
        ),
      ),
    );
  }

  void _submitRegister(String role) {
    if (_formKey.currentState?.validate() != true) return;

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
      if (googleUser == null) return; // user cancelled

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
