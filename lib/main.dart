import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_role_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/chatbot_screen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/settings_tab/theme_settings_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/splash_screen/splash_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';
import 'package:codexa_mobile/firebase_options.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
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
import 'Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'Ui/home_page/additional_screens/profile/profile_cubit/profile_cubit.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencyInjection();

  final prefs = sl<SharedPreferences>();

  final userProvider = UserProvider(prefs);
  await userProvider.loadUser();

  final initialRoute = userProvider.token == null
      ? SplashScreen.routeName
      : HomeScreen.routeName;

  runApp(MyApp(
    initialRoute: initialRoute,
    userProvider: userProvider,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final UserProvider userProvider;

  const MyApp({
    required this.initialRoute,
    required this.userProvider,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => userProvider),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<AuthViewModel>()),
              BlocProvider(create: (_) => sl<RegisterViewModel>()),
              BlocProvider(create: (_) => sl<StudentCoursesCubit>()),
              BlocProvider(
                  create: (_) => sl<InstructorCoursesCubit>()..fetchCourses()),
              BlocProvider(create: (_) => sl<EnrollCubit>()),
              BlocProvider(
                  create: (_) => sl<CommunityPostsCubit>()..fetchPosts()),
              BlocProvider(create: (_) => sl<LikeCubit>()),
              BlocProvider(create: (_) => sl<CommentCubit>()),
              BlocProvider(create: (_) => sl<ReplyCubit>()),
              BlocProvider(create: (_) => sl<ProfileCubit>()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: initialRoute,
              theme: AppThemeData.lightTheme,
              darkTheme: AppThemeData.darkTheme,
              themeMode: themeProvider.currentTheme,
              routes: {
                SplashScreen.routeName: (_) => SplashScreen(),
                OnboardingScreen.routeName: (_) => OnboardingScreen(),
                RoleSelectionScreen.routeName: (_) => RoleSelectionScreen(),
                RegisterScreen.routeName: (_) => RegisterScreen(),
                LoginScreen.routeName: (_) => LoginScreen(),
                HomeScreen.routeName: (_) => HomeScreen(),
                ProfileScreen.routeName: (_) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);

                  if (userProvider.user != null) {
                    final user = userProvider.user!;
                    final userType = userProvider.role ?? 'User';

                    if (userType.toLowerCase().contains('student') && user is StudentEntity) {
                      return BlocProvider<ProfileCubit<StudentEntity>>(
                        create: (context) => sl<ProfileCubit<StudentEntity>>(),
                        child: ProfileScreen<StudentEntity>(
                          user: user,
                          userType: 'Student',
                        ),
                      );
                    } else if (userType.toLowerCase().contains('instructor') && user is InstructorEntity) {
                      return BlocProvider<ProfileCubit<InstructorEntity>>(
                        create: (context) => sl<ProfileCubit<InstructorEntity>>(),
                        child: ProfileScreen<InstructorEntity>(
                          user: user,
                          userType: 'Instructor',
                        ),
                      );
                    }
                  }

                  return Scaffold(
                    body: Center(
                      child: Text('User data not available'),
                    ),
                  );
                },
                ThemeSettingsScreen.routeName: (_) => ThemeSettingsScreen(),
                ChatbotScreen.routeName: (context) => const ChatbotScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}