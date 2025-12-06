import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_role_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/chatbot_screen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:codexa_mobile/generated/l10n.dart';
import 'package:codexa_mobile/localization//localization_service.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'Ui/utils/provider_ui/auth_provider.dart';
import 'Ui/auth/register/register_viewModel/register_bloc.dart';
import 'Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'Ui/home_page/additional_screens/profile/profile_cubit/profile_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:animated_theme_switcher/animated_theme_switcher.dart'
    as animated;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  timeago.setLocaleMessages('ar', timeago.ArMessages());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencyInjection();

  final prefs = sl<SharedPreferences>();

  final userProvider = UserProvider(prefs);
  await userProvider.loadUser();

  // Create LocalizationService instance
  final localizationService = LocalizationService();

  // Initialize localization service
  await localizationService.init();

  final initialRoute = userProvider.token == null
      ? SplashScreen.routeName
      : HomeScreen.routeName;

  runApp(MyApp(
    initialRoute: initialRoute,
    userProvider: userProvider,
    localizationService: localizationService,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final UserProvider userProvider;
  final LocalizationService localizationService;

  const MyApp({
    required this.initialRoute,
    required this.userProvider,
    required this.localizationService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider.value(value: localizationService),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          final localizationService = Provider.of<LocalizationService>(context);

          return animated.ThemeProvider(
            initTheme: themeProvider.isDarkMode
                ? AppThemeData.darkTheme
                : AppThemeData.lightTheme,
            builder: (context, theme) {
              return animated.ThemeSwitcher(builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => sl<AuthViewModel>()),
                    BlocProvider(create: (_) => sl<RegisterViewModel>()),
                    BlocProvider(
                        create: (_) =>
                            sl<StudentCoursesCubit>()..fetchCourses()),
                    BlocProvider(
                        create: (_) =>
                            sl<InstructorCoursesCubit>()..fetchCourses()),
                    BlocProvider(create: (_) => sl<EnrollCubit>()),
                    BlocProvider(
                        create: (_) => sl<CommunityPostsCubit>()..fetchPosts()),
                    BlocProvider(create: (_) => sl<LikeCubit>()),
                    BlocProvider(create: (_) => sl<CommentCubit>()),
                    BlocProvider(create: (_) => sl<ReplyCubit>()),
                    BlocProvider(create: (_) => sl<ProfileCubit>()),
                    BlocProvider(create: (_) => sl<CartCubit>()..getCart()),
                  ],
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Codexa',
                    initialRoute: initialRoute,
                    theme: theme, // Use the theme from AnimatedThemeProvider
                    locale: localizationService.locale,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: S.supportedLocales,
                    localeResolutionCallback: (locale, supportedLocales) {
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale?.languageCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    },
                    routes: {
                      SplashScreen.routeName: (_) => SplashScreen(),
                      OnboardingScreen.routeName: (_) => OnboardingScreen(),
                      RoleSelectionScreen.routeName: (_) =>
                          RoleSelectionScreen(),
                      RegisterScreen.routeName: (_) => RegisterScreen(),
                      LoginScreen.routeName: (context) {
                        // Wrap LoginScreen with all necessary providers
                        return MultiProvider(
                          providers: [
                            // Get existing providers from the root context
                            ChangeNotifierProvider.value(
                              value: Provider.of<ThemeProvider>(context,
                                  listen: false),
                            ),
                            ChangeNotifierProvider.value(
                              value: Provider.of<UserProvider>(context,
                                  listen: false),
                            ),
                            ChangeNotifierProvider.value(
                              value: Provider.of<LocalizationService>(context,
                                  listen: false),
                            ),
                            // Create a new AuthViewModel for this screen
                            BlocProvider<AuthViewModel>(
                              create: (_) => sl<AuthViewModel>(),
                            ),
                          ],
                          child: LoginScreen(),
                        );
                      },
                      HomeScreen.routeName: (_) => HomeScreen(),
                      ProfileScreen.routeName: (context) {
                        return MultiProvider(
                          providers: [
                            // Get providers from parent context
                            ChangeNotifierProvider.value(
                              value: Provider.of<UserProvider>(context,
                                  listen: false),
                            ),
                            ChangeNotifierProvider.value(
                              value: Provider.of<LocalizationService>(context,
                                  listen: false),
                            ),
                            ChangeNotifierProvider.value(
                              value: Provider.of<ThemeProvider>(context,
                                  listen: false),
                            ),
                          ],
                          child: Builder(
                            builder: (innerContext) {
                              final currentUserProvider =
                                  Provider.of<UserProvider>(innerContext,
                                      listen: false);

                              if (currentUserProvider.user != null) {
                                final user = currentUserProvider.user!;
                                final userType = currentUserProvider.role ??
                                    S.of(innerContext).profile;

                                if (userType
                                        .toLowerCase()
                                        .contains('student') &&
                                    user is StudentEntity) {
                                  return BlocProvider<
                                      ProfileCubit<StudentEntity>>(
                                    create: (context) =>
                                        sl<ProfileCubit<StudentEntity>>(),
                                    child: ProfileScreen<StudentEntity>(
                                      user: user,
                                      userType: 'Student',
                                    ),
                                  );
                                } else if (userType
                                        .toLowerCase()
                                        .contains('instructor') &&
                                    user is InstructorEntity) {
                                  return BlocProvider<
                                      ProfileCubit<InstructorEntity>>(
                                    create: (context) =>
                                        sl<ProfileCubit<InstructorEntity>>(),
                                    child: ProfileScreen<InstructorEntity>(
                                      user: user,
                                      userType: 'Instructor',
                                    ),
                                  );
                                }
                              }

                              return Scaffold(
                                body: Center(
                                  child: Text(
                                      S.of(innerContext).userDataNotAvailable),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      // ThemeSettingsScreen.routeName: (_) => ThemeSettingsScreen(),
                      ChatbotScreen.routeName: (context) =>
                          const ChatbotScreen(),
                    },
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }
}
