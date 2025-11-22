import 'package:codexa_mobile/Data/Repository/add_course_repo_impl.dart';
import 'package:codexa_mobile/Data/Repository/coumminty_repo_impl.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/Repository/auth_repository.dart';
import 'package:codexa_mobile/Data/Repository/profile_repo_impl.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_reply_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_videos_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/profile/update_student_profile_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/profile/update_instructor_profile_usecase.dart';
import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/register_screen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_cubit/community_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  String? _token;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = UserProvider();
    await userProvider.loadUser();
    setState(() {
      _token = userProvider.token;
      _role = userProvider.role;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final apiManager = ApiManager(token: _token);
    final authRepo = AuthRepoImpl(apiManager);
    final coursesRepo = CoursesRepoImpl(apiManager);
    final getCoursesUseCase = GetCoursesUseCase(coursesRepo);
    final courseInstructorRepo =
        CourseInstructorRepoImpl(apiManager: apiManager);
    final communityRepo = CommunityRepoImpl(apiManager);
    final getAllPostsUseCase = GetAllPostsUseCase(communityRepo);
    final createPostUseCase = CreatePostUseCase(communityRepo);
    final toggleLikeUseCase = ToggleLikeUseCase(communityRepo);
    final addCommentUseCase = AddCommentUseCase(communityRepo);
    final addReplyUseCase = AddReplyUseCase(communityRepo);
    final profileRepo = ProfileRepoImpl(apiManager);
    final updateStudentProfileUseCase =
        UpdateStudentProfileUseCase(profileRepo);
    final updateInstructorProfileUseCase =
        UpdateInstructorProfileUseCase(profileRepo);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<UpdateStudentProfileUseCase>(
          create: (_) => updateStudentProfileUseCase,
        ),
        Provider<UpdateInstructorProfileUseCase>(
          create: (_) => updateInstructorProfileUseCase,
        ),
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
          BlocProvider(
            create: (_) => InstructorCoursesCubit(
                getCoursesUseCase: getCoursesUseCase,
                addCourseUseCase: AddCourseUseCase(courseInstructorRepo),
                updateCourseUseCase: UpdateCourseUseCase(courseInstructorRepo),
                deleteCourseUseCase: DeleteCourseUseCase(courseInstructorRepo),
                uploadVideosUseCase: UploadVideosUseCase(courseInstructorRepo)),
          ),
          BlocProvider(
            create: (context) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              return EnrollCubit(
                enrollUseCase: GetCoursesUseCase(
                  CoursesRepoImpl(ApiManager(token: userProvider.token)),
                ),
                token: userProvider.token ?? '',
              );
            },
          ),
          BlocProvider(
            create: (_) => CommunityCubit(
              getAllPostsUseCase: getAllPostsUseCase,
              createPostUseCase: createPostUseCase,
              toggleLikeUseCase: toggleLikeUseCase,
              addCommentUseCase: addCommentUseCase,
              addReplyUseCase: addReplyUseCase,
            )..fetchPosts(),
          )
        ],
        child: MyApp(
            initialRoute:
                _token == null ? SplashScreen.routeName : HomeScreen.routeName),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

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
        ProfileScreen.routeName: (_) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          if (userProvider.user is StudentEntity) {
            final student = userProvider.user as StudentEntity;
            return ProfileScreen<StudentEntity>(
              user: student,
              userType: 'Student',
            );
          } else if (userProvider.user is InstructorEntity) {
            final instructor = userProvider.user as InstructorEntity;
            return ProfileScreen<InstructorEntity>(
              user: instructor,
              userType: 'Instructor',
            );
          }

          return const Scaffold(
            body: Center(
              child: Text('User not found or unsupported user type'),
            ),
          );
        },
      },
      initialRoute: initialRoute,
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: themeProvider.currentTheme,
    );
  }
}
