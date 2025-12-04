import 'dart:io';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_states.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/posts_state.dart';
import 'package:codexa_mobile/Ui/utils/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'profile_cubit/profile_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Image picker fields
  bool _isPickingImage = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    print('🎯 ProfileScreen initialized for ${widget.userType}');
    print('👤 User: ${widget.user}');

    // Load user's community posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityPostsCubit>().fetchPosts();
    });
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
      return (widget.user as StudentEntity).name ?? 'Unknown Student';
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).name ?? 'Unknown Instructor';
    }
    return 'Unknown User';
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
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  /// Upload profile image to server and return the public URL or path.
  /// Returns null on failure.
  Future<String?> _uploadProfileImage(File file) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final apiManager = ApiManager(prefs: prefs);

      // Try uploading with PUT (many APIs accept PUT for updating profile image)
      final response = await apiManager.putMultipartData(
        '/uploads/profile',
        file: file,
        fileFieldName: 'image',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        String? url;

        // Try multiple common shapes returned by file upload endpoints
        try {
          if (data is Map) {
            // 1) { data: { url: '...' } } or { data: { path: '...' } }
            final d = data['data'];
            if (d is Map) {
              url = d['url'] ??
                  d['path'] ??
                  d['filePath'] ??
                  d['profileImage'] ??
                  d['location'];
            }

            // 2) top-level url/path
            url ??= data['url'] ??
                data['path'] ??
                data['filePath'] ??
                data['profileImage'] ??
                data['location'];

            // 3) files array: { files: [{ url: '...' }] } or { files: [{ path: '...' }] }
            if (url == null &&
                data['files'] is List &&
                data['files'].isNotEmpty) {
              final f0 = data['files'][0];
              if (f0 is Map) {
                url =
                    f0['url'] ?? f0['path'] ?? f0['filePath'] ?? f0['location'];
              } else if (f0 is String) {
                url = f0;
              }
            }
          } else if (data is List && data.isNotEmpty) {
            // 4) response is a list: [{ path: '...'}]
            final first = data[0];
            if (first is Map) {
              url = first['url'] ??
                  first['path'] ??
                  first['filePath'] ??
                  first['location'];
            } else if (first is String) {
              url = first;
            }
          } else if (data is String) {
            // 5) response is just a string path/url
            url = data;
          }
        } catch (e) {
          // parsing failed — fall through to null
          print('⚠️ _uploadProfileImage: parsing response failed: $e');
        }

        // Final normalization: if we have a leading-slash path, prefix baseUrl
        if (url != null) {
          if (url.startsWith('/')) {
            final base = ApiManager.baseUrl;
            final normalizedBase =
                base.endsWith('/') ? base.substring(0, base.length - 1) : base;
            url = normalizedBase + url;
          }
          return url;
        }

        // If we couldn't parse a url, but response contains a readable body, show it briefly
        _showErrorSnackBar('Image uploaded but response shape unexpected');
        return null;
      } else {
        _showErrorSnackBar('Image upload failed (${response.statusCode})');
        return null;
      }
    } catch (e) {
      _showErrorSnackBar('Image upload failed: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
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
                  'Change Profile Picture',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              if (_isPickingImage)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                )
              else ...[
                // _buildImageSourceOption(
                //   icon: Icons.camera_alt,
                //   title: 'Take Photo',
                //   onTap: _takePhotoWithCamera,
                // ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  onTap: _pickImageFromGallery,
                ),
              ],
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
                    'Cancel',
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
    _showSuccessSnackBar('Image selection removed');
  }

  T _createUpdatedUser({String? uploadedImageUrl}) {
    print('🔄 Creating updated user...');

    if (widget.user is StudentEntity) {
      final original = widget.user as StudentEntity;
      final updatedStudent = StudentEntity(
        id: original.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImage: uploadedImageUrl ??
            (_selectedImage != null
                ? _selectedImage!.path
                : original.profileImage),
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
        profileImage: uploadedImageUrl ??
            (_selectedImage != null
                ? _selectedImage!.path
                : original.profileImage),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            const SnackBar(
              content: Text('Profile updated successfully'),
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
              content: Text(state.failure.errorMessage),
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
            backgroundColor:
                theme.appBarTheme.backgroundColor ?? theme.cardColor,
            foregroundColor: theme.iconTheme.color,
            title: Text(
              "${widget.userType} Profile",
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
                  tooltip: 'Edit Profile',
                ),
            ],
          ),
          body: _isEditing
              ? Padding(
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
                                    color: theme.progressIndicatorTheme.color
                                        ?.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.progressIndicatorTheme.color
                                              ?.withOpacity(0.3) ??
                                          Colors.blue,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: theme
                                              .progressIndicatorTheme.color,
                                          size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'New image selected',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: theme
                                                    .progressIndicatorTheme
                                                    .color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedImage!.path
                                                  .split('/')
                                                  .last,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.iconTheme.color
                                                    ?.withOpacity(0.7),
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
                                        tooltip: 'Remove selected image',
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
                                label: "Full Name",
                                icon: Icons.person_outline,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 20),

                              // Email field
                              _buildModernTextField(
                                theme: theme,
                                controller: emailController,
                                label: "Email Address",
                                icon: Icons.email_outlined,
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),

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
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProfileImageSection(theme),
                            const SizedBox(height: 32),
                            _buildModernTextField(
                              theme: theme,
                              controller: nameController,
                              label: "Full Name",
                              icon: Icons.person_outline,
                              enabled: false,
                            ),
                            const SizedBox(height: 20),
                            _buildModernTextField(
                              theme: theme,
                              controller: emailController,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              enabled: false,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Community Activity Section
                      _buildCommunityActivitySection(theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// Build Community Activity Section
  Widget _buildCommunityActivitySection(ThemeData theme) {
    final currentUserId = _getCurrentUserId();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community Activity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Posts & engagement in the community',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
          builder: (context, state) {
            if (state is CommunityPostsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CommunityPostsLoaded) {
              // Filter posts to show only current user's posts
              final userPosts = state.posts
                  .where((post) => post.author?.id == currentUserId)
                  .toList();

              if (userPosts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.post_add,
                            size: 48,
                            color: theme.iconTheme.color?.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No community posts yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userPosts.length,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return PostCard(post: post);
                },
              );
            } else if (state is CommunityPostsError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Center(
                    child: Text(
                      'Error loading posts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  String _getCurrentUserId() {
    if (widget.user is StudentEntity) {
      return (widget.user as StudentEntity).id ?? '';
    } else if (widget.user is InstructorEntity) {
      return (widget.user as InstructorEntity).id ?? '';
    }
    return '';
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
        color: enabled
            ? theme.cardTheme.color
            : theme.cardTheme.color?.withOpacity(0.5),
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
          color: enabled
              ? theme.dividerTheme.color
              : theme.iconTheme.color?.withOpacity(0.5),
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
                  color: theme.progressIndicatorTheme.color?.withOpacity(0.2) ??
                      Colors.blue.withOpacity(0.2),
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
          _isEditing ? 'Profile Preview' : _userName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.iconTheme.color,
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 4),
          Text(
            'Tap the camera icon to change photo',
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
      } else if (imageUrl.startsWith('assets/')) {
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
      } else if (imageUrl.startsWith('/')) {
        // Decide if this is a local filepath or a server-relative path.
        // Treat as local file ONLY for common mobile local prefixes to avoid attempting
        // filesystem operations on server-relative paths like '/uploads/...'.
        final lower = imageUrl.toLowerCase();
        final looksLikeLocal = lower.startsWith('/storage') ||
            lower.startsWith('/data') ||
            lower.startsWith('file:');

        if (looksLikeLocal) {
          try {
            final localFile = File(imageUrl);
            if (localFile.existsSync()) {
              return ClipOval(
                child: Image.file(
                  localFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Error loading file image: $error');
                    return _buildDefaultProfileIcon(theme);
                  },
                ),
              );
            }
          } catch (e) {
            // ignore and treat as server-relative below
            print('⚠️ Failed checking local file: $e');
          }
        }

        // Treat as server-relative path
        final base = ApiManager.baseUrl;
        final normalizedBase =
            base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        final fullUrl = '${normalizedBase}${imageUrl}';
        return ClipOval(
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading network image: $error');
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
              "Cancel",
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
            onPressed: _isUploadingImage
                ? null
                : () async {
                    // Validation
                    if (nameController.text.isEmpty) {
                      _showErrorSnackBar('Please enter your name');
                      return;
                    }

                    if (emailController.text.isEmpty) {
                      _showErrorSnackBar('Please enter your email');
                      return;
                    }

                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(emailController.text)) {
                      print('❌ Validation failed: Invalid email format');
                      _showErrorSnackBar('Please enter a valid email address');
                      return;
                    }

                    try {
                      String? uploadedUrl;
                      if (_selectedImage != null) {
                        // Upload selected image first
                        uploadedUrl =
                            await _uploadProfileImage(_selectedImage!);
                        if (uploadedUrl == null) {
                          // upload failed and snackbar already shown
                          return;
                        }
                      }

                      final updatedUser =
                          _createUpdatedUser(uploadedImageUrl: uploadedUrl);
                      final cubit = context.read<ProfileCubit<T>>();
                      cubit.updateProfile(updatedUser);
                      print('🚀 updateProfile method called successfully');
                    } catch (e) {
                      _showErrorSnackBar('Error: $e');
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
              "Save Changes",
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
          'Updating profile...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    print('🗑️ Disposing ProfileScreen');
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
