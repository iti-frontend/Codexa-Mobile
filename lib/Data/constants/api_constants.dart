class ApiConstants {
  static const String studentEndpointLogin = "/students/login";
  static const String studentEndpointRegister = "/students/register";
  static const String studentEndpointSocial = "/students/social-login";
  static const String instructorEndpointLogin = "/instructors/login";
  static const String instructorEndpointRegister = "/instructors/register";
  static const String instructorEndpointSocial = "/instructors/social-login";

  static const String coursesEndpoint = "/courses";

  static const String coursesInstructorEndpoint = "/courses/my-courses";

  static String courseInstructorById(String courseId) => '/courses/$courseId';
  static String courseInstructorVideos(String courseId) =>
      '/courses/$courseId/videos';
  static String courseInstructorVideoById(String courseId, String videoId) =>
      '/courses/$courseId/videos/$videoId';
}
