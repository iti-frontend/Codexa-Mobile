import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../Data/Repository/auth_repository.dart';
import '../../register/register_view/register_screen.dart';
import '../login_viewModel/LoginBloc.dart';
import '../login_viewModel/login_event.dart';
import '../login_viewModel/login_state.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/widgets/custom_social_icon.dart';
import '../../../home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'student';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<LoginBloc>();
    if (_selectedRole == 'student') {
      bloc.add(LoginStudentSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    } else {
      bloc.add(LoginInstructorSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }

  Future<void> _signInWithGoogle() async {
    final bloc = context.read<LoginBloc>();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get Google ID Token')),
        );
        return;
      }

      bloc.add(SocialLoginEvent(role: _selectedRole, tokenId: idToken));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e')),
      );
    }
  }

  void _onLoginSuccess(String role) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      role == 'student'
          ? '/StudentDashboard'
          : '/InstructorDashboard',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(AuthRepository()),
      child: Scaffold(
        backgroundColor: AppColorsDark.accentBlue,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColorsDark.accentBlueAuth,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      _onLoginSuccess(state.role);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged in successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is LoginFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login failed: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is LoginLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Header(),
                          const SizedBox(height: 12),
                          const Text('I am a:', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          RoleSelector(
                            selectedRole: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value),
                          ),
                          const SizedBox(height: 16),
                          const Text('Email', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'username@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email cannot be empty';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Password', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password cannot be empty';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsDark.accentBlue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : () => _submitLogin(context),
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Sign in',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
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
                                onTap: _signInWithGoogle,
                                child: const CustomSocialIcon(
                                    assetPath: 'assets/images/google.png'),
                              ),
                              GestureDetector(
                                onTap: _signInWithGoogle,
                                child: const CustomSocialIcon(
                                    assetPath: 'assets/images/github.png'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account yet? ",
                                style: const TextStyle(color: Colors.white),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                        Navigator.pushReplacementNamed(
                                            context,
                                            RegisterScreen.routeName);
                                      },
                                      child: const Text(
                                        'Register for free',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColorsDark.primaryText,
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

// ================== Role Selector ==================
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    Key? key,
    required this.selectedRole,
    required this.onChanged,
  }) : super(key: key);

  Widget _buildRole(BuildContext context, String value, String label) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedRole,
            activeColor: AppColorsDark.primaryText,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildRole(context, 'student', 'Student'),
        _buildRole(context, 'instructor', 'Instructor'),
      ],
    );
  }
}
