class ApiConstants {
  // ============================
  // !Auth (Students & Instructors)
  // ============================
  static const String studentEndpointLogin = "/students/login";
  static const String studentEndpointRegister = "/students/register";
  static const String studentEndpointSocial = "/students/social-login";

  static const String instructorEndpointLogin = "/instructors/login";
  static const String instructorEndpointRegister = "/instructors/register";
  static const String instructorEndpointSocial = "/instructors/social-login";

  // ============================
  // !Courses
  // ============================
  static const String coursesEndpoint = "/courses";
  static const String coursesInstructorEndpoint = "/courses/my-courses";

  static String courseInstructorById(String courseId) => '/courses/$courseId';

  static String courseInstructorVideos(String courseId) =>
      '/courses/$courseId/videos';

  static String courseInstructorVideoById(String courseId, String videoId) =>
      '/courses/$courseId/videos/$videoId';

  static String enrollCourseEndpoint(String courseId) =>
      '/students/enroll/$courseId';

  // ============================
  // ~ Community (Users)
  // ============================
  static const String communityBase = "/community";

  ///? 1) Create a new post
  static const String communityCreatePost = "/community/";

  ///? 2) Get all posts
  static const String communityGetAll = "/community/";

  ///? 3) Toggle like (like/unlike)
  static String communityToggleLike(String postId) => "/community/$postId/like";

  ///? 4) Add a comment to a post
  static String communityAddComment(String postId) =>
      "/community/$postId/comment";

  ///? 5) Add a reply to a specific comment
  static String communityAddReply(String postId, String commentId) =>
      "/community/$postId/comment/$commentId/reply";

  ///? 6) Edit a post
  static String communityEditPost(String postId) => "/community/$postId";

  ///? 7) Delete a post
  static String communityDeletePost(String postId) => "/community/$postId";

  ///? 8) Edit a comment
  static String communityEditComment(String postId, String commentId) =>
      "/community/$postId/comment/$commentId";

  ///? 9) Delete a comment
  static String communityDeleteComment(String postId, String commentId) =>
      "/community/$postId/comment/$commentId";

  ///? 10) Edit a reply
  static String communityEditReply(
          String postId, String commentId, String replyId) =>
      "/community/$postId/comment/$commentId/reply/$replyId";

  ///? 11) Delete a reply
  static String communityDeleteReply(
          String postId, String commentId, String replyId) =>
      "/community/$postId/comment/$commentId/reply/$replyId";

  ///? 12) Report a post
  static String communityReportPost(String postId) =>
      "/community/$postId/report";

  // ============================
  //~ Community Admin (Moderation)
  // ============================
  static const String adminCommunityReports = "/admin/community/reports";

  ///? Get a single report by ID
  static String adminCommunityReportById(String reportId) =>
      "/admin/community/reports/$reportId";

  ///? Resolve a report (delete, warn, ban, dismiss)
  static String adminResolveReport(String reportId) =>
      "/admin/community/reports/$reportId/resolve";

  ///? Force delete any post (Admin only)
  static String adminDeletePost(String postId) => "/admin/community/$postId";

  // ============================
  // !Profile
  // ============================
  static String studentEndpointProfile= '/students/profile/';

  static String instructorEndpointProfile= '/instructors/profile/';
}
