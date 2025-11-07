import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/splash_screen/splash_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';
import 'package:codexa_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'Ui/auth/register/register_view/register_role_screen.dart';
import 'Ui/auth/login/login_viewModel/LoginBloc.dart';
import 'Data/Repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepo = AuthRepoImpl(ApiManager());
  final coursesRepo = CoursesRepoImpl(ApiManager());
  final getCoursesUseCase = GetCoursesUseCase(coursesRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthViewModel(
              loginStudentUseCase: LoginStudentUseCase(authRepo),
              registerStudentUseCase: RegisterStudentUseCase(authRepo),
              socialLoginStudentUseCase: SocialLoginStudentUseCase(authRepo),
              loginInstructorUseCase: LoginInstructorUseCase(authRepo),
              registerInstructorUseCase: RegisterInstructorUseCase(authRepo),
              socialLoginInstructorUseCase:
                  SocialLoginInstructorUseCase(authRepo),
            ),
          ),
          BlocProvider(
            create: (_) => RegisterViewModel(
              registerStudentUseCase: RegisterStudentUseCase(authRepo),
              socialLoginStudentUseCase: SocialLoginStudentUseCase(authRepo),
              registerInstructorUseCase: RegisterInstructorUseCase(authRepo),
              socialLoginInstructorUseCase:
                  SocialLoginInstructorUseCase(authRepo),
            ),
          ),
          BlocProvider(
            create: (_) => StudentCoursesCubit(getCoursesUseCase),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          SplashScreen.routeName: (_) => SplashScreen(),
          OnboardingScreen.routeName: (_) => OnboardingScreen(),
          RoleSelectionScreen.routeName: (_) => RoleSelectionScreen(),
          RegisterScreen.routeName: (_) => RegisterScreen(),
          LoginScreen.routeName: (_) => LoginScreen(),
          HomeScreen.routeName: (_) => HomeScreen(),
        },
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeMode: themeProvider.currentTheme);
  }
}
