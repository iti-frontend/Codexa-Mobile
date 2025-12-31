import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class S {
  S(this.locale);

  final Locale locale;

  static S? _current;

  // Static getter to access current instance
  static S get current {
    if (_current == null) {
      throw FlutterError('S.current called before S loaded. '
          'Make sure to initialize localization properly.');
    }
    return _current!;
  }

  // Method to update current instance when locale changes
  static void updateLocale(Locale locale) {
    _current = S(locale);
  }

  static S of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedS>();
    if (inherited == null) {
      throw FlutterError(
          'S.of() called with a context that does not contain S. '
          'Make sure your widget is wrapped in MaterialApp or Localizations widget.');
    }
    return inherited.localizations;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  // App Common
  String get appTitle => _translate('appTitle');
  String get welcome => _translate('welcome');
  String get orContinueWith => _translate('orContinueWith');
  String get registerForFree => _translate('registerForFree');
  String get loginNow => _translate('loginNow');
  String get alreadyHaveAccount => _translate('alreadyHaveAccount');
  String get dontHaveAccount => _translate('dontHaveAccount');
  String get loading => _translate('loading');
  String get error => _translate('error');
  String get success => _translate('success');
  String get cancel => _translate('cancel');
  String get save => _translate('save');
  String get delete => _translate('delete');
  String get edit => _translate('edit');
  String get confirm => _translate('confirm');
  String get continueText => _translate('continueText');
  String get back => _translate('back');
  String get next => _translate('next');
  String get skip => _translate('skip');
  String get finish => _translate('finish');
  String get search => _translate('search');
  String get clear => _translate('clear');
  String get submit => _translate('submit');
  String get send => _translate('send');
  String get add => _translate('add');
  String get remove => _translate('remove');
  String get update => _translate('update');
  String get create => _translate('create');
  String get view => _translate('view');
  String get profile => _translate('profile');
  String get settings => _translate('settings');
  String get logout => _translate('logout');
  String get language => _translate('language');
  String get theme => _translate('theme');
  String get darkTheme => _translate('darkTheme');
  String get help => _translate('help');
  String get about => _translate('about');
  String get privacy => _translate('privacy');
  String get notifications => _translate('notifications');

  //Tabs
  String get home => _translate('home');
  String get courses => _translate('courses');
  String get community => _translate('community');
  String get favorites => _translate('favorites');

  // Login Screen
  String get login => _translate('login');
  String get signIn => _translate('signIn');
  String get iAmA => _translate('iAmA');
  String get student => _translate('student');
  String get instructor => _translate('instructor');
  String get email => _translate('email');
  String get password => _translate('password');
  String get forgotPassword => _translate('forgotPassword');
  String get enterValidEmail => _translate('enterValidEmail');
  String get emailCannotBeEmpty => _translate('emailCannotBeEmpty');
  String get passwordCannotBeEmpty => _translate('passwordCannotBeEmpty');
  String get passwordMinLength => _translate('passwordMinLength');
  String get selectRole => _translate('selectRole');
  String get selectRoleSocial => _translate('selectRoleSocial');
  String get loginFailed => _translate('loginFailed');
  String get loginSuccess => _translate('loginSuccess');
  String get googleLoginFailed => _translate('googleLoginFailed');
  String get githubLoginFailed => _translate('githubLoginFailed');

  // Register Screen
  String get register => _translate('register');
  String get registerTitle => _translate('registerTitle');
  String get fullName => _translate('fullName');
  String get confirmPassword => _translate('confirmPassword');
  String get enterValidName => _translate('enterValidName');
  String get passwordTooShort => _translate('passwordTooShort');
  String get passwordsDoNotMatch => _translate('passwordsDoNotMatch');
  String get registrationSuccessful => _translate('registrationSuccessful');
  String get registrationFailed => _translate('registrationFailed');

  // Profile Screen
  String get profileTitle => _translate('profileTitle');
  String get studentProfile => _translate('studentProfile');
  String get instructorProfile => _translate('instructorProfile');
  String get editProfile => _translate('editProfile');
  String get saveChanges => _translate('saveChanges');
  String get cancelEditing => _translate('cancelEditing');
  String get changeProfilePicture => _translate('changeProfilePicture');
  String get chooseFromGallery => _translate('chooseFromGallery');
  String get takePhoto => _translate('takePhoto');
  String get newImageSelected => _translate('newImageSelected');
  String get imageSelectionRemoved => _translate('imageSelectionRemoved');
  String get profileUpdated => _translate('profileUpdated');
  String get enterName => _translate('enterName');
  String get enterEmail => _translate('enterEmail');
  String get validEmail => _translate('validEmail');
  String get profilePreview => _translate('profilePreview');
  String get tapToChangePhoto => _translate('tapToChangePhoto');
  String get updatingProfile => _translate('updatingProfile');
  String get errorLoadingPosts => _translate('errorLoadingPosts');
  String get removeSelectedImage => _translate('removeSelectedImage');
  String get communityActivity => _translate('communityActivity');
  String get postsAndEngagement => _translate('postsAndEngagement');
  String get noCommunityActivityYet => _translate('noCommunityActivityYet');
  String get noChangesDetected => _translate('noChangesDetected');

  // Placeholders
  String get usernamePlaceholder => _translate('usernamePlaceholder');
  String get passwordPlaceholder => _translate('passwordPlaceholder');
  String get fullNamePlaceholder => _translate('fullNamePlaceholder');

  // Errors
  String get somethingWentWrong => _translate('somethingWentWrong');
  String get userDataNotAvailable => _translate('userDataNotAvailable');

  //app bar
  String get searchHint => _translate('searchHint');
  String get createPost => _translate('createPost');

  //home_tab
  String get dashboard => _translate('dashboard');
  String get activeCourses => _translate('activeCourses');
  String get allStudents => _translate('allStudents');
  String get myCourses => _translate('myCourses');
  String get noCoursesCreated => _translate('noCoursesCreated');
  String get createNewCourse => _translate('createNewCourse');
  String get recentActivity => _translate('recentActivity');
  String get noRecentEnrollments => _translate('noRecentEnrollments');
  String get recently => _translate('recently');
  String get enrolledIn => _translate('enrolledIn');
  String get noCommunityActivity => _translate('noCommunityActivity');
  String get failedToLoadActivity => _translate('failedToLoadActivity');
  String get posted => _translate('posted');
  String get commentedOn => _translate('commentedOn');
  String get course => _translate('course');
  String get unknownUser => _translate('unknownUser');
  String get noContent => _translate('noContent');
  String get courseProgress => _translate('courseProgress');
  String get noCoursesEnrolledYet => _translate('noCoursesEnrolledYet');
  String get unknownInstructor => _translate('unknownInstructor');
  String get untitledCourse => _translate('untitledCourse');
  String get skillDevelopment => _translate('skillDevelopment');
  String get enrollInCoursesToDevelopSkills =>
      _translate('enrollInCoursesToDevelopSkills');
  String get learners => _translate('learners');
  String get companies => _translate('companies');
  String get recommendedForYou => _translate('recommendedForYou');
  String get noCoursesFound => _translate('noCoursesFound');
  String get unknownCourse => _translate('unknownCourse');
  String get noDescriptionAvailable => _translate('noDescriptionAvailable');
  String get viewCourse => _translate('viewCourse');
  String get liked => _translate('liked');
  String get retry => _translate('retry');
  String get noPostsYet => _translate('noPostsYet');
  String get beFirstToShare => _translate('beFirstToShare');
  String get noPostsAvailable => _translate('noPostsAvailable');
  String get noCoursesYet => _translate('noCoursesYet');
  String get invalidCourseId => _translate('invalidCourseId');
  String get untitled => _translate('untitled');
  String get noCategory => _translate('noCategory');
  String get createCourse => _translate('createCourse');
  String get editCourse => _translate('editCourse');
  String get title => _translate('title');
  String get enterTitle => _translate('enterTitle');
  String get category => _translate('category');
  String get description => _translate('description');
  String get priceDollar => _translate('priceDollar');
  String get enterPrice => _translate('enterPrice');
  String get enterValidNumber => _translate('enterValidNumber');
  String get videos => _translate('videos');
  String get selectVideos => _translate('selectVideos');
  String get updateCourse => _translate('updateCourse');
  String get continueLearning => _translate('continueLearning');
  String get courseDetails => _translate('courseDetails');
  String get notAvailable => _translate('notAvailable');
  String get noVideosAvailable => _translate('noVideosAvailable');
  String get untitledVideo => _translate('untitledVideo');
  String get enrollToUnlock => _translate('enrollToUnlock');
  String get locked => _translate('locked');
  String get watch => _translate('watch');
  String get videoUrlEmpty => _translate('videoUrlEmpty');
  String get removeFromCart => _translate('removeFromCart');
  String get addToCart => _translate('addToCart');
  String get students => _translate('student(s)');
  String get enrolledStudents => _translate('enrolledStudents');
  String get price => _translate('price');
  String get level => _translate('level');
  String get selectLevel => _translate('selectLevel');
  String get updatedAt => _translate('updatedAt');
  String get existingVideos => _translate('existingVideos');
  String get newVideos => _translate('newVideos');
  String get deleteVideo => _translate('deleteVideo');
  String get confirmDeleteVideo => _translate('confirmDeleteVideo');
  String get coverImage => _translate('coverImage');
  String get selectCoverImage => _translate('selectCoverImage');
  String get changeCoverImage => _translate('changeCoverImage');

  // Post Details Screen (Community/Post Details)
  String get post => _translate('post');
  String get unknown => _translate('unknown');
  String get comments => _translate('comments');
  String get beFirstToComment => _translate('beFirstToComment');
  String get writeAComment => _translate('writeAComment');
  String get errorAddingComment => _translate('errorAddingComment');
  String get commentAdded => _translate('commentAdded');
  String get commentDeleted => _translate('commentDeleted');
  String get deleteComment => _translate('deleteComment');
  String get confirmDeleteComment => _translate('confirmDeleteComment');
  String get like => _translate('like');
  String get unlike => _translate('unlike');
  String get share => _translate('share');
  String get report => _translate('report');
  String get postDetails => _translate('postDetails');
  String get author => _translate('author');
  String get createdAt => _translate('createdAt');
  String get replies => _translate('replies');
  String get reply => _translate('reply');
  String get seeMoreComments => _translate('seeMoreComments');
  String get loadingComments => _translate('loadingComments');
  String get noMoreComments => _translate('noMoreComments');
  String get addImage => _translate('addImage');
  String get changeImage => _translate('changeImage');
  String get charactersRemaining => _translate('charactersRemaining');
  String get deletePost => _translate('deletePost');
  String get confirmDeletePost => _translate('confirmDeletePost');

  //favorites
  String get noFavouritesYet => _translate('noFavouritesYet');
  String get addCoursesToFavourites => _translate('addCoursesToFavourites');
  String get free => _translate('free');
  String get today => _translate('today');
  String get yesterday => _translate('yesterday');
  String get daysAgo => _translate('daysAgo');
  String get weeksAgo => _translate('weeksAgo');
  String get monthsAgo => _translate('monthsAgo');
  String get yearsAgo => _translate('yearsAgo');

  //shopping cart
  String get shoppingCart => _translate('shoppingCart');
  String get cartEmpty => _translate('cartEmpty');
  String get addCoursesToStart => _translate('addCoursesToStart');
  String get total => _translate('total');
  String get paymentFeatureComingSoon => _translate('paymentFeatureComingSoon');
  String get proceedToPayment => _translate('proceedToPayment');

  // Payment
  String get securePayment => _translate('securePayment');
  String get loadingPaymentPage => _translate('loadingPaymentPage');
  String get cancelPayment => _translate('cancelPayment');
  String get cancelPaymentConfirmation =>
      _translate('cancelPaymentConfirmation');
  String get yes => _translate('yes');
  String get no => _translate('no');
  String get paymentSuccessful => _translate('paymentSuccessful');
  String get paymentFailed => _translate('paymentFailed');
  String get paymentCancelled => _translate('paymentCancelled');
  String get verifyingPayment => _translate('verifyingPayment');
  String get enrolledSuccessfully => _translate('enrolledSuccessfully');
  String get viewMyCourses => _translate('viewMyCourses');
  String get paymentError => _translate('paymentError');

  //search
  String get tryDifferentKeywords => _translate('tryDifferentKeywords');
  String get searchForCourses => _translate('searchForCourses');

  // Course Reviews
  String get courseReviews => _translate('courseReviews');
  String get instructorReviews => _translate('instructorReviews');
// Reviews and Ratings
  String get reviews => _translate('reviews');
  String get anonymous => _translate('anonymous');
  String get you => _translate('you');
  String get addReview => _translate('addReview');
  String get yourReview => _translate('yourReview');
  String get noReviewsYet => _translate('noReviewsYet');
  String get editReview => _translate('editReview');
  String get deleteReview => _translate('deleteReview');
  String get rating => _translate('rating');
  String get review => _translate('review');
  String get averageRating => _translate('averageRating');
  String get stars => _translate('stars');
  String get star => _translate('star');
  String get reviewTitle => _translate('reviewTitle');
  String get reviewComment => _translate('reviewComment');
  String get submitReview => _translate('submitReview');
  String get reviewSubmitted => _translate('reviewSubmitted');
  String get reviewUpdated => _translate('reviewUpdated');
  String get reviewDeleted => _translate('reviewDeleted');
  String get confirmDeleteReview => _translate('confirmDeleteReview');
  String get writeYourReview => _translate('writeYourReview');
  String get selectRating => _translate('selectRating');
  String get editYourReview => _translate('editYourReview');
  String get writeAReview => _translate('writeAReview');
  String get likes => _translate('likes');
  String get beFirstToReview => _translate('beFirstToReview');

  String _translate(String key) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTranslations[key] ?? _englishTranslations[key] ?? key;
      default:
        return _englishTranslations[key] ?? key;
    }
  }

  static final Map<String, String> _englishTranslations = {
    // App Common
    'appTitle': 'Codexa',
    'welcome': 'Welcome',
    'orContinueWith': 'or continue with',
    'registerForFree': 'Register for free',
    'loginNow': 'Login Now',
    'alreadyHaveAccount': 'Already Have An Account? ',
    'dontHaveAccount': "Don't have an account yet? ",
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'confirm': 'Confirm',
    'continueText': 'Continue',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'finish': 'Finish',
    'search': 'Search',
    'clear': 'Clear',
    'submit': 'Submit',
    'send': 'Send',
    'add': 'Add',
    'remove': 'Remove',
    'update': 'Update',
    'create': 'Create',
    'view': 'View',
    'profile': 'Profile',
    'settings': 'Settings',
    'logout': 'Logout',
    'language': 'Language',
    'theme': 'Theme',
    'darkTheme': 'Dark Theme',
    'help': 'Help',
    'about': 'About',
    'privacy': 'Privacy',
    'notifications': 'Notifications',

    // Login Screen
    'login': 'Login',
    'signIn': 'Sign in',
    'iAmA': 'I am a:',
    'student': 'Student',
    'instructor': 'Instructor',
    'email': 'Email',
    'password': 'Password',
    'forgotPassword': 'Forgot Password?',
    'enterValidEmail': 'Enter a valid email',
    'emailCannotBeEmpty': 'Email cannot be empty',
    'passwordCannotBeEmpty': 'Password cannot be empty',
    'passwordMinLength': 'Password must be at least 6 characters',
    'selectRole': 'Please select a role (Student or Instructor)',
    'selectRoleSocial': 'Please select a role before social login',
    'loginFailed': 'Login failed',
    'loginSuccess': 'Logged in successfully!',
    'googleLoginFailed': 'Google login failed',
    'githubLoginFailed': 'GitHub login failed',

    // Register Screen
    'register': 'Register',
    'registerTitle': 'Register',
    'fullName': 'Full Name',
    'confirmPassword': 'Confirm Password',
    'enterValidName': 'Enter valid full name',
    'passwordTooShort': 'Password too short',
    'passwordsDoNotMatch': 'Passwords do not match',
    'registrationSuccessful': 'Registration Successful! Redirecting...',
    'registrationFailed': 'Registration failed',

    // Profile Screen
    'profileTitle': 'Profile',
    'studentProfile': 'Student Profile',
    'instructorProfile': 'Instructor Profile',
    'editProfile': 'Edit Profile',
    'saveChanges': 'Save Changes',
    'cancelEditing': 'Cancel',
    'changeProfilePicture': 'Change Profile Picture',
    'chooseFromGallery': 'Choose from Gallery',
    'takePhoto': 'Take Photo',
    'newImageSelected': 'New image selected',
    'imageSelectionRemoved': 'Image selection removed',
    'profileUpdated': 'Profile updated successfully',
    'enterName': 'Please enter your name',
    'enterEmail': 'Please enter your email',
    'validEmail': 'Please enter a valid email address',
    'profilePreview': 'Profile Preview',
    'tapToChangePhoto': 'Tap the camera icon to change photo',
    'updatingProfile': 'Updating profile...',
    'removeSelectedImage': 'Remove selected image',
    'communityActivity': 'Community Activity',
    'postsAndEngagement': 'Posts & engagement in the community',
    'noCommunityActivityYet': 'No community posts yet',
    'errorLoadingPosts': 'Error loading posts',
    'somethingWentWrong': 'Something went wrong',
    'noChangesDetected': 'No changes detected',

    // Placeholders
    'usernamePlaceholder': 'username@gmail.com',
    'passwordPlaceholder': 'Password',
    'fullNamePlaceholder': 'Full Name',

    // Errors
    'somethingWentWrong': 'Something went wrong',
    'userDataNotAvailable': 'User data not available',

    //Tabs
    'home': 'Home',
    'courses': 'Courses',
    'community': 'Community',
    'favorites': 'Favorites',

    //app bar
    'searchHint': 'Search for courses...',
    'createPost': 'Create Post',

    //home tab
    'dashboard': 'Dashboard',
    'activeCourses': 'Active Courses',
    'allStudents': 'All Students',
    'myCourses': 'My Courses',
    'noCoursesCreated': 'No courses created yet.',
    'createNewCourse': 'Create new Course',
    'recentActivity': 'Recent Activity',
    'noRecentEnrollments': 'No recent enrollments.',
    'recently': 'Recently',
    'enrolledIn': 'enrolled in',
    'noCommunityActivity': 'No community activity yet.',
    'failedToLoadActivity': 'Failed to load activity',
    'posted': 'posted',
    'commentedOn': 'commented on',
    'course': 'Course',
    'unknownUser': 'Unknown User',
    'noContent': 'No content',
    'courseProgress': 'Course Progress',
    'noCoursesEnrolledYet': 'No courses enrolled yet.',
    'unknownInstructor': 'Unknown Instructor',
    'untitledCourse': 'Untitled Course',
    'skillDevelopment': 'Skill Development',
    'enrollInCoursesToDevelopSkills': 'Enroll in courses to develop skills.',
    'learners': 'Learners',
    'companies': 'Companies',
    'recommendedForYou': 'Recommended for You',
    'noCoursesFound': 'No courses found',
    'unknownCourse': 'Unknown Course',
    'noDescriptionAvailable': 'No description available.',
    'viewCourse': 'View Course',
    'liked': 'liked',

    //community
    'retry': 'Retry',
    'noPostsYet': 'No posts yet',
    'beFirstToShare': 'Be the first to share something!',
    'noPostsAvailable': 'No posts available',

    //courses
    'noCoursesYet': 'No courses yet',
    'invalidCourseId': 'Error: Invalid course ID',
    'untitled': 'Untitled',
    'noCategory': 'No category',
    'createCourse': 'Create Course',
    'editCourse': 'Edit Course',
    'title': 'Title',
    'enterTitle': 'Enter title',
    'category': 'Category',
    'description': 'Description',
    'priceDollar': 'Price (\$)',
    'enterPrice': 'Enter price',
    'enterValidNumber': 'Enter valid number',
    'videos': 'Videos',
    'selectVideos': 'Select Videos',
    'updateCourse': 'Update Course',
    'continueLearning': 'Continue Learning',
    'courseDetails': 'Course Details',
    'notAvailable': 'N/A',
    'noVideosAvailable': 'No videos available yet.',
    'untitledVideo': 'Untitled Video',
    'enrollToUnlock': 'Enroll to unlock',
    'locked': 'Locked',
    'watch': 'Watch',
    'videoUrlEmpty': 'Video URL is empty',
    'removeFromCart': 'Remove from Cart',
    'addToCart': 'Add to Cart',
    'student(s)': 'student(s)',
    'enrolledStudents': 'Enrolled Students',
    'price': 'Price',
    'level': 'Level',
    'selectLevel': 'Select Level',
    'updatedAt': 'Updated At',
    'existingVideos': 'Existing Videos',
    'newVideos': 'New Videos (pending upload)',
    'deleteVideo': 'Delete Video',
    'confirmDeleteVideo': 'Are you sure you want to delete this video?',
    'coverImage': 'Cover Image',
    'selectCoverImage': 'Select Cover Image',
    'changeCoverImage': 'Change Cover Image',

    // Post Details Screen (Community/Post Details)
    'post': 'Post',
    'unknown': 'Unknown',
    'comments': 'Comments',
    'beFirstToComment': 'Be first to comment',
    'writeAComment': 'Write a comment...',
    'errorAddingComment': 'Error adding comment',
    'commentAdded': 'Comment added successfully',
    'commentDeleted': 'Comment deleted successfully',
    'deleteComment': 'Delete Comment',
    'confirmDeleteComment': 'Are you sure you want to delete this comment?',
    'like': 'Like',
    'unlike': 'Unlike',
    'share': 'Share',
    'report': 'Report',
    'postDetails': 'Post Details',
    'author': 'Author',
    'createdAt': 'Created at',
    'replies': 'Replies',
    'reply': 'Reply',
    'seeMoreComments': 'See more comments',
    'loadingComments': 'Loading comments...',
    'noMoreComments': 'No more comments',
    'addImage': 'Add Image',
    'changeImage': 'Change Image',
    'charactersRemaining': 'characters remaining',
    'deletePost': 'Delete Post',
    'confirmDeletePost':
        'Do you really want to delete this post? This action cannot be undone.',

    //favorites
    'noFavouritesYet': 'No favourites yet',
    'addCoursesToFavourites': 'Add courses to your favourites',
    'free': 'Free',
    'today': 'Today',
    'yesterday': 'Yesterday',
    'daysAgo': 'days ago',
    'weeksAgo': 'weeks ago',
    'monthsAgo': 'months ago',
    'yearsAgo': 'years ago',

    //shopping cart
    'shoppingCart': 'Shopping Cart',
    'cartEmpty': 'Your cart is empty',
    'addCoursesToStart': 'Add courses to get started',
    'total': 'Total',
    'paymentFeatureComingSoon': 'Payment feature coming soon!',
    'proceedToPayment': 'Proceed to Payment',

    // Payment
    'securePayment': 'Secure Payment',
    'loadingPaymentPage': 'Loading payment page...',
    'cancelPayment': 'Cancel Payment',
    'cancelPaymentConfirmation':
        'Are you sure you want to cancel this payment?',
    'yes': 'Yes',
    'no': 'No',
    'paymentSuccessful': 'Payment Successful!',
    'paymentFailed': 'Payment Failed',
    'paymentCancelled': 'Payment was cancelled',
    'verifyingPayment': 'Verifying payment...',
    'enrolledSuccessfully': 'You are now enrolled in the courses!',
    'viewMyCourses': 'View My Courses',
    'paymentError': 'Payment error occurred',

    //search
    'tryDifferentKeywords': 'Try different keywords or check back later',
    'searchForCourses': 'Search for courses',

    // course reviews
    'courseReviews': 'Course Reviews',
    'instructorReviews': 'Instructor Reviews',
    'addReview': 'Add Review',
    'yourReview': 'Your Review',
    'noReviewsYet': 'No reviews yet',
    'beFirstToReview': 'Be the first to review',
    'editReview': 'Edit Review',
    'deleteReview': 'Delete Review',
    'rating': 'Rating',
    'review': 'Review',
    'reviews': 'Reviews',
    'averageRating': 'Average Rating',
    'stars': 'stars',
    'star': 'star',
    'reviewTitle': 'Review Title',
    'reviewComment': 'Review Comment',
    'submitReview': 'Submit Review',
    'reviewSubmitted': 'Review submitted successfully',
    'reviewUpdated': 'Review updated successfully',
    'reviewDeleted': 'Review deleted successfully',
    'confirmDeleteReview': 'Are you sure you want to delete this review?',
    'writeYourReview': 'Write your review here...',
    'selectRating': 'Select a rating',
    'anonymous': 'Anonymous',
    'you': 'You',
    'likes': 'likes',
    'writeAReview': 'Write a review',
    'editYourReview': 'Edit your review',
  };

  static final Map<String, String> _arabicTranslations = {
    // App Common
    'appTitle': 'كوديكسا',
    'welcome': 'مرحباً',
    'orContinueWith': 'أو متابعة باستخدام',
    'registerForFree': 'سجل مجاناً',
    'loginNow': 'سجل الدخول الآن',
    'alreadyHaveAccount': 'هل لديك حساب بالفعل؟ ',
    'dontHaveAccount': 'ليس لديك حساب بعد؟ ',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'confirm': 'تأكيد',
    'continueText': 'متابعة',
    'back': 'رجوع',
    'next': 'التالي',
    'skip': 'تخطي',
    'finish': 'إنهاء',
    'search': 'بحث',
    'clear': 'مسح',
    'submit': 'إرسال',
    'send': 'إرسال',
    'add': 'إضافة',
    'remove': 'إزالة',
    'update': 'تحديث',
    'create': 'إنشاء',
    'view': 'عرض',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'logout': 'تسجيل الخروج',
    'language': 'اللغة',
    'theme': 'الثيم',
    'darkTheme': 'الثيم الداكن',
    'help': 'مساعدة',
    'about': 'حول',
    'privacy': 'الخصوصية',
    'notifications': 'الإشعارات',

    // Login Screen
    'login': 'تسجيل الدخول',
    'signIn': 'تسجيل الدخول',
    'iAmA': 'أنا:',
    'student': 'طالب',
    'instructor': 'مدرس',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'enterValidEmail': 'أدخل بريد إلكتروني صحيح',
    'emailCannotBeEmpty': 'البريد الإلكتروني لا يمكن أن يكون فارغاً',
    'passwordCannotBeEmpty': 'كلمة المرور لا يمكن أن تكون فارغة',
    'passwordMinLength': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'selectRole': 'الرجاء اختيار دور (طالب أو مدرس)',
    'selectRoleSocial': 'الرجاء اختيار دور قبل التسجيل الاجتماعي',
    'loginFailed': 'فشل تسجيل الدخول',
    'loginSuccess': 'تم تسجيل الدخول بنجاح!',
    'googleLoginFailed': 'فشل تسجيل الدخول عبر جوجل',
    'githubLoginFailed': 'فشل تسجيل الدخول عبر جيثب',

    // Register Screen
    'register': 'تسجيل',
    'registerTitle': 'التسجيل',
    'fullName': 'الاسم الكامل',
    'confirmPassword': 'تأكيد كلمة المرور',
    'enterValidName': 'أدخل اسم كامل صحيح',
    'passwordTooShort': 'كلمة المرور قصيرة جداً',
    'passwordsDoNotMatch': 'كلمات المرور لا تتطابق',
    'registrationSuccessful': 'تم التسجيل بنجاح! جاري التوجيه...',
    'registrationFailed': 'فشل التسجيل',

    // Profile Screen
    'profileTitle': 'الملف الشخصي',
    'studentProfile': 'ملف الطالب',
    'instructorProfile': 'ملف المدرس',
    'editProfile': 'تعديل الملف',
    'saveChanges': 'حفظ التغييرات',
    'cancelEditing': 'إلغاء التعديل',
    'changeProfilePicture': 'تغيير صورة الملف',
    'chooseFromGallery': 'اختيار من المعرض',
    'takePhoto': 'التقاط صورة',
    'newImageSelected': 'تم اختيار صورة جديدة',
    'imageSelectionRemoved': 'تمت إزالة اختيار الصورة',
    'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
    'enterName': 'الرجاء إدخال اسمك',
    'enterEmail': 'الرجاء إدخال بريدك الإلكتروني',
    'validEmail': 'الرجاء إدخال بريد إلكتروني صحيح',
    'profilePreview': 'معاينة الملف',
    'tapToChangePhoto': 'انقر على أيقونة الكاميرا لتغيير الصورة',
    'updatingProfile': 'جاري تحديث الملف...',
    'removeSelectedImage': 'إزالة الصورة المختارة',
    'communityActivity': 'النشاط المجتمعي',
    'postsAndEngagement': 'المشاركات والتفاعل في المجتمع',
    'noCommunityActivityYet': 'لا توجد مشاركات مجتمعية بعد',
    'errorLoadingPosts': 'خطأ في تحميل المشاركات',
    'noChangesDetected': 'لم يتم اكتشاف أي تغييرات',

    // Placeholders
    'usernamePlaceholder': 'اسم المستخدم@gmail.com',
    'passwordPlaceholder': 'كلمة المرور',
    'fullNamePlaceholder': 'الاسم الكامل',

    // Errors
    'somethingWentWrong': 'حدث خطأ ما',
    'userDataNotAvailable': 'بيانات المستخدم غير متاحة',

    //Tabs
    'home': 'الرئيسية',
    'courses': 'الدورات',
    'community': 'المجتمع',
    'favorites': 'المفضلة',

    //app bar
    'searchHint': 'ابحث عن الدورات...',
    'createPost': 'إنشاء منشور',

    //home tab
    'dashboard': 'لوحة التحكم',
    'activeCourses': 'الدورات النشطة',
    'allStudents': 'جميع الطلاب',
    'myCourses': 'دوراتي',
    'noCoursesCreated': 'لا توجد دورات مضافة بعد.',
    'createNewCourse': 'إنشاء دورة جديدة',
    'recentActivity': 'النشاط الأخير',
    'noRecentEnrollments': 'لا توجد تسجيلات حديثة.',
    'recently': 'مؤخراً',
    'enrolledIn': 'سجل في',
    'noCommunityActivity': 'لا يوجد نشاط مجتمعي بعد.',
    'failedToLoadActivity': 'فشل تحميل النشاط',
    'posted': 'نشر',
    'commentedOn': 'علق على',
    'course': 'دورة',
    'unknownUser': 'مستخدم غير معروف',
    'noContent': 'لا يوجد محتوى',
    'courseProgress': 'تقدم الدورة',
    'noCoursesEnrolledYet': 'لا توجد دورات مسجلة بعد.',
    'unknownInstructor': 'مدرس غير معروف',
    'untitledCourse': 'دورة بدون عنوان',
    'skillDevelopment': 'تطوير المهارات',
    'enrollInCoursesToDevelopSkills': 'سجل في الدورات لتطوير المهارات.',
    'learners': 'المتعلمين',
    'companies': 'الشركات',
    'recommendedForYou': 'موصى به لك',
    'noCoursesFound': 'لا توجد دورات',
    'unknownCourse': 'دورة غير معروفة',
    'noDescriptionAvailable': 'لا يوجد وصف متاح.',
    'viewCourse': 'عرض الدورة',
    'liked': 'أعجب',

    //community
    'retry': 'إعادة المحاولة',
    'noPostsYet': 'لا توجد مشاركات بعد',
    'beFirstToShare': 'كن أول من يشارك شيئاً!',
    'noPostsAvailable': 'لا توجد مشاركات متاحة',

    //courses
    'noCoursesYet': 'لا توجد دورات بعد',
    'invalidCourseId': 'خطأ: معرف الدورة غير صالح',
    'untitled': 'بدون عنوان',
    'noCategory': 'لا يوجد تصنيف',
    'createCourse': 'إنشاء دورة',
    'editCourse': 'تعديل الدورة',
    'title': 'العنوان',
    'enterTitle': 'أدخل العنوان',
    'category': 'التصنيف',
    'description': 'الوصف',
    'priceDollar': 'السعر (\$)',
    'enterPrice': 'أدخل السعر',
    'enterValidNumber': 'أدخل رقم صحيح',
    'videos': 'الفيديوهات',
    'selectVideos': 'اختيار الفيديوهات',
    'updateCourse': 'تحديث الدورة',
    'continueLearning': 'مواصلة التعلم',
    'courseDetails': 'تفاصيل الدورة',
    'notAvailable': 'غير متوفر',
    'noVideosAvailable': 'لا توجد فيديوهات متاحة بعد.',
    'untitledVideo': 'فيديو بدون عنوان',
    'enrollToUnlock': 'سجل لإلغاء القفل',
    'locked': 'مقفل',
    'watch': 'شاهد',
    'videoUrlEmpty': 'رابط الفيديو فارغ',
    'removeFromCart': 'إزالة من السلة',
    'addToCart': 'أضف إلى السلة',
    'student(s)': 'طالب/طالبين',
    'enrolledStudents': 'الطلاب المسجلون',
    'price': 'السعر',
    'level': 'المستوى',
    'selectLevel': 'اختر مستوي',
    'updatedAt': 'تم التحديث في',
    'existingVideos': 'الفيديوهات الحالية',
    'newVideos': 'فيديوهات جديدة (قيد الرفع)',
    'deleteVideo': 'حذف الفيديو',
    'confirmDeleteVideo': 'هل أنت متأكد من حذف هذا الفيديو؟',
    'coverImage': 'صورة الغلاف',
    'selectCoverImage': 'اختر صورة الغلاف',
    'changeCoverImage': 'تغيير صورة الغلاف',

    // Post Details Screen (Community/Post Details)
    'post': 'منشور',
    'unknown': 'غير معروف',
    'comments': 'التعليقات',
    'beFirstToComment': 'كن أول من يعلق',
    'writeAComment': 'اكتب تعليقاً...',
    'errorAddingComment': 'حدث خطأ في إضافة التعليق',
    'commentAdded': 'تمت إضافة التعليق بنجاح',
    'commentDeleted': 'تم حذف التعليق بنجاح',
    'deleteComment': 'حذف التعليق',
    'confirmDeleteComment': 'هل أنت متأكد من حذف هذا التعليق؟',
    'like': 'إعجاب',
    'unlike': 'إلغاء الإعجاب',
    'share': 'مشاركة',
    'report': 'تقرير',
    'postDetails': 'تفاصيل المنشور',
    'author': 'المؤلف',
    'createdAt': 'تم الإنشاء في',
    'replies': 'الردود',
    'reply': 'رد',
    'seeMoreComments': 'رؤية المزيد من التعليقات',
    'loadingComments': 'جاري تحميل التعليقات...',
    'noMoreComments': 'لا يوجد المزيد من التعليقات',
    'addImage': 'إضافة صورة',
    'changeImage': 'تغيير الصورة',
    'charactersRemaining': 'حروف متبقية',
    'deletePost': 'حذف المنشور',
    'confirmDeletePost':
        'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',

    //favorites
    'noFavouritesYet': 'لا توجد مفضلات بعد',
    'addCoursesToFavourites': 'أضف دورات إلى مفضلتك',
    'free': 'مجاني',
    'today': 'اليوم',
    'yesterday': 'أمس',
    'daysAgo': 'أيام مضت',
    'weeksAgo': 'أسابيع مضت',
    'monthsAgo': 'شهور مضت',
    'yearsAgo': 'سنوات مضت',

    //shopping cart
    'shoppingCart': 'عربة التسوق',
    'cartEmpty': 'عربة التسوق فارغة',
    'addCoursesToStart': 'أضف دورات للبدء',
    'total': 'المجموع',
    'paymentFeatureComingSoon': 'ميزة الدفع قريباً!',
    'proceedToPayment': 'تابع للدفع',

    // Payment
    'securePayment': 'دفع آمن',
    'loadingPaymentPage': 'جاري تحميل صفحة الدفع...',
    'cancelPayment': 'إلغاء الدفع',
    'cancelPaymentConfirmation': 'هل أنت متأكد من إلغاء هذا الدفع؟',
    'yes': 'نعم',
    'no': 'لا',
    'paymentSuccessful': 'تم الدفع بنجاح!',
    'paymentFailed': 'فشل الدفع',
    'paymentCancelled': 'تم إلغاء الدفع',
    'verifyingPayment': 'جاري التحقق من الدفع...',
    'enrolledSuccessfully': 'أنت مسجل الآن في الدورات!',
    'viewMyCourses': 'عرض دوراتي',
    'paymentError': 'حدث خطأ في الدفع',

    //search
    'tryDifferentKeywords': 'جرب كلمات مفتاحية مختلفة أو تحقق لاحقاً',
    'searchForCourses': 'ابحث عن الدورات',

    //course reviews
    'courseReviews': 'تقييمات الدورة',
    'instructorReviews': 'تقييمات المدرس',
    'addReview': 'إضافة تقييم',
    'yourReview': 'تقييمك',
    'noReviewsYet': 'لا توجد تقييمات بعد',
    'beFirstToReview': 'كن أول من يقيم',
    'editReview': 'تعديل التقييم',
    'deleteReview': 'حذف التقييم',
    'rating': 'التقييم',
    'review': 'تقييم',
    'reviews': 'التقييمات',
    'averageRating': 'متوسط التقييم',
    'stars': 'نجوم',
    'star': 'نجمة',
    'reviewTitle': 'عنوان التقييم',
    'reviewComment': 'تعليق التقييم',
    'submitReview': 'إرسال التقييم',
    'reviewSubmitted': 'تم إرسال التقييم بنجاح',
    'reviewUpdated': 'تم تحديث التقييم بنجاح',
    'reviewDeleted': 'تم حذف التقييم بنجاح',
    'confirmDeleteReview': 'هل أنت متأكد من حذف هذا التقييم؟',
    'writeYourReview': 'اكتب تقييمك هنا...',
    'selectRating': 'اختر تقييماً',
    'anonymous': 'مجهول',
    'you': 'أنت',
    'likes': 'إعجابات',
    'writeAReview': 'اكتب تقييم',
    'editYourReview': 'عدل تقييمك',
  };
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) {
    final s = S(locale);
    S.updateLocale(locale); // Update the static current instance
    return SynchronousFuture<S>(s);
  }

  @override
  bool shouldReload(_SDelegate old) => false;
}

class _InheritedS extends InheritedWidget {
  const _InheritedS({
    required this.localizations,
    required super.child,
  });

  final S localizations;

  @override
  bool updateShouldNotify(_InheritedS old) => false;
}
