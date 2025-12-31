import 'package:codexa_mobile/Domain/entities/cart_entity.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/payment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/payment_state.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/screens/payment_webview_screen.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _translations = generated.S(_localizationService.locale);
      });
    }
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  /// Handle payment button press
  void _handlePaymentPressed(BuildContext context, List<CartItemEntity> items) {
    if (items.isEmpty) return;

    // Extract course IDs from cart items
    final courseIds = items
        .where((item) => item.courseId != null)
        .map((item) => item.courseId!)
        .toList();

    if (courseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations.somethingWentWrong),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Initiate payment
    context.read<PaymentCubit>().initiatePayment(courseIds);
  }

  /// Open Stripe checkout WebView
  Future<void> _openPaymentWebView(
    BuildContext context,
    String checkoutUrl,
    String sessionId,
  ) async {
    final result = await Navigator.push<PaymentWebViewResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          checkoutUrl: checkoutUrl,
          sessionId: sessionId,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      if (result.success && result.sessionId != null) {
        // Payment successful - enroll in courses directly
        print(
            '✅ [CART_SCREEN] Payment success, getting course IDs from cart...');

        // Get course IDs from current cart state
        final cartState = context.read<CartCubit>().state;
        List<String> courseIds = [];

        if (cartState is CartLoaded) {
          final items = cartState.cart.items;
          if (items != null) {
            courseIds = items
                .where((item) => item.courseId != null)
                .map((item) => item.courseId!)
                .toList();
          }
        }

        print('📋 [CART_SCREEN] Found ${courseIds.length} courses to enroll');

        // Enroll in courses directly (bypassing webhook)
        if (courseIds.isNotEmpty) {
          await _enrollCourses(context, courseIds);

          // Clear cart after successful enrollment
          context.read<CartCubit>().getCart();

          // Show success and emit state with enrolled course IDs
          context.read<PaymentCubit>().handlePaymentSuccess(result.sessionId!);
        } else {
          // No course IDs found, just proceed with success
          context.read<PaymentCubit>().handlePaymentSuccess(result.sessionId!);
        }
      } else if (result.cancelled) {
        // User cancelled payment
        context.read<PaymentCubit>().cancelPayment();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translations.paymentCancelled),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Enroll student in courses after successful payment
  /// This bypasses the webhook and calls enrollment endpoint directly
  /// Also removes enrolled courses from cart
  Future<List<String>> _enrollCourses(
      BuildContext context, List<String> courseIds) async {
    print('📚 [CART_SCREEN] Enrolling in ${courseIds.length} courses...');

    final apiManager = sl<ApiManager>();
    final coursesRepo = CoursesRepoImpl(apiManager);

    final enrolledCourseIds = <String>[];

    for (final courseId in courseIds) {
      print('  ➡️ Enrolling in course: $courseId');
      try {
        final result = await coursesRepo.enrollInCourse(courseId: courseId);
        result.fold(
          (failure) {
            print('  ❌ Failed to enroll in $courseId: ${failure.errorMessage}');
          },
          (success) {
            print('  ✅ Successfully enrolled in $courseId');
            enrolledCourseIds.add(courseId);

            // Remove course from cart after successful enrollment
            print('  🗑️ Removing course $courseId from cart...');
            context.read<CartCubit>().removeFromCart(courseId);
          },
        );
      } catch (e) {
        print('  💥 Exception enrolling in $courseId: $e');
      }
    }

    print(
        '📚 [CART_SCREEN] Enrollment complete: ${enrolledCourseIds.length}/${courseIds.length} courses');
    return enrolledCourseIds;
  }

  /// Show payment success dialog
  void _showPaymentSuccessDialog(
      BuildContext context, List<String> enrolledCourses) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _translations.paymentSuccessful,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.iconTheme.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _translations.enrolledSuccessfully,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.iconTheme.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (enrolledCourses.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${enrolledCourses.length} ${_translations.courses}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.progressIndicatorTheme.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                print('🎯 [CART_SCREEN] View My Courses button pressed');
                Navigator.of(dialogContext).pop();

                // Enrollment was already done in _openPaymentWebView
                // Just refresh courses to show the newly enrolled courses
                print('🔄 [CART_SCREEN] Refreshing courses...');

                try {
                  await context.read<StudentCoursesCubit>().fetchCourses();
                  print('✅ [CART_SCREEN] Courses refreshed successfully');
                } catch (e) {
                  print('❌ [CART_SCREEN] Error refreshing courses: $e');
                }

                // Refresh cart (should be empty now)
                context.read<CartCubit>().getCart();

                // Close cart screen and return to home
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                  print('✅ [CART_SCREEN] Returned to home');
                }

                print('🏁 [CART_SCREEN] Post-payment flow complete!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.progressIndicatorTheme.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _translations.viewMyCourses,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
          foregroundColor:
              theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
          automaticallyImplyLeading: false,
          title: Container(
            width: double.infinity,
            child: Text(
              _translations.shoppingCart,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.iconTheme.color,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isRTL ? Icons.arrow_forward : Icons.close,
                color: theme.iconTheme.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            // Cart state listener
            BlocListener<CartCubit, CartState>(
              listener: (context, state) {
                if (state is RemoveFromCartSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else if (state is RemoveFromCartError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
            // Payment state listener
            BlocListener<PaymentCubit, PaymentState>(
              listener: (context, state) {
                print(
                    '💳 [CART_SCREEN] Payment state changed: ${state.runtimeType}');
                if (state is CheckoutSessionCreated) {
                  print(
                      '🔗 [CART_SCREEN] Opening WebView with URL: ${state.session.checkoutUrl}');
                  // Open WebView with Stripe checkout
                  _openPaymentWebView(
                    context,
                    state.session.checkoutUrl,
                    state.session.sessionId,
                  );
                } else if (state is PaymentSuccess) {
                  print(
                      '🎉 [CART_SCREEN] PaymentSuccess received! Showing success dialog...');
                  // Reset payment state and show success
                  context.read<PaymentCubit>().reset();
                  _showPaymentSuccessDialog(context, state.enrolledCourseIds);
                } else if (state is PaymentFailed) {
                  context.read<PaymentCubit>().reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${_translations.paymentFailed}: ${state.message}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else if (state is PaymentError) {
                  context.read<PaymentCubit>().reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${_translations.paymentError}: ${state.message}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoading && state is! CartLoaded) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.progressIndicatorTheme.color ?? theme.primaryColor,
                    ),
                  ),
                );
              }

              if (state is CartError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<CartCubit>().getCart(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _translations.retry,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is CartLoaded) {
                final cart = state.cart;
                final items = cart.items ?? [];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _translations.cartEmpty,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.disabledColor,
                          ),
                          textAlign: isRTL ? TextAlign.right : TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _translations.addCoursesToStart,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                          textAlign: isRTL ? TextAlign.right : TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final totalPrice = cart.totalPrice ?? 0.0;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _CartItemCard(
                            item: items[index],
                            onDelete: () {
                              if (items[index].courseId != null) {
                                context
                                    .read<CartCubit>()
                                    .removeFromCart(items[index].courseId!);
                              }
                            },
                            isRTL: isRTL,
                            translations: _translations,
                          );
                        },
                      ),
                    ),
                    _CartBottomBar(
                      totalPrice: totalPrice,
                      isRTL: isRTL,
                      translations: _translations,
                      cartItems: items,
                      onPaymentPressed: () =>
                          _handlePaymentPressed(context, items),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onDelete;
  final bool isRTL;
  final generated.S translations;

  const _CartItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
    required this.isRTL,
    required this.translations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isRTL
              ? [
                  // RTL: Delete button first
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: translations.removeFromCart,
                  ),
                  const SizedBox(width: 16),
                  // Course details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.title ?? translations.untitledCourse,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.iconTheme.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        if (item.category != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.iconTheme.color,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '\$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.progressIndicatorTheme.color,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Course image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.coverImage?['url'] != null
                        ? Image.network(
                            item.coverImage!['url'] as String,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder(theme);
                            },
                          )
                        : _buildImagePlaceholder(theme),
                  ),
                ]
              : [
                  // LTR: Image first
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.coverImage?['url'] != null
                        ? Image.network(
                            item.coverImage!['url'] as String,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder(theme);
                            },
                          )
                        : _buildImagePlaceholder(theme),
                  ),
                  const SizedBox(width: 16),
                  // Course details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? translations.untitledCourse,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.iconTheme.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.category != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '\$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.progressIndicatorTheme.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: translations.removeFromCart,
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.play_circle_outline,
        size: 40,
        color: theme.progressIndicatorTheme.color,
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final double totalPrice;
  final bool isRTL;
  final generated.S translations;
  final List<CartItemEntity> cartItems;
  final VoidCallback onPaymentPressed;

  const _CartBottomBar({
    Key? key,
    required this.totalPrice,
    required this.isRTL,
    required this.translations,
    required this.cartItems,
    required this.onPaymentPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${translations.total}:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.iconTheme.color,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.iconTheme.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Payment button with loading state
            BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, paymentState) {
                final isLoading = paymentState is PaymentLoading ||
                    paymentState is PaymentVerifying;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onPaymentPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.progressIndicatorTheme.color,
                      disabledBackgroundColor:
                          theme.progressIndicatorTheme.color?.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                paymentState is PaymentVerifying
                                    ? translations.verifyingPayment
                                    : translations.loading,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            translations.proceedToPayment,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
