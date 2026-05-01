import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../models/product_args.dart';
import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, this.args});

  final Object? args;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  late ProductArgs _product;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final l10n = AppLocalizations.of(context)!;
    _product = switch (widget.args) {
      final ProductArgs a => a,
      _ => ProductArgs(
          id: 'bruschetta_tuna_portion',
          title: l10n.sampleProductName,
          price: 68000,
          priceText: '68 000 ${l10n.currencySum}',
          descriptionTitle: l10n.sampleDescriptionTitle,
          descriptionText: l10n.sampleDescriptionText,
          mode: ProductPricingMode.portion,
          images: const [
            'assets/images/categories/breakfast.png',
            'assets/images/categories/pancakes.png',
          ],
          portionOptions: [
            PortionOption(id: 'half', label: l10n.portionHalf, price: 35000),
            PortionOption(id: 'full', label: l10n.portionFull, price: 68000),
          ],
          titleRu: l10n.sampleProductName,
          titleUz: l10n.sampleProductName,
        ),
    };
    _initialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F7F3);
    final textTheme = Theme.of(context).textTheme;
    final state = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currency = state.currencySymbol.isNotEmpty
        ? state.currencySymbol
        : l10n.currencySum;
    final priceText = _product.priceText.trim().isNotEmpty
        ? _product.priceText
        : '${formatMoney(_product.price)} $currency';

    final qty = state.cartQty(_product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                AppTopBar(title: _product.title),
                Expanded(
                  child: Container(
                    color: bg,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProductImageCarousel(
                            images: _product.images,
                            controller: _pageController,
                            page: _page,
                            onPageChanged: (value) =>
                                setState(() => _page = value),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _product.title,
                                  style:
                                      textTheme.headlineSmall?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ) ??
                                      const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                              Text(
                                priceText,
                                style:
                                    textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _product.descriptionTitle,
                            style:
                                textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ) ??
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _product.descriptionText,
                            style:
                                textTheme.bodyLarge?.copyWith(
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ) ??
                                const TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 78 + 18,
              child: _product.mode == ProductPricingMode.quantity
                  ? _QtyControl(
                      qty: qty,
                      onMinus: () => state.removeProduct(_product.id),
                      onPlus: () => state.addProduct(
                        _product.id,
                        1,
                        _metaForQtyProduct(),
                      ),
                      onAdd: () => state.addProduct(
                        _product.id,
                        1,
                        _metaForQtyProduct(),
                      ),
                    )
                  : _AddToCartButton(
                    label: l10n.addToCart,
                      onPressed: _openPortionSheetAndAdd,
                    ),
            ),
          ],
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

  CartItemMeta _metaForQtyProduct() => CartItemMeta(
    id: _product.id,
    title: _product.title,
    titleRu: _product.titleRu,
    titleUz: _product.titleUz,
    unitPrice: _product.price,
    image: _product.images.isEmpty ? null : _product.images.first,
  );

  Future<void> _openPortionSheetAndAdd() async {
    final l10n = AppLocalizations.of(context)!;
    final options = _product.portionOptions.isEmpty
        ? [
            PortionOption(id: 'p1', label: l10n.portionHalf, price: 35000),
            PortionOption(id: 'p2', label: l10n.portionFull, price: 68000),
          ]
        : _product.portionOptions;

    final selected = await showModalBottomSheet<PortionOption>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return _PortionSheet(options: options);
      },
    );

    if (!mounted || selected == null) return;

    final state = AppStateScope.of(context);
    final cartItemId = '${_product.id}:${selected.id}';
    state.addProduct(
      cartItemId,
      1,
      CartItemMeta(
        id: cartItemId,
        title: _product.title,
        titleRu: _product.titleRu,
        titleUz: _product.titleUz,
        subtitle: selected.label,
        unitPrice: selected.price,
        image: _product.images.isEmpty ? null : _product.images.first,
      ),
    );
  }
}

class _ProductImageCarousel extends StatelessWidget {
  const _ProductImageCarousel({
    required this.images,
    required this.controller,
    required this.page,
    required this.onPageChanged,
  });

  final List<String> images;
  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedImages = images.isEmpty ? const <String>[''] : images;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: resolvedImages.length,
              itemBuilder: (context, index) {
                return _ProductImage(src: resolvedImages[index]);
              },
            ),
          ),
        ),
        if (resolvedImages.length > 1) ...[
          const SizedBox(height: 10),
          _DotsIndicator(count: resolvedImages.length, index: page),
        ],
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.src});

  final String src;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withValues(alpha: 0.6);

    if (src.trim().isEmpty) {
      return _ImagePlaceholder(bg: bg);
    }

    final isAsset = src.startsWith('assets/');
    final isSvg = src.toLowerCase().trim().endsWith('.svg');

    if (isSvg) {
      final w = isAsset
          ? SvgPicture.asset(
              src,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => _ImagePlaceholder(bg: bg),
            )
          : SvgPicture.network(
              src,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => _ImagePlaceholder(bg: bg),
            );
      return ColoredBox(color: bg, child: w);
    }

    final Widget image = isAsset
        ? Image.asset(
            src,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _ImagePlaceholder(bg: bg),
          )
        : Image.network(
            src,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _ImagePlaceholder(bg: bg),
          );

    return ColoredBox(color: bg, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.bg});

  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        size: 60,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Padding(
          padding: EdgeInsets.only(right: i == count - 1 ? 0 : 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == index
                  ? Colors.black
                  : Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.qty,
    required this.onAdd,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: qty == 0
            ? Material(
                key: const ValueKey('add'),
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onAdd,
                  child: Center(
                    child: Text(
                      l10n.addToCart,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                key: const ValueKey('stepper'),
                children: [
                  _QtyTap(label: '–', onTap: onMinus),
                  Expanded(
                    child: Text(
                      '$qty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _QtyTap(label: '+', onTap: onPlus),
                ],
              ),
      ),
    );
  }
}

class _QtyTap extends StatelessWidget {
  const _QtyTap({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        height: double.infinity,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _PortionSheet extends StatelessWidget {
  const _PortionSheet({required this.options});

  final List<PortionOption> options;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.portionTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              for (final o in options) ...[
                _PortionOptionButton(
                  label: o.label,
                  price: o.price,
                  onTap: () => Navigator.of(context).pop(o),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PortionOptionButton extends StatelessWidget {
  const _PortionOptionButton({
    required this.label,
    required this.price,
    required this.onTap,
  });

  final String label;
  final int price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '${formatMoney(price)} ${AppLocalizations.of(context)!.currencySum}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
