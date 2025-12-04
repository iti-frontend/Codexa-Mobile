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

class CustomAppbar extends StatelessWidget {
  final String profileImage;
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCreatePostTap;
  final bool showCart;

  const CustomAppbar({
    required this.profileImage,
    required this.userName,
    this.onProfileTap,
    this.onCreatePostTap,
    this.showCart = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  },
                  theme: theme,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second Row: Search Box (Full Width)
            _buildSearchBox(context, theme, isDark),
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
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
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

  Widget _buildSearchBox(BuildContext context, ThemeData theme, bool isDark) {
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
                "Search for courses...",
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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

  void _toggleTheme(ThemeProvider themeProvider) async {
    // Start animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Toggle theme
    await themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _toggleTheme(themeProvider),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColorsDark.cardBackground.withOpacity(0.5)
              : AppColorsLight.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.amber.withOpacity(0.2)
                  : AppColorsLight.accentBlue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
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
                    themeProvider.isDarkMode
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    key: ValueKey<bool>(themeProvider.isDarkMode),
                    color: themeProvider.isDarkMode
                        ? Colors.amber
                        : AppColorsLight.accentBlue,
                    size: 22,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
