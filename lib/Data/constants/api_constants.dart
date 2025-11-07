class ApiConstants {
  static const String studentEndpointLogin = "/students/login";
  static const String studentEndpointRegister = "/students/register";
  static const String studentEndpointSocial = "/students/social-login";
  static const String studentCoursesEndpoint = "/students/my-courses";
  static const String instructorEndpointLogin = "/instructors/login";
  static const String instructorEndpointRegister = "/instructors/register";
  static const String instructorEndpointSocial = "/instructors/social-login";

  static const String coursesEndpoint = "/courses";
  static String enrollCourseEndpoint(String courseId) =>
      '/students/enroll/$courseId';

  static const String coursesInstructorEndpoint = "/courses/my-courses";
}
