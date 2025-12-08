import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Cart action button for course details - handles add/remove from cart
class CartActionButton extends StatelessWidget {
  final CourseEntity course;
  final generated.S translations;

  const CartActionButton({
    Key? key,
    required this.course,
    required this.translations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is AddToCartSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AddToCartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is RemoveFromCartSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is RemoveFromCartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<CartCubit>();
            final isInCart = cubit.currentCart?.items
                    ?.any((item) => item.courseId == course.id) ??
                false;

            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ElevatedButton(
              onPressed: () {
                if (course.id != null) {
                  if (isInCart) {
                    cubit.removeFromCart(course.id!);
                  } else {
                    cubit.addToCart(course.id!);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCart
                    ? Colors.red
                    : (theme.brightness == Brightness.dark
                        ? AppColorsDark.accentGreen
                        : AppColorsLight.accentBlue),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInCart
                        ? Icons.remove_shopping_cart
                        : Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInCart
                        ? translations.removeFromCart
                        : translations.addToCart,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
