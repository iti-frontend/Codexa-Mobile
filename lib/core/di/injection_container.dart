import 'package:codexa_mobile/Data/Repository/add_course_repo_impl.dart';
import 'package:codexa_mobile/Data/Repository/auth_repository.dart';
import 'package:codexa_mobile/Data/Repository/cart_repository_impl.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/Repository/coumminty_repo_impl.dart';
import 'package:codexa_mobile/Data/Repository/profile_repo_impl.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/services/likes_persistence_service.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/repo/add_course_repo.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:codexa_mobile/Domain/repo/cart_repository.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/cart/cart_usecases.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_reply_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_reply_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_videos_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/profile/update_student_profile_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/profile/update_instructor_profile_usecase.dart';
import 'package:codexa_mobile/Ui/auth/login/login_viewModel/LoginBloc.dart';
import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/reply_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_cubit.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Locator instance
/// Use `sl<Type>()` to retrieve registered dependencies
final sl = GetIt.instance;

/// Setup all dependency injection
/// Must be called in main() before runApp()
Future<void> setupDependencyInjection() async {
  // ===========================================================================
  // 1. Core Services (External Dependencies)
  // ===========================================================================
  await _registerCoreServices();

  // ===========================================================================
  // 2. Data Layer (API & Repositories)
  // ===========================================================================
  _registerDataSources();
  _registerRepositories();

  // ===========================================================================
  // 3. Domain Layer (Use Cases)
  // ===========================================================================
  _registerUseCases();

  // ===========================================================================
  // 4. Presentation Layer (Cubits & Providers)
  // ===========================================================================
  _registerCubits();
  _registerProviders();
}

// =============================================================================
// CORE SERVICES
// =============================================================================

Future<void> _registerCoreServices() async {
  // SharedPreferences - Async Singleton
  // Must be initialized before any dependency that needs it
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

// =============================================================================
// DATA LAYER
// =============================================================================

void _registerDataSources() {
  // ApiManager - LazySingleton with reactive token management
  // Reads token dynamically from SharedPreferences in interceptor
  sl.registerLazySingleton<ApiManager>(
    () => ApiManager(prefs: sl<SharedPreferences>()),
  );

  // LikesPersistenceService - LazySingleton for persistent likes storage
  sl.registerLazySingleton<LikesPersistenceService>(
    () => LikesPersistenceService(sl<SharedPreferences>()),
  );
}

void _registerRepositories() {
  // Auth Repository
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(sl<ApiManager>()),
  );

  // Courses Repository
  sl.registerLazySingleton<GetCoursesRepo>(
    () => CoursesRepoImpl(sl<ApiManager>()),
  );

  // Community Repository
  sl.registerLazySingleton<CommunityRepo>(
    () => CommunityRepoImpl(sl<ApiManager>()),
  );

  // Instructor Course Repository
  sl.registerLazySingleton<CourseInstructorRepo>(
    () => CourseInstructorRepoImpl(apiManager: sl<ApiManager>()),
  );

  sl.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(sl<ApiManager>()),
  );

  // Cart Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<ApiManager>()),
  );
}

// =============================================================================
// DOMAIN LAYER - USE CASES
// =============================================================================

void _registerUseCases() {
  _registerAuthUseCases();
  _registerCoursesUseCases();
  _registerCommunityUseCases();
  _registerProfileUseCases();
  _registerCartUseCases();
}

void _registerAuthUseCases() {
  // All auth use cases as LazySingletons (stateless, can be reused)
  sl.registerLazySingleton(() => LoginInstructorUseCase(sl<AuthRepo>()));
  sl.registerLazySingleton(() => LoginStudentUseCase(sl<AuthRepo>()));
  sl.registerLazySingleton(() => RegisterInstructorUseCase(sl<AuthRepo>()));
  sl.registerLazySingleton(() => RegisterStudentUseCase(sl<AuthRepo>()));
  sl.registerLazySingleton(() => SocialLoginInstructorUseCase(sl<AuthRepo>()));
  sl.registerLazySingleton(() => SocialLoginStudentUseCase(sl<AuthRepo>()));
}

void _registerCoursesUseCases() {
  // Courses use cases
  sl.registerLazySingleton(() => GetCoursesUseCase(sl<GetCoursesRepo>()));
  sl.registerLazySingleton(() => AddCourseUseCase(sl<CourseInstructorRepo>()));
  sl.registerLazySingleton(
      () => UpdateCourseUseCase(sl<CourseInstructorRepo>()));
  sl.registerLazySingleton(
      () => DeleteCourseUseCase(sl<CourseInstructorRepo>()));
  sl.registerLazySingleton(
      () => UploadVideosUseCase(sl<CourseInstructorRepo>()));
}

