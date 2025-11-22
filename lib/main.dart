import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_role_screen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/splash_screen/splash_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';
import 'package:codexa_mobile/firebase_options.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ui/auth/register/register_view/register_screen.dart';
import 'Ui/auth/login/login_viewModel/LoginBloc.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/reply_cubit.dart';
import 'Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_cubit.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'Ui/utils/provider_ui/auth_provider.dart';
import 'Ui/auth/register/register_viewModel/register_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✨ Setup Dependency Injection
  await setupDependencyInjection();

  // Get initial route based on token
  final prefs = sl<SharedPreferences>();
  final token = prefs.getString('token');
  final initialRoute =
      token == null ? SplashScreen.routeName : HomeScreen.routeName;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => sl<UserProvider>()),
      ],
      child: Builder(builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MultiBlocProvider(
          providers: [
            // Auth Blocs
            BlocProvider(create: (_) => sl<AuthViewModel>()),
            BlocProvider(create: (_) => sl<RegisterViewModel>()),

            // Courses Blocs
            BlocProvider(create: (_) => sl<StudentCoursesCubit>()),
            BlocProvider(
                create: (_) => sl<InstructorCoursesCubit>()..fetchCourses()),
            BlocProvider(create: (_) => sl<EnrollCubit>()),

            // Community Blocs
            BlocProvider(
                create: (_) => sl<CommunityPostsCubit>()..fetchPosts()),
            BlocProvider(create: (_) => sl<LikeCubit>()),
            BlocProvider(create: (_) => sl<CommentCubit>()),
            BlocProvider(create: (_) => sl<ReplyCubit>()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: {
              SplashScreen.routeName: (_) => SplashScreen(),
              OnboardingScreen.routeName: (_) => OnboardingScreen(),
              RoleSelectionScreen.routeName: (_) => RoleSelectionScreen(),
              RegisterScreen.routeName: (_) => RegisterScreen(),
              LoginScreen.routeName: (_) => LoginScreen(),
              HomeScreen.routeName: (_) => HomeScreen(),
            },
            initialRoute: initialRoute,
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            themeMode: themeProvider.currentTheme,
          ),
        );
      }),
    );
  }
}
