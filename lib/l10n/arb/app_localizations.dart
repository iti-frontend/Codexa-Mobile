import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Codexa'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @registerForFree.
  ///
  /// In en, this message translates to:
  /// **'Register for free'**
  String get registerForFree;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already Have An Account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get dontHaveAccount;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a:'**
  String get iAmA;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailCannotBeEmpty;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role (Student or Instructor)'**
  String get selectRole;

  /// No description provided for @selectRoleSocial.
  ///
  /// In en, this message translates to:
  /// **'Please select a role before social login'**
  String get selectRoleSocial;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccess;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get googleLoginFailed;

  /// No description provided for @githubLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'GitHub login failed'**
  String get githubLoginFailed;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterValidName.
  ///
  /// In en, this message translates to:
  /// **'Enter valid full name'**
  String get enterValidName;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful! Redirecting...'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @studentProfile.
  ///
  /// In en, this message translates to:
  /// **'Student Profile'**
  String get studentProfile;

  /// No description provided for @instructorProfile.
  ///
  /// In en, this message translates to:
  /// **'Instructor Profile'**
  String get instructorProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancelEditing.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelEditing;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @newImageSelected.
  ///
  /// In en, this message translates to:
  /// **'New image selected'**
  String get newImageSelected;

  /// No description provided for @imageSelectionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Image selection removed'**
  String get imageSelectionRemoved;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmail;

  /// No description provided for @profilePreview.
  ///
  /// In en, this message translates to:
  /// **'Profile Preview'**
  String get profilePreview;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera icon to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @updatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Updating profile...'**
  String get updatingProfile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCourses;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @communityActivity.
  ///
  /// In en, this message translates to:
  /// **'Community Activity'**
  String get communityActivity;

  /// No description provided for @skillDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Skill Development'**
  String get skillDevelopment;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @activeCourse.
  ///
  /// In en, this message translates to:
  /// **'Active Course'**
  String get activeCourse;

  /// No description provided for @allStudents.
  ///
  /// In en, this message translates to:
  /// **'All Students'**
  String get allStudents;

  /// No description provided for @learners.
  ///
  /// In en, this message translates to:
  /// **'Learners'**
  String get learners;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @companies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @viewCourse.
  ///
  /// In en, this message translates to:
  /// **'View Course'**
  String get viewCourse;

  /// No description provided for @enrollToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enroll to unlock'**
  String get enrollToUnlock;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @createNewCourse.
  ///
  /// In en, this message translates to:
  /// **'Create new Course'**
  String get createNewCourse;

  /// No description provided for @chatbot.
  ///
  /// In en, this message translates to:
  /// **'Codexa Chatbot'**
  String get chatbot;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all messages?'**
  String get clearChatConfirm;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @chatbotWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your learning assistant. How can I help you today?'**
  String get chatbotWelcome;

  /// No description provided for @chatbotHi.
  ///
  /// In en, this message translates to:
  /// **'Hi there! 👋 How can I assist you with your learning today?'**
  String get chatbotHi;

  /// No description provided for @chatbotCourses.
  ///
  /// In en, this message translates to:
  /// **'You can browse available courses in the Courses tab. Is there a specific topic you\'re interested in?'**
  String get chatbotCourses;

  /// No description provided for @chatbotProgress.
  ///
  /// In en, this message translates to:
  /// **'Your learning progress is tracked in each course. You can view detailed progress in the course details page.'**
  String get chatbotProgress;

  /// No description provided for @chatbotHelp.
  ///
  /// In en, this message translates to:
  /// **'I\'m here to help! You can ask me about courses, learning progress, or general app features.'**
  String get chatbotHelp;

  /// No description provided for @chatbotThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your message! I\'m here to help with your learning journey. Feel free to ask about courses, progress, or any other questions.'**
  String get chatbotThanks;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreated;

  /// No description provided for @writeSomething.
  ///
  /// In en, this message translates to:
  /// **'Please write something'**
  String get writeSomething;

  /// No description provided for @contentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Content too long (max 500 chars)'**
  String get contentTooLong;

  /// No description provided for @charactersRemaining.
  ///
  /// In en, this message translates to:
  /// **'characters remaining'**
  String get charactersRemaining;

  /// No description provided for @postDetails.
  ///
  /// In en, this message translates to:
  /// **'Post Details'**
  String get postDetails;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @beFirstToComment.
  ///
  /// In en, this message translates to:
  /// **'Be first to comment'**
  String get beFirstToComment;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @deletePostConfirm2.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this post? This action cannot be undone.'**
  String get deletePostConfirm2;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get postDeleted;

  /// No description provided for @cannotDeletePost.
  ///
  /// In en, this message translates to:
  /// **'You can only delete your own posts'**
  String get cannotDeletePost;

  /// No description provided for @invalidPostId.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete post: Invalid ID'**
  String get invalidPostId;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'This comment will be permanently deleted.'**
  String get deleteCommentConfirm;

  /// No description provided for @errorDeletingPost.
  ///
  /// In en, this message translates to:
  /// **'Error deleting post'**
  String get errorDeletingPost;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @enrolledStudents.
  ///
  /// In en, this message translates to:
  /// **'Enrolled Students'**
  String get enrolledStudents;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get updatedAt;

  /// No description provided for @unknownInstructor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Instructor'**
  String get unknownInstructor;

  /// No description provided for @untitledCourse.
  ///
  /// In en, this message translates to:
  /// **'Untitled Course'**
  String get untitledCourse;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available for this course.'**
  String get noDescription;

  /// No description provided for @noVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos available yet.'**
  String get noVideos;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @selectVideos.
  ///
  /// In en, this message translates to:
  /// **'Select Videos'**
  String get selectVideos;

  /// No description provided for @createCourse.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get createCourse;

  /// No description provided for @editCourse.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get editCourse;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid number'**
  String get validNumber;

  /// No description provided for @saveCourse.
  ///
  /// In en, this message translates to:
  /// **'Save Course'**
  String get saveCourse;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addCourses.
  ///
  /// In en, this message translates to:
  /// **'Add courses to get started'**
  String get addCourses;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @paymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment feature coming soon!'**
  String get paymentComingSoon;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart'**
  String get removeFromCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Course added to cart'**
  String get addedToCart;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get removedFromCart;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @noFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavourites;

  /// No description provided for @toggleFavourite.
  ///
  /// In en, this message translates to:
  /// **'Toggle favourite'**
  String get toggleFavourite;

  /// No description provided for @welcomeToCodexa.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Codexa'**
  String get welcomeToCodexa;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your go-to platform for professional growth and community engagement. Connect with peers, learn new skills, and advance your career.'**
  String get welcomeDescription;

  /// No description provided for @learnFromBest.
  ///
  /// In en, this message translates to:
  /// **'Learn from the best'**
  String get learnFromBest;

  /// No description provided for @learnDescription.
  ///
  /// In en, this message translates to:
  /// **'Access high-quality courses, track your progress, and engage with a vibrant community of learners.'**
  String get learnDescription;

  /// No description provided for @highQualityContent.
  ///
  /// In en, this message translates to:
  /// **'High-Quality Content'**
  String get highQualityContent;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Codexa Community'**
  String get joinCommunity;

  /// No description provided for @joinDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with peers, share insights, and grow together in your professional journey.'**
  String get joinDescription;

  /// No description provided for @joinCommunityButton.
  ///
  /// In en, this message translates to:
  /// **'Join Community'**
  String get joinCommunityButton;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorized;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// No description provided for @userDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User data not available'**
  String get userDataNotAvailable;

  /// No description provided for @operationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get operationCancelled;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera and storage permissions in app settings'**
  String get permissionRequired;

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera/Gallery feature not available on this device'**
  String get featureNotAvailable;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @coursesTab.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTab;

  /// No description provided for @communityTab.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTab;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @noCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses yet'**
  String get noCourses;

  /// No description provided for @noCoursesEnrolled.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t enrolled in any courses yet'**
  String get noCoursesEnrolled;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPosts;

  /// No description provided for @beFirstToPost.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share something!'**
  String get beFirstToPost;

  /// No description provided for @noCommunityActivity.
  ///
  /// In en, this message translates to:
  /// **'No community activity yet'**
  String get noCommunityActivity;

  /// No description provided for @noRecentEnrollments.
  ///
  /// In en, this message translates to:
  /// **'No recent enrollments.'**
  String get noRecentEnrollments;

  /// No description provided for @enrollInCourses.
  ///
  /// In en, this message translates to:
  /// **'Enroll in courses to develop skills.'**
  String get enrollInCourses;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'posted'**
  String get posted;

  /// No description provided for @commented.
  ///
  /// In en, this message translates to:
  /// **'commented'**
  String get commented;

  /// No description provided for @commentedOnPost.
  ///
  /// In en, this message translates to:
  /// **'commented on {userName}\'s post'**
  String commentedOnPost(Object userName);

  /// No description provided for @enrolledIn.
  ///
  /// In en, this message translates to:
  /// **'enrolled in'**
  String get enrolledIn;

  /// No description provided for @usernamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'username@gmail.com'**
  String get usernamePlaceholder;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordPlaceholder;

  /// No description provided for @fullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNamePlaceholder;

  /// No description provided for @searchForCourse.
  ///
  /// In en, this message translates to:
  /// **'Search for a course...'**
  String get searchForCourse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
