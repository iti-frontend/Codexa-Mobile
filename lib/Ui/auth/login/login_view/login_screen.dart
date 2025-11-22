import 'package:codexa_mobile/Ui/auth/login/login_viewModel/LoginBloc.dart';
import 'package:codexa_mobile/Ui/auth/login/login_viewModel/login_state.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_role_screen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_text_field.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_social_icon.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRole;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthViewModel, AuthStates>(
      listener: (context, state) {
        if (state is StudentAuthSuccessState ||
            state is InstructorAuthSuccessState) {
          final token = (state is StudentAuthSuccessState)
              ? state.student.token
              : (state as InstructorAuthSuccessState).instructor.token;

          final user = (state is StudentAuthSuccessState)
              ? state.student
              : (state as InstructorAuthSuccessState).instructor;

          final role =
              state is StudentAuthSuccessState ? 'student' : 'instructor';

          Provider.of<UserProvider>(context, listen: false).saveUser(
            token: token ?? "",
            role: role,
            user: user,
          );

          Navigator.pushReplacementNamed(context, HomeScreen.routeName);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${state.failure.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final authViewModel = context.read<AuthViewModel>();

        return Scaffold(
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
                        const _Header(),
                        const SizedBox(height: 16),
                        const Text('I am a:',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        _roleSelector(),
                        const SizedBox(height: 16),
                        const Text('Email',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: authViewModel.emailController,
                          hintText: 'username@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Email cannot be empty';
                            if (!value.contains('@'))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Password',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: authViewModel.passwordController,
                          hintText: 'Password',
                          obscureText: obscurePassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorsDark.accentBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _submitLogin,
                            child: const Text('Sign in',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                            child: Text('or continue with',
                                style: TextStyle(color: Colors.white))),
                        const SizedBox(height: 16),
                        _socialLoginButtons(),
                        const SizedBox(height: 24),
                        _registerLink(),
                      ],
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

  // =================== Role Selector ===================
  Widget _roleSelector() {
    return Row(
      children: [
        _roleRadio('student', 'Student'),
        _roleRadio('instructor', 'Instructor'),
      ],
    );
  }

  Widget _roleRadio(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedRole,
          activeColor: AppColorsDark.primaryText,
          onChanged: (v) {
            setState(() {
              selectedRole = v;
            });
          },
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(width: 12),
      ],
    );
  }

  // =================== Social Login ===================
  Widget _socialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => _googleSignIn(selectedRole ?? ''),
          child: const CustomSocialIcon(assetPath: 'assets/images/google.png'),
        ),
        GestureDetector(
          onTap: () => _githubSignIn(selectedRole ?? ''),
          child: const CustomSocialIcon(assetPath: 'assets/images/github.png'),
        ),
      ],
    );
  }

  // =================== Register Link ===================
  Widget _registerLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account yet? ",
          style: const TextStyle(color: Colors.white),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, RoleSelectionScreen.routeName),
                child: const Text(
                  'Register for free',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorsDark.primaryText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== Submit Login ===================
  void _submitLogin() {
    if (_formKey.currentState?.validate() != true) return;

    final authViewModel = context.read<AuthViewModel>();

    if (selectedRole == 'student') {
      authViewModel.loginStudent();
    } else if (selectedRole == 'instructor') {
      authViewModel.loginInstructor();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // =================== Google Sign In ===================
  void _googleSignIn(String role) async {
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseIdToken = await userCredential.user!.getIdToken();

      final authViewModel = context.read<AuthViewModel>();

      if (role == 'student') {
        authViewModel.socialLoginStudent(token: firebaseIdToken ?? "");
      } else if (role == 'instructor') {
        authViewModel.socialLoginInstructor(token: firebaseIdToken ?? "");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role before social login'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google login failed: $e')));
    }
  }

  // =================== GitHub Sign In ===================
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

      final authViewModel = context.read<AuthViewModel>();

      if (role == 'student') {
        authViewModel.socialLoginStudent(token: firebaseIdToken);
      } else {
        authViewModel.socialLoginInstructor(token: firebaseIdToken);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('GitHub login failed: $e')));
    }
  }
}

// ================== Header ==================
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Login',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Gilroy',
      ),
    );
  }
}
