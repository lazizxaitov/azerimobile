import 'dart:async';

import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../models/category_args.dart';
import '../../models/product_args.dart';
import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.args});

  final CategoryArgs args;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<void> _loadFuture;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final state = AppStateScope.of(context);
    final completer = Completer<void>();
    _loadFuture = completer.future;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await state.loadInitialData();
        if (widget.args.id != 0) {
          await state.loadCategoryProducts(widget.args.id);
        }
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final resolvedTitle =
        widget.args.title.trim().isEmpty
            ? l10n.categoriesTitle
            : widget.args.title;
    final localeCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            final list = widget.args.id == 0
                ? state.products
                : state.categoryProducts(widget.args.id);
            final items = list
                .map(
                  (p) => state.mapProductToArgs(
                    p,
                    languageCode: localeCode,
                  ),
                )
                .toList(growable: false);

            return Column(
              children: [
                AppTopBar(title: resolvedTitle),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F7F3),
                    child: RefreshIndicator(
                      color: const Color(0xFFCFB07A),
                      onRefresh: () async {
                        if (widget.args.id == 0) {
                          await state.loadInitialData();
                        } else {
                          await state.refreshCategoryProducts(widget.args.id);
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final productArgs = items[index];
                          return _CategoryProductCard(
                            product: productArgs,
                            onOpen: () => Navigator.of(
                              context,
                            ).pushNamed(
                              AppRoutes.product,
                              arguments: productArgs,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppBottomTab.menu,
        onMenuTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  const _CategoryProductCard({required this.product, required this.onOpen});

  final ProductArgs product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppStateScope.of(context);
    final qty = state.cartQty(product.id);

    return Container(
      height: 146,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 176,
                  height: double.infinity,
                  child: _ProductImage(
                    src: product.images.isEmpty ? null : product.images.first,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onOpen,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ) ??
                                const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.descriptionText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                textTheme.bodyMedium?.copyWith(
                                  fontSize: 9,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withValues(alpha: 0.9),
                                ) ??
                                TextStyle(
                                  fontSize: 9,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withValues(alpha: 0.9),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.priceText,
                            style:
                                textTheme.titleSmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ) ??
                                const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 30,
                    width: 170,
                    child: product.mode == ProductPricingMode.quantity
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: qty == 0
                                ? _AddButton(
                                    key: const ValueKey('add'),
                                    onPressed: () => state.addProduct(
                                      product.id,
                                      1,
                                      CartItemMeta(
                                        id: product.id,
                                        title: product.title,
                                        titleRu: product.titleRu,
                                        titleUz: product.titleUz,
                                        unitPrice: product.price,
                                        image: product.images.isEmpty
                                            ? null
                                            : product.images.first,
                                      ),
                                    ),
                                  )
                                : _QtyStepper(
                                    key: const ValueKey('stepper'),
                                    qty: qty,
                                    onMinus: () =>
                                        state.removeProduct(product.id),
                                    onPlus: () => state.addProduct(
                                      product.id,
                                      1,
                                      CartItemMeta(
                                        id: product.id,
                                        title: product.title,
                                        titleRu: product.titleRu,
                                        titleUz: product.titleUz,
                                        unitPrice: product.price,
                                        image: product.images.isEmpty
                                            ? null
                                            : product.images.first,
                                      ),
                                    ),
                                  ),
                          )
                        : _AddButton(onPressed: onOpen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const width = 170.0;
  static const height = 30.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.addButton,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _AddButton.width,
      height: _AddButton.height,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            _StepperButton(label: '-', onTap: onMinus),
            Expanded(
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ),
            _StepperButton(label: '+', onTap: onPlus),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: _AddButton.height,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.src});

  final String? src;

  @override
  Widget build(BuildContext context) {
    final source = src;
    if (source == null || source.trim().isEmpty) {
      return _placeholder();
    }
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.6),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        size: 40,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}
