import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import '../../../../Data/Repository/auth_repository.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_social_icon.dart';
import '../register_viewModel/register_bloc.dart';
import '../register_viewModel/register_event.dart';
import '../register_viewModel/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (_) => RegisterBloc(AuthRepository()),
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
                child: BlocConsumer<RegisterBloc, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registering...')),
                      );
                    } else if (state is RegisterSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('✅ Registration Successful!')),
                      );
                      Navigator.pushReplacementNamed(
                          context, LoginScreen.routeName);
                    } else if (state is RegisterFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(' ${state.message}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
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
                            controller: fullNameController,
                            validator: (v) => v == null || v.trim().length < 3
                                ? 'Enter valid full name'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Username
                          const Text('User Name',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          CustomTextField(
                            hintText: 'User Name',
                            controller: userNameController,
                            validator: (v) => v == null || v.trim().length < 3
                                ? 'Enter valid username'
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
                            controller: emailController,
                            validator: (value) =>
                            value != null &&
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
                            obscureText: true,
                            controller: passwordController,
                            validator: (v) => v == null || v.length < 6
                                ? 'Password too short'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          CustomButton(
                            text: state is RegisterLoading ? 'Wait...' : 'Register',
                            onPressed: state is RegisterLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                final bloc = context.read<RegisterBloc>();

                                if (role == 'student') {
                                  bloc.add(RegisterStudentSubmitted(
                                    name: fullNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  ));
                                } else {
                                  bloc.add(RegisterInstructorSubmitted(
                                    name: fullNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  ));
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          const Center(
                            child: Text('or continue with',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              CustomSocialIcon(
                                  assetPath: 'assets/images/google.png'),
                              CustomSocialIcon(
                                  assetPath: 'assets/images/github.png'),
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
                                      child: const Text(
                                        'Login Now',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                          TextDecoration.underline,
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
