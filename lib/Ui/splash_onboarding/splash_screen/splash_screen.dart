import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.loadUser().then((_) {
        // Increased delay slightly to allow animations to play
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            if (userProvider.token != null && userProvider.role != null) {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            } else {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Codexa" Text with cool animation
            Text(
              "Codexa",
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColorsDark.primaryBackground,
                letterSpacing: 1.5,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                    delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack)
                .shimmer(
                    delay: 1000.ms,
                    duration: 1500.ms,
                    color: Colors.white.withOpacity(0.5))
                .then()
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(
                    end: 1.05,
                    duration: 2.seconds,
                    curve: Curves.easeInOut), // Breathing

            const SizedBox(height: 10),

            Text(
              "Learn Code Online",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(
                begin: 0.5,
                end: 0,
                delay: 800.ms,
                duration: 800.ms,
                curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }
}