void _registerCommunityUseCases() {
  // Community use cases
  sl.registerLazySingleton(() => GetAllPostsUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => AddReplyUseCase(sl<CommunityRepo>()));
  sl.registerLazySingleton(() => DeleteReplyUseCase(sl<CommunityRepo>()));
}

void _registerProfileUseCases() {
  // Profile use cases
  sl.registerLazySingleton(
      () => UpdateStudentProfileUseCase(sl<ProfileRepo>()));
  sl.registerLazySingleton(
      () => UpdateInstructorProfileUseCase(sl<ProfileRepo>()));
}

void _registerCartUseCases() {
  // Cart use cases
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
}

// =============================================================================
// PRESENTATION LAYER - CUBITS
// =============================================================================

void _registerCubits() {
  // All cubits as Factories (new instance each time to avoid state conflicts)

  // Auth Cubits
  sl.registerFactory(
    () => AuthViewModel(
      loginStudentUseCase: sl<LoginStudentUseCase>(),
      registerStudentUseCase: sl<RegisterStudentUseCase>(),
      socialLoginStudentUseCase: sl<SocialLoginStudentUseCase>(),
      loginInstructorUseCase: sl<LoginInstructorUseCase>(),
      registerInstructorUseCase: sl<RegisterInstructorUseCase>(),
      socialLoginInstructorUseCase: sl<SocialLoginInstructorUseCase>(),
    ),
  );

  sl.registerFactory(
    () => RegisterViewModel(
      registerStudentUseCase: sl<RegisterStudentUseCase>(),
      socialLoginStudentUseCase: sl<SocialLoginStudentUseCase>(),
      registerInstructorUseCase: sl<RegisterInstructorUseCase>(),
      socialLoginInstructorUseCase: sl<SocialLoginInstructorUseCase>(),
    ),
  );

  // Courses Cubits
  sl.registerFactory(
    () => StudentCoursesCubit(sl<GetCoursesUseCase>()),
  );

  sl.registerFactory(
    () => InstructorCoursesCubit(
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      addCourseUseCase: sl<AddCourseUseCase>(),
      updateCourseUseCase: sl<UpdateCourseUseCase>(),
      deleteCourseUseCase: sl<DeleteCourseUseCase>(),
      uploadVideosUseCase: sl<UploadVideosUseCase>(),
    ),
  );

  sl.registerFactory(
    () => EnrollCubit(
      enrollUseCase: sl<GetCoursesUseCase>(),
      token: sl<SharedPreferences>().getString('token') ?? '',
    ),
  );

  // Community Cubits
  sl.registerFactory(
    () => CommunityPostsCubit(
      getAllPostsUseCase: sl<GetAllPostsUseCase>(),
      createPostUseCase: sl<CreatePostUseCase>(),
      deletePostUseCase: sl<DeletePostUseCase>(),
    ),
  );

  sl.registerFactory(
    () => LikeCubit(sl<ToggleLikeUseCase>()),
  );

  sl.registerFactory(
    () => CommentCubit(
      addCommentUseCase: sl<AddCommentUseCase>(),
      deleteCommentUseCase: sl<DeleteCommentUseCase>(),
    ),
  );

  sl.registerFactory(
    () => ReplyCubit(
      addReplyUseCase: sl<AddReplyUseCase>(),
      deleteReplyUseCase: sl<DeleteReplyUseCase>(),
    ),
  );

  // Register Student ProfileCubit
  sl.registerFactory<ProfileCubit<StudentEntity>>(
    () => ProfileCubit<StudentEntity>(
      updateProfileUseCase: sl<UpdateStudentProfileUseCase>(),
    ),
  );

// Register Instructor ProfileCubit
  sl.registerFactory<ProfileCubit<InstructorEntity>>(
    () => ProfileCubit<InstructorEntity>(
      updateProfileUseCase: sl<UpdateInstructorProfileUseCase>(),
    ),
  );

  // Cart Cubit
  sl.registerFactory(
    () => CartCubit(
      addToCartUseCase: sl<AddToCartUseCase>(),
      getCartUseCase: sl<GetCartUseCase>(),
      removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
    ),
  );
}

// =============================================================================
// PRESENTATION LAYER - PROVIDERS
// =============================================================================

void _registerProviders() {
  // UserProvider - LazySingleton with injected SharedPreferences
  sl.registerFactory(
    () => UserProvider(sl<SharedPreferences>()),
  );

  // ThemeProvider - No dependencies, but register for consistency
  // (Could also be kept as ChangeNotifierProvider.create in main.dart)
  // We'll keep it in main.dart to avoid over-engineering
}
