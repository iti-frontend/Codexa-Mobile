import 'dart:io';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_states.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/generated/l10n.dart';
import 'profile_cubit/profile_cubit.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen<T> extends StatefulWidget {
  static const String routeName = "/profile";

  final T user;
  final String userType;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.userType,
  });

  @override
  State<ProfileScreen<T>> createState() => _ProfileScreenState<T>();
}

class _ProfileScreenState<T> extends State<ProfileScreen<T>> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    print('🎯 ProfileScreen initialized for ${widget.userType}');
    print('👤 User: ${widget.user}');
  }

  void _initializeControllers() {
    if (widget.user is StudentEntity) {
      final student = widget.user as StudentEntity;
      nameController = TextEditingController(text: student.name ?? '');
      emailController = TextEditingController(text: student.email ?? '');
    } else if (widget.user is InstructorEntity) {
      final instructor = widget.user as InstructorEntity;
      nameController = TextEditingController(text: instructor.name ?? '');
      emailController = TextEditingController(text: instructor.email ?? '');
    } else {
      nameController = TextEditingController();
      emailController = TextEditingController();
    }
  }

  String get _userName {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).name ?? S.of(context).student;
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).name ?? S.of(context).instructor;
    }
    return S.of(context).profile;
  }

  String get _userEmail {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).email ?? '';
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).email ?? '';
    }
    return '';
  }

  String get _userProfileImage {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).profileImage ?? '';
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).profileImage ?? '';
    }
    return '';
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    print('✏️ Started editing profile');
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      _initializeControllers(); // Reset to original values
    });
    print('❌ Cancelled editing');
  }

  // Image picking methods
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).somethingWentWrong}: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  S.of(context).changeProfilePicture,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: S.of(context).chooseFromGallery,
                onTap: _pickImageFromGallery,
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: Text(
                    S.of(context).cancel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.progressIndicatorTheme.color?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: theme.progressIndicatorTheme.color,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.iconTheme.color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.iconTheme.color,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
    _showSuccessSnackBar(S.of(context).imageSelectionRemoved);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Language switcher dialog
  void _showLanguageDialog() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              onTap: () => _changeLanguage('en', localizationService),
            ),
            ListTile(
              leading: const Text('🇸🇦'),
              title: const Text('العربية'),
              onTap: () => _changeLanguage('ar', localizationService),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(String languageCode, LocalizationService localizationService) async {
    await localizationService.changeLanguage(languageCode);
    Navigator.pop(context); // Close language dialog

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageCode == 'en'
            ? 'Language changed to English'
            : 'تم تغيير اللغة إلى العربية'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to home to apply changes
    Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    print('🎯 Building ProfileScreen for ${widget.userType}');

    return BlocConsumer<ProfileCubit<T>, ProfileState>(
      listener: (context, state) {
        print('🎯 BlocConsumer Listener - Current state: $state');

        if (state is ProfileSuccess<T>) {
          print('✅ Profile update successful!');
          _updateAuthProvider(state.user);

          setState(() {
            _isEditing = false;
            _selectedImage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).profileUpdated),
              backgroundColor: Colors.green,
            ),
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              print('🔙 Navigating back after successful update');
              Navigator.pop(context);
            }
          });
        } else if (state is ProfileError) {
          print('❌ Profile error: ${state.failure.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.errorMessage ?? S.of(context).somethingWentWrong),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProfileLoading) {
          print('⏳ Profile update in progress...');
        }
      },
      builder: (context, state) {
        print('🎯 BlocConsumer Builder - Current state: $state');

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
            foregroundColor: theme.iconTheme.color,
            title: Text(
              widget.userType == 'Student'
                  ? S.of(context).studentProfile
                  : S.of(context).instructorProfile,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.iconTheme.color,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              onPressed: () {
                print('🔙 Back button pressed');
                Navigator.pop(context);
              },
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: Icon(Icons.edit, color: theme.iconTheme.color),
                  onPressed: _startEditing,
                  tooltip: S.of(context).editProfile,
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile image section
                _buildProfileImageSection(theme),
                const SizedBox(height: 32),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Selected image info
                        if (_isEditing && _selectedImage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.progressIndicatorTheme.color?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.progressIndicatorTheme.color?.withOpacity(0.3) ?? Colors.blue,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: theme.progressIndicatorTheme.color, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).newImageSelected,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.progressIndicatorTheme.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedImage!.path
                                            .split('/')
                                            .last,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.iconTheme.color?.withOpacity(0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: _removeSelectedImage,
                                  icon: Icon(Icons.delete_outline,
                                      color: theme.iconTheme.color),
                                  tooltip: S.of(context).remove,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Name field
                        _buildModernTextField(
                          theme: theme,
                          controller: nameController,
                          label: S.of(context).fullName,
                          icon: Icons.person_outline,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        _buildModernTextField(
                          theme: theme,
                          controller: emailController,
                          label: S.of(context).email,
                          icon: Icons.email_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // Language Settings
                        if (!_isEditing) ...[
                          const SizedBox(height: 30),
                          Text(
                            S.of(context).settings,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.iconTheme.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: theme.cardTheme.color,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.progressIndicatorTheme.color?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.language,
                                  color: theme.progressIndicatorTheme.color,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                S.of(context).language,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                              subtitle: Text(
                                localizationService.isRTL() ? 'العربية' : 'English',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.iconTheme.color?.withOpacity(0.6),
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.iconTheme.color,
                              ),
                              onTap: _showLanguageDialog,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        const SizedBox(height: 40),

                        // Action buttons
                        if (_isEditing) ...[
                          state is ProfileLoading
                              ? _buildLoadingState(theme)
                              : _buildActionButtons(theme),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: enabled ? theme.cardTheme.color : theme.cardTheme.color?.withOpacity(0.5),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? theme.dividerTheme.color : theme.iconTheme.color?.withOpacity(0.5),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: enabled
                  ? theme.progressIndicatorTheme.color
                  : theme.iconTheme.color?.withOpacity(0.3),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.progressIndicatorTheme.color ?? Colors.blue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceVariant,
                border: Border.all(
                  color: theme.progressIndicatorTheme.color?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
                  width: 3,
                ),
              ),
              child: _getProfileImageWidget(theme),
            ),

            // Camera icon
            if (_isEditing)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.progressIndicatorTheme.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.iconTheme.color,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? S.of(context).profilePreview : _userName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.iconTheme.color,
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 4),
          Text(
            S.of(context).tapToChangePhoto,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.iconTheme.color?.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _getProfileImageWidget(ThemeData theme) {
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading selected image: $error');
            return _buildDefaultProfileIcon(theme);
          },
        ),
      );
    }

    final imageUrl = _userProfileImage;
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading network image: $error');
              return _buildDefaultProfileIcon(theme);
            },
          ),
        );
      } else if (imageUrl.startsWith('assets/') || imageUrl.startsWith('/')) {
        return ClipOval(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading asset image: $error');
              return _buildDefaultProfileIcon(theme);
            },
          ),
        );
      }
    }

    // Default placeholder
    return _buildDefaultProfileIcon(theme);
  }

  Widget _buildDefaultProfileIcon(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 48,
      color: theme.iconTheme.color,
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEditing,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: theme.dividerColor,
              ),
            ),
            child: Text(
              S.of(context).cancelEditing,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Validation
              if (nameController.text.isEmpty) {
                _showErrorSnackBar(S.of(context).enterName);
                return;
              }

              if (emailController.text.isEmpty) {
                _showErrorSnackBar(S.of(context).enterEmail);
                return;
              }

              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
                print('❌ Validation failed: Invalid email format');
                _showErrorSnackBar(S.of(context).validEmail);
                return;
              }

              try {
                final updatedUser = _createUpdatedUser();
                final cubit = context.read<ProfileCubit<T>>();
                cubit.updateProfile(updatedUser);
                print('🚀 updateProfile method called successfully');
              } catch (e, stackTrace){
                _showErrorSnackBar('${S.of(context).error}: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.progressIndicatorTheme.color,
            ),
            child: Text(
              S.of(context).saveChanges,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.iconTheme.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      children: [
        CircularProgressIndicator(
          color: theme.progressIndicatorTheme.color,
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).updatingProfile,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  T _createUpdatedUser() {
    print('🔄 Creating updated user...');

    if (widget.user is StudentEntity) {
      final original = widget.user as StudentEntity;
      final updatedStudent = StudentEntity(
        id: original.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImage: _selectedImage != null
            ? _selectedImage!.path
            : original.profileImage,
        role: original.role,
        isAdmin: original.isAdmin,
        isActive: original.isActive,
        emailVerified: original.emailVerified,
        authProvider: original.authProvider,
        token: original.token,
      ) as T;
      return updatedStudent;
    } else if (widget.user is InstructorEntity) {
      final original = widget.user as InstructorEntity;
      final updatedInstructor = InstructorEntity(
        id: original.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImage: _selectedImage != null
            ? _selectedImage!.path
            : original.profileImage,
        role: original.role,
        isActive: original.isActive,
        emailVerified: original.emailVerified,
        authProvider: original.authProvider,
        token: original.token,
        isAdmin: original.isAdmin,
      ) as T;
      return updatedInstructor;
    }
    throw Exception('Unsupported user type');
  }

  void _updateAuthProvider(T updatedUser) {
    print('🔄 Updating auth provider with new user data');
    final authProvider = Provider.of<UserProvider>(context, listen: false);

    // Use the new updateUser method
    authProvider.updateUser(updatedUser);

    print('✅ Updated user in auth provider: ${updatedUser.runtimeType}');
  }

  @override
  void dispose() {
    print('🗑️ Disposing ProfileScreen');
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}