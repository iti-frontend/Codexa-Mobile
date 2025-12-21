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
import 'package:flutter_animate/flutter_animate.dart';

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
    return Directionality(
      textDirection: TextDirection.ltr, // Force LTR
      child: BlocConsumer<AuthViewModel, AuthStates>(
        listener: (context, state) async {
          if (state is StudentAuthSuccessState ||
              state is InstructorAuthSuccessState) {
            String token = '';
            dynamic userObj;
            if (state is StudentAuthSuccessState) {
              token = state.student.token ?? '';
              userObj = state.student;
            } else if (state is InstructorAuthSuccessState) {
              token =
                  (state as InstructorAuthSuccessState).instructor.token ?? '';
              userObj = (state as InstructorAuthSuccessState).instructor;
            }

            // Try to get role from returned user object (preferred)
            String resolvedRole = _resolveRoleFromUser(userObj) ??
                (state is StudentAuthSuccessState ? 'student' : 'instructor');

            // Debug prints (remove in production)
            debugPrint(
                'LOGIN SUCCESS - resolvedRole: $resolvedRole, token present: ${token.isNotEmpty}');
            debugPrint('Returned user object type: ${userObj?.runtimeType}');

            // Save to provider (use role derived from returned user when possible)
            await Provider.of<UserProvider>(context, listen: false).saveUser(
              token: token,
              role: resolvedRole.toLowerCase(),
              user: userObj,
            );

            // Navigate to home
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logged in successfully!'), // English text
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed: ${state.failure.errorMessage}'), // English text
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final authViewModel = context.read<AuthViewModel>();
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
                          const _Header(),
                          const SizedBox(height: 16),
                          Text('I am a:', // English text
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColorsDark.secondaryText
                                      : AppColorsLight.secondaryText)),
                          const SizedBox(height: 8),
                          _roleSelector(
                              isDarkMode, textColor, secondaryTextColor),
                          const SizedBox(height: 16),
                          Text('Email', // English text
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColorsDark.secondaryText
                                      : AppColorsLight.secondaryText)),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: authViewModel.emailController,
                            hintText: 'username@gmail.com', // English text
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Email cannot be empty'; // English text
                              if (!value.contains('@'))
                                return 'Enter a valid email'; // English text
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Password', // English text
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColorsDark.secondaryText
                                      : AppColorsLight.secondaryText)),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: authViewModel.passwordController,
                            hintText: 'Password', // English text
                            obscureText: obscurePassword,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password cannot be empty'; // English text
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters'; // English text
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
                                backgroundColor: buttonColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed:
                              state is AuthLoadingState ? null : _submitLogin,
                              child: state is AuthLoadingState
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text('Sign in', // English text
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                              child: Text('or continue with', // English text
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? AppColorsDark.secondaryText
                                          : AppColorsLight.secondaryText))),
                          const SizedBox(height: 16),
                          _socialLoginButtons(),
                          const SizedBox(height: 24),
                          _registerLink(isDarkMode, textColor),
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
      ),
    );
  }

  // =================== Role Selector ===================
  Widget _roleSelector(
      bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return Row(
      children: [
        _roleRadio(
            'student', 'Student', isDarkMode, secondaryTextColor),
        _roleRadio('instructor', 'Instructor', isDarkMode,
            secondaryTextColor),
      ],
    );
  }

  Widget _roleRadio(
      String value, String label, bool isDarkMode, Color secondaryTextColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedRole,
          activeColor: isDarkMode
              ? AppColorsDark.primaryText
              : AppColorsLight.primaryText,
          onChanged: (v) {
            setState(() {
              selectedRole = v;
            });
          },
        ),
        Text(label, style: TextStyle(color: secondaryTextColor)),
        const SizedBox(width: 12),
      ],
    );
  }

  // =================== Social Login Buttons ===================
  Widget _socialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomSocialIcon(
          assetPath: 'assets/images/google.png',
          onTap: () => _googleSignIn(selectedRole),
        ),
        const SizedBox(width: 24),
        CustomSocialIcon(
          assetPath: 'assets/images/github.png',
          onTap: () => _githubSignIn(selectedRole),
        ),
      ],
    );
  }

  // =================== Register Link ===================
  Widget _registerLink(bool isDarkMode, Color textColor) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account yet? ", // English text
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, RoleSelectionScreen.routeName),
                child: Text(
                  'Register for free', // English text
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: textColor),
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

    // Ensure role selected before attempting login
    if (selectedRole == null || selectedRole!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role (Student or Instructor)'), // English text
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    // Call the existing methods (keep using existing ViewModel API)
    if (selectedRole == 'student') {
      authViewModel.loginStudent();
    } else if (selectedRole == 'instructor') {
      authViewModel.loginInstructor();
    }
  }

  // =================== Google Sign In ===================
  void _googleSignIn(String? role) async {
    // Ensure role selected
    if (role == null || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role before social login'), // English text
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login failed')), // English text
        );
        return;
      }

      final authViewModel = context.read<AuthViewModel>();

      // Use explicit role path (keeps compatibility with existing ViewModel methods)
      if (role == 'student') {
        authViewModel.socialLoginStudent(token: firebaseIdToken);
      } else if (role == 'instructor') {
        authViewModel.socialLoginInstructor(token: firebaseIdToken);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Google login failed: $e'))); // English text
    }
  }

  // =================== GitHub Sign In ===================
  Future<void> _githubSignIn(String? role) async {
    if (role == null || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role before social login'), // English text
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final githubProvider = GithubAuthProvider();
      final userCredential =
      await FirebaseAuth.instance.signInWithProvider(githubProvider);

      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub login failed')), // English text
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
      debugPrint('GitHub sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('GitHub login failed: $e'))); // English text
    }
  }

  // Try to resolve role from returned user object (if backend includes it)
  String? _resolveRoleFromUser(dynamic userObj) {
    try {
      if (userObj == null) return null;

      // If it's a Map-like
      if (userObj is Map) {
        if (userObj.containsKey('role')) return userObj['role']?.toString();
        if (userObj.containsKey('userType'))
          return userObj['userType']?.toString();
        if (userObj.containsKey('type')) return userObj['type']?.toString();
      }

      // If it's a class with a `role` getter/field
      final dynamic maybeRole = (userObj as dynamic).role;
      if (maybeRole != null) return maybeRole.toString();
    } catch (_) {
      // ignore
    }
    return null;
  }
}

// ================== Header ==================
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
    isDarkMode ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return Text(
      'Login', // English text
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Gilroy',
      ),
    );
  }
}