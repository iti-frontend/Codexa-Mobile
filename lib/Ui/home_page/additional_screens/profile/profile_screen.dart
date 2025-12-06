// Complete ProfileScreen with RTL support
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

  // Store translations instance
  late S _translations;
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Get the LocalizationService singleton instance
    _localizationService = LocalizationService();

    // Initialize with current locale
    _translations = S(_localizationService.locale);

    print('🎯 ProfileScreen initialized for ${widget.userType}');
    print('🌐 Current locale: ${_localizationService.locale}');
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to LocalizationService changes
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      print('🔄 Language changed in ProfileScreen: ${_localizationService.locale}');
      setState(() {
        _translations = S(_localizationService.locale);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always use current translations from LocalizationService
    final isRTL = _localizationService.isRTL();

    print('🎯 Building ProfileScreen for ${widget.userType}');
    print('🌐 Current locale: ${_localizationService.locale}');
    print('🌐 RTL: $isRTL');

    // Wrap with Directionality for RTL support
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: BlocConsumer<ProfileCubit<T>, ProfileState>(
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
                content: Text(_translations.profileUpdated),
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
                content: Text(state.failure.errorMessage ?? _translations.somethingWentWrong),
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
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).iconTheme.color,
              title: Text(
                widget.userType == 'Student'
                    ? _translations.studentProfile
                    : _translations.instructorProfile,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  isRTL ? Icons.arrow_forward : Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  print('🔙 Back button pressed');
                  Navigator.pop(context);
                },
              ),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                    onPressed: _startEditing,
                    tooltip: _translations.editProfile,
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: isRTL
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Profile image section
                  _buildProfileImageSection(Theme.of(context)),
                  const SizedBox(height: 32),

                  // Form fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Selected image info
                          if (_isEditing && _selectedImage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).progressIndicatorTheme.color?.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).progressIndicatorTheme.color?.withOpacity(0.3) ?? Colors.blue,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: isRTL
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isRTL)
                                    Icon(Icons.check_circle,
                                        color: Theme.of(context).progressIndicatorTheme.color, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: isRTL
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _translations.newImageSelected,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).progressIndicatorTheme.color,
                                          ),
                                          textAlign: isRTL
                                              ? TextAlign.right
                                              : TextAlign.left,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedImage!.path.split('/').last,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: isRTL
                                              ? TextAlign.right
                                              : TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isRTL)
                                    Icon(Icons.check_circle,
                                        color: Theme.of(context).progressIndicatorTheme.color, size: 24),
                                  IconButton(
                                    onPressed: _removeSelectedImage,
                                    icon: Icon(Icons.delete_outline,
                                        color: Theme.of(context).iconTheme.color),
                                    tooltip: _translations.remove,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Name field - USING _translations directly
                          _buildModernTextField(
                            theme: Theme.of(context),
                            controller: nameController,
                            label: _translations.fullName,
                            icon: Icons.person_outline,
                            enabled: _isEditing,
                            isRTL: isRTL,
                          ),
                          const SizedBox(height: 20),

                          // Email field - USING _translations directly
                          _buildModernTextField(
                            theme: Theme.of(context),
                            controller: emailController,
                            label: _translations.email,
                            icon: Icons.email_outlined,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            isRTL: isRTL,
                          ),
                          const SizedBox(height: 20),

                          // Language Settings
                          if (!_isEditing) ...[
                            const SizedBox(height: 30),
                            Text(
                              _translations.settings,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              textAlign: isRTL
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Theme.of(context).cardTheme.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: isRTL ? null : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).progressIndicatorTheme.color?.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.language,
                                    color: Theme.of(context).progressIndicatorTheme.color,
                                    size: 22,
                                  ),
                                ),
                                trailing: isRTL ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).progressIndicatorTheme.color?.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.language,
                                    color: Theme.of(context).progressIndicatorTheme.color,
                                    size: 22,
                                  ),
                                ) : null,
                                title: Text(
                                  _translations.language,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  textAlign: isRTL
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                                subtitle: Text(
                                  isRTL ? 'العربية' : 'English',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                                  ),
                                  textAlign: isRTL
                                      ? TextAlign.right
                                      : TextAlign.left,
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
                                ? _buildLoadingState(Theme.of(context))
                                : _buildActionButtons(Theme.of(context), isRTL),
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
      ),
    );
  }

  // ============ MISSING METHODS ============

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
      _showErrorSnackBar('${_translations.somethingWentWrong}: $e');
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
    _showSuccessSnackBar(_translations.imageSelectionRemoved);
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

  // ============ UI WIDGET METHODS ============

  Widget _buildModernTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    bool isRTL = false,
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
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? theme.dividerTheme.color : theme.iconTheme.color?.withOpacity(0.5),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
          prefixIcon: isRTL ? null : Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: enabled
                  ? theme.progressIndicatorTheme.color
                  : theme.iconTheme.color?.withOpacity(0.3),
              size: 20,
            ),
          ),
          suffixIcon: isRTL ? Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: enabled
                  ? theme.progressIndicatorTheme.color
                  : theme.iconTheme.color?.withOpacity(0.3),
              size: 20,
            ),
          ) : null,
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
          alignLabelWithHint: true,
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
          _isEditing ? _translations.profilePreview : _getUserName(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.iconTheme.color,
          ),
          textAlign: _localizationService.isRTL() ? TextAlign.right : TextAlign.left,
        ),
        if (_isEditing) ...[
          const SizedBox(height: 4),
          Text(
            _translations.tapToChangePhoto,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.iconTheme.color?.withOpacity(0.6),
            ),
            textAlign: _localizationService.isRTL() ? TextAlign.right : TextAlign.left,
          ),
        ],
      ],
    );
  }

  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
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
                    _translations.changeProfilePicture,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.iconTheme.color,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: _translations.chooseFromGallery,
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
                      _translations.cancel,
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
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

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
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
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

  void _showLanguageDialog() {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            _translations.language,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                onTap: () => _changeLanguage('en'),
              ),
              ListTile(
                leading: const Text('🇸🇦'),
                title: const Text('العربية'),
                onTap: () => _changeLanguage('ar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _localizationService.changeLanguage(languageCode);
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
  }

  Widget _buildActionButtons(ThemeData theme, bool isRTL) {
    return Row(
      children: isRTL
          ? [
        // RTL layout: Save button first
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                _showErrorSnackBar(_translations.enterName);
                return;
              }

              if (emailController.text.isEmpty) {
                _showErrorSnackBar(_translations.enterEmail);
                return;
              }

              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
                print('❌ Validation failed: Invalid email format');
                _showErrorSnackBar(_translations.validEmail);
                return;
              }

              try {
                final updatedUser = _createUpdatedUser();
                final cubit = context.read<ProfileCubit<T>>();
                cubit.updateProfile(updatedUser);
                print('🚀 updateProfile method called successfully');
              } catch (e, stackTrace) {
                _showErrorSnackBar('${_translations.error}: $e');
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
              _translations.saveChanges,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.iconTheme.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
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
              _translations.cancelEditing,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ),
      ]
          : [
        // LTR layout: Cancel button first
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
              _translations.cancelEditing,
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
              if (nameController.text.isEmpty) {
                _showErrorSnackBar(_translations.enterName);
                return;
              }

              if (emailController.text.isEmpty) {
                _showErrorSnackBar(_translations.enterEmail);
                return;
              }

              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
                print('❌ Validation failed: Invalid email format');
                _showErrorSnackBar(_translations.validEmail);
                return;
              }

              try {
                final updatedUser = _createUpdatedUser();
                final cubit = context.read<ProfileCubit<T>>();
                cubit.updateProfile(updatedUser);
                print('🚀 updateProfile method called successfully');
              } catch (e, stackTrace) {
                _showErrorSnackBar('${_translations.error}: $e');
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
              _translations.saveChanges,
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
          _translations.updatingProfile,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
          textAlign: _localizationService.isRTL() ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  // ============ HELPER METHODS ============

  String _getUserName() {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).name ?? _translations.student;
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).name ?? _translations.instructor;
    }
    return _translations.profile;
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

    final imageUrl = _getUserProfileImage();
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

    return _buildDefaultProfileIcon(theme);
  }

  String _getUserProfileImage() {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).profileImage ?? '';
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).profileImage ?? '';
    }
    return '';
  }

  Widget _buildDefaultProfileIcon(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 48,
      color: theme.iconTheme.color,
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
    authProvider.updateUser(updatedUser);
    print('✅ Updated user in auth provider: ${updatedUser.runtimeType}');
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    _localizationService.removeListener(_onLocaleChanged);
    print('🗑️ Disposing ProfileScreen');
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}