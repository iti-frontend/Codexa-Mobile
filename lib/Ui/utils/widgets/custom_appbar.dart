import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/search_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'dart:io';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart'
    as animated;
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';

class CustomAppbar extends StatelessWidget {
  final String profileImage;
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCreatePostTap;
  final bool showCart;
  final dynamic translations;

  const CustomAppbar({
    required this.profileImage,
    required this.userName,
    this.onProfileTap,
    this.onCreatePostTap,
    this.showCart = true,
    required this.translations, // Make it required
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Helper function to get translation
    String getTranslation(String key, {String defaultValue = ''}) {
      if (translations == null) return defaultValue;

      try {
        // If translations is a Map
        if (translations is Map<String, String>) {
          return (translations as Map<String, String>)[key] ?? defaultValue;
        }
        // If translations is dynamic and has getters
        else if (translations is dynamic) {
          // Try common translation keys
          switch (key) {
            case 'searchHint':
              return _tryGetProperty(translations, 'search') ?? defaultValue;
            case 'logout':
              return _tryGetProperty(translations, 'logout') ?? defaultValue;
            default:
              return _tryGetProperty(translations, key) ?? defaultValue;
          }
        }
      } catch (e) {
        print('Error getting translation for $key: $e');
      }
      return defaultValue;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First Row: Profile, Icons
            Row(
              children: [
                // Profile Avatar with Border
                _buildProfileAvatar(context, theme),

                const SizedBox(width: 10),

                // User Name
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Cart Icon with Badge
                if (showCart)
                  _buildCartIconWithBadgeWidget(
                    context: context,
                    theme: theme,
                  ),

                const SizedBox(width: 8),

                // Theme Toggle
                _AnimatedThemeToggle(),

                const SizedBox(width: 8),

                // Create Post Icon
                if (onCreatePostTap != null)
                  _buildIconButton(
                    context: context,
                    icon: Icons.add_circle_outline,
                    onTap: onCreatePostTap!,
                    theme: theme,
                    tooltip: getTranslation('createPost',
                        defaultValue: 'Create Post'),
                  ),

                const SizedBox(width: 8),

                // Logout Icon
                _buildIconButton(
                  context: context,
                  icon: Icons.logout_rounded,
                  onTap: () {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    userProvider.logout();

                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            LoginScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = 0.0;
                          var end = 1.0;
                          var curve = Curves.ease;

                          // Implicitly using the tween logic without variable assignment to clean up
                          var _ = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  theme: theme,
                  tooltip: getTranslation('logout', defaultValue: 'Logout'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second Row: Search Box (Full Width)
            _buildSearchBox(context, theme, isDark, translations),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIconWithBadgeWidget({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        int cartCount = 0;
        if (state is CartLoaded) {
          cartCount = state.cart.items?.length ?? 0;
        } else {
          // Fallback to currentCart from cubit for optimistic updates or other states
          try {
            final cubit = context.read<CartCubit>();
            cartCount = cubit.currentCart?.items?.length ?? 0;
          } catch (_) {}
        }

        return _buildCartIconWithBadge(
          context: context,
          theme: theme,
          count: cartCount,
        );
      },
    );
  }

  Widget _buildCartIconWithBadge({
    required BuildContext context,
    required ThemeData theme,
    required int count,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.cardBackground.withOpacity(0.5)
                  : AppColorsLight.cardBackground,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.cart_fill,
              size: 20,
              color: theme.iconTheme.color,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                decoration: BoxDecoration(
                  color: theme.progressIndicatorTheme.color ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    String tooltip = '',
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorsDark.cardBackground.withOpacity(0.5)
                : AppColorsLight.cardBackground,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: theme.iconTheme.color,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isDark
                ? [AppColorsDark.accentGreen, AppColorsDark.accentBlue]
                : [AppColorsLight.accentBlue, AppColorsLight.accentGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColorsDark.accentGreen.withOpacity(0.3)
                  : AppColorsLight.accentBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.all(1.5),
          child: CircleAvatar(
            backgroundImage: _getProfileImage(profileImage),
            radius: 16,
            backgroundColor: isDark
                ? AppColorsDark.cardBackground
                : AppColorsLight.cardBackground,
            child: profileImage.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    color: theme.iconTheme.color,
                    size: 18,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, ThemeData theme, bool isDark,
      dynamic translations) {
    // Get search hint translation
    String searchHint = 'Search for courses...';
    if (translations != null) {
      try {
        if (translations is Map<String, String>) {
          searchHint = translations['searchHint'] ??
              translations['search'] ??
              searchHint;
        } else if (translations is dynamic) {
          final searchTranslation =
              _tryGetProperty(translations, 'searchHint') ??
                  _tryGetProperty(translations, 'search');
          if (searchTranslation != null) {
            searchHint = searchTranslation;
          }
        }
      } catch (e) {
        print('Error getting search translation: $e');
      }
    }

    return GestureDetector(
      onTap: () {
        final cubit = context.read<StudentCoursesCubit>();
        showSearch(
          context: context,
          delegate: SearchCoursesScreen(cubit),
        );
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? AppColorsDark.cardBackground.withOpacity(0.6)
              : AppColorsLight.cardBackground,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.accentBlue.withOpacity(0.2)
                    : AppColorsLight.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColorsDark.accentBlue
                    : AppColorsLight.accentBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                searchHint,
                style: TextStyle(
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.accentGreen.withOpacity(0.15)
                    : AppColorsLight.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⌘K',
                style: TextStyle(
                  color: isDark
                      ? AppColorsDark.accentGreen
                      : AppColorsLight.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else if (imageUrl.startsWith('/')) {
      final lower = imageUrl.toLowerCase();
      final looksLikeLocal = lower.startsWith('/storage') ||
          lower.startsWith('/data') ||
          lower.startsWith('file:');
      if (looksLikeLocal) {
        try {
          final file = File(imageUrl);
          if (file.existsSync()) return FileImage(file);
        } catch (e) {
          // ignore and fall back to treating as server-relative
        }
      }

      // Treat as server-relative
      final base = ApiManager.baseUrl;
      final normalizedBase =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return NetworkImage('$normalizedBase$imageUrl');
    } else {
      return AssetImage('assets/$imageUrl');
    }
  }

  // Helper to dynamically access properties
  dynamic _tryGetProperty(dynamic obj, String propertyName) {
    if (obj == null) return null;

    try {
      // If the object is a Map
      if (obj is Map) {
        return obj[propertyName];
      }
      // Try to access as a property using dynamic access
      else {
        switch (propertyName) {
          case 'search':
          case 'searchHint':
            return obj.searchHint ?? obj.search;
          case 'logout':
            return obj.logout;
          case 'createPost':
            return obj.createPost ?? obj.create;
          case 'home':
            return obj.home;
          case 'courses':
            return obj.courses;
          case 'community':
            return obj.community;
          case 'favorites':
            return obj.favorites;
          default:
            // Try to access using noSuchMethod fallback
            try {
              return obj[propertyName];
            } catch (_) {
              return null;
            }
        }
      }
    } catch (e) {
      return null;
    }
  }
}

// Animated Theme Toggle Widget
class _AnimatedThemeToggle extends StatefulWidget {
  const _AnimatedThemeToggle({Key? key}) : super(key: key);

  @override
  State<_AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<_AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme(BuildContext context, ThemeProvider themeProvider) {
    // Determine the next theme based on current brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextTheme = isDark ? AppThemeData.lightTheme : AppThemeData.darkTheme;

    // Calculate Center of the screen
    final size = MediaQuery.of(context).size;
    final centerOffset = Offset(size.width / 2, size.height / 2);

    // Start icon animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Trigger the circular reveal animation from the package
    animated.ThemeSwitcher.of(context).changeTheme(
      theme: nextTheme,
      isReversed: isDark,
      offset: centerOffset, // Start from center of screen
    );

    // Update local provider for persistence and other app state
    themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    // Listen false to prevent rebuilds from Provider. Rebuilds should come from Theme.of(context)
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use ThemeSwitcher.of(context) which is now at the root of the app
    return GestureDetector(
      onTap: () => _toggleTheme(context, themeProvider),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.cardBackground.withAlpha(128)
                  : AppColorsLight.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.amber
                          .withAlpha(((_glowAnimation.value) * 255).toInt())
                      : AppColorsLight.accentBlue
                          .withAlpha(((_glowAnimation.value) * 255).toInt()),
                  blurRadius: 12 + (_glowAnimation.value * 8),
                  spreadRadius: _glowAnimation.value * 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _rotationAnimation.value * 3.14159 * 2,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    key: ValueKey<bool>(isDark),
                    color: isDark ? Colors.amber : AppColorsLight.accentBlue,
                    size: 22,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
