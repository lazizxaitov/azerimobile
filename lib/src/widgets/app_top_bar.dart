import 'package:flutter/material.dart';

import '../routing/app_router.dart';
import '../state/app_state.dart';
import 'app_icon.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.showCartButton = true,
    this.onCartTap,
    this.titleStyle,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showCartButton;
  final VoidCallback? onCartTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final resolvedTitleStyle = titleStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.black,
            ) ??
        const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: Colors.black,
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, 18 + topInset, 24, 12),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new),
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            )
          else
            const SizedBox(width: 44),
          const SizedBox(width: 6),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: resolvedTitleStyle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (showCartButton)
            Builder(
              builder: (context) {
                final state = AppStateScope.of(context);
                return AppIconButton(
                  onPressed: onCartTap ??
                      () => Navigator.of(context).pushNamed(AppRoutes.cart),
                  assetPath: 'assets/icons/cart.svg',
                  fallback: Icons.shopping_cart_outlined,
                  size: 30,
                  badgeActive: state.cartHasItems,
                );
              },
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
