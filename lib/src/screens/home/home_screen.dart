import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../models/banner.dart';
import '../../models/category_args.dart';
import '../../models/product_args.dart';
import '../../routing/app_router.dart';
import '../../state/app_preferences.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/language_select_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late Future<void> _loadFuture;
  bool _didLoad = false;
  bool _languagePrompted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final completer = Completer<void>();
    _loadFuture = completer.future;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await AppStateScope.of(context).loadInitialData();
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowLanguage());
  }

  Future<void> _maybeShowLanguage() async {
    if (_languagePrompted) return;
    _languagePrompted = true;
    final saved = await AppPreferences.getLanguage();
    if (!mounted || saved != null) return;
    await showLanguageSelectDialog(
      context,
      onSelected: (language, dialogContext) async {
        await AppPreferences.setLanguage(language);
        AppStateScope.of(dialogContext).setLocale(Locale(language));
        if (!dialogContext.mounted) return;
        Navigator.of(dialogContext).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    Future<void> openNotifications() async {
      await AppStateScope.of(context).refreshNotifications();
      if (!context.mounted) return;
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'notifications',
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _NotificationsDialog(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
    }
    final sectionTitleStyle =
        textTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ) ??
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        );

    return Scaffold(
      key: const ValueKey('home_screen'),
      backgroundColor: const Color(0xFFF7F4EF),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            final categories = state.categories;
            final topProducts = state.topProducts();
            final banner = state.banners.isNotEmpty ? state.banners.first : null;
            final currency = state.currencySymbol.isNotEmpty
                ? state.currencySymbol
                : l10n.currencySum;

            return RefreshIndicator(
              color: const Color(0xFFCFB07A),
              onRefresh: () => AppStateScope.of(context).loadInitialData(),
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedHeaderDelegate(
                      onNotificationsTap: openNotifications,
                      onCartTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.cart),
                      onBannerTap: () {},
                      banner: banner,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                      child:
                          Text(l10n.categoriesTitle, style: sectionTitleStyle),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final category = categories[index];
                        final title = localeCode == 'uz'
                            ? category.nameUz
                            : category.nameRu;
                        return _CategoryCard(
                          title: title,
                          imageUrl: category.imageUrl,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.category,
                            arguments: CategoryArgs(
                              id: category.id,
                              title: title,
                            ),
                          ),
                        );
                      }, childCount: categories.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 176 / 81.4,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                      child: Text(l10n.bonusSystem, style: sectionTitleStyle),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _BonusCard(
                        bonusText:
                            '${formatMoney(state.bonusBalanceValue)} $currency',
                        enabled: AppStateScope.of(context).isAuthorized,
                        onTap: () {
                          if (AppStateScope.of(context).isAuthorized) {
                            Navigator.of(context).pushNamed(AppRoutes.bonuses);
                            return;
                          }
                          showGeneralDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'auth_required',
                            barrierColor: Colors.black.withValues(alpha: 0.08),
                            transitionDuration:
                                const Duration(milliseconds: 220),
                            pageBuilder:
                                (dialogContext, animation, secondaryAnimation) =>
                                _AuthRequiredDialog(
                              onLogin: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.login);
                              },
                              onRegister: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.register);
                              },
                            ),
                            transitionBuilder:
                                (context, animation, secondaryAnimation, child) {
                              final curved = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );
                              return FadeTransition(
                                opacity: curved,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.96, end: 1)
                                      .animate(curved),
                                  child: child,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                      child: Text(l10n.topProducts, style: sectionTitleStyle),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 190,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final product = state.mapProductToArgs(
                            topProducts[index],
                            languageCode: localeCode,
                          );
                          return _ProductCard(
                            product: product,
                            onOpen: () => Navigator.of(context).pushNamed(
                              AppRoutes.product,
                              arguments: product,
                            ),
                          );
                        },
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 12),
                        itemCount: topProducts.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _HomeBottomBar(),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.onNotificationsTap,
    required this.onCartTap,
    required this.onBannerTap,
    required this.banner,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;
  final VoidCallback onBannerTap;
  final BannerItem? banner;

  static const _extent = 272.0;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF7F4EF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 30, 32, 14),
            child: Row(
              children: [
                const BrandLogo(height: 42, width: 103),
                const Spacer(),
                Builder(
                  builder: (context) {
                    final state = AppStateScope.of(context);
                    return AppIconButton(
                      key: const ValueKey('home_notify'),
                      onPressed: onNotificationsTap,
                      assetPath: 'assets/icons/notify.svg',
                      fallback: Icons.notifications_none,
                      size: 30,
                      badgeActive: state.hasUnreadNotifications,
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final state = AppStateScope.of(context);
                    return AppIconButton(
                      key: const ValueKey('home_cart'),
                      onPressed: onCartTap,
                      assetPath: 'assets/icons/cart.svg',
                      fallback: Icons.shopping_cart_outlined,
                      size: 30,
                      badgeActive: state.cartHasItems,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
            child: _BannerCard(onTap: onBannerTap, banner: banner),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return onNotificationsTap != oldDelegate.onNotificationsTap ||
        onCartTap != oldDelegate.onCartTap ||
        onBannerTap != oldDelegate.onBannerTap ||
        banner != oldDelegate.banner;
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.onTap, required this.banner});

  final VoidCallback onTap;
  final BannerItem? banner;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.primary),
              ),
              if (banner?.imageUrl.trim().isNotEmpty == true)
                Image.network(
                  banner!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _BannerPlaceholder();
                  },
                )
              else
                const _BannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        size: 52,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox.expand(
                    child: _CategoryImage(src: imageUrl),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 10, 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.src});

  final String src;

  @override
  Widget build(BuildContext context) {
    if (src.trim().isEmpty) return _placeholder();
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return Image.network(
      src,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        color: Colors.black.withValues(alpha: 0.55),
        size: 26,
      ),
    );
  }
}

class _BonusCard extends StatelessWidget {
  const _BonusCard({
    required this.bonusText,
    required this.onTap,
    this.enabled = true,
  });

  final String bonusText;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        );

    final amountStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 30,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ) ??
        const TextStyle(
          fontSize: 30,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        );

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 115,
          decoration: BoxDecoration(
            gradient: enabled ? AppGradients.primary : null,
            color: enabled ? null : const Color(0xFFE8E3DA),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final titleLeft = width * 0.22;
              final amountRight = width * 0.12;

              return Stack(
                children: [
                  Positioned(
                    left: -18,
                    bottom: -18,
                    child: Transform.rotate(
                      angle: -0.18,
                      child: _BonusGiftImage(
                        assetPath: 'assets/images/bonus/gift_left.png',
                        fallbackAlignment: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -18,
                    bottom: -18,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: _BonusGiftImage(
                        assetPath: 'assets/images/bonus/gift_right.png',
                        fallbackAlignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: titleLeft,
                    child: ImageFiltered(
                      imageFilter: enabled
                          ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                          : ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Text(
                        AppLocalizations.of(context)!.yourBonus,
                        style: titleStyle.copyWith(
                          color: enabled ? Colors.black : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    right: amountRight + 32,
                    child: ImageFiltered(
                      imageFilter: enabled
                          ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                          : ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Text(
                        bonusText,
                        style: amountStyle.copyWith(
                          color: enabled ? Colors.black : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthRequiredDialog extends StatelessWidget {
  const _AuthRequiredDialog({
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.authRequired,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onLogin,
                  child: Text(
                    AppLocalizations.of(context)!.loginButton,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x33000000)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: onRegister,
                  child: Text(
                    AppLocalizations.of(context)!.registerButton,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BonusGiftImage extends StatelessWidget {
  const _BonusGiftImage({
    required this.assetPath,
    required this.fallbackAlignment,
  });

  final String assetPath;
  final Alignment fallbackAlignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 140,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Align(
            alignment: fallbackAlignment,
            child: Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.black.withValues(alpha: 0.18),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final items = state.notifications;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationsTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (items.isEmpty)
                    Text(
                      l10n.ordersEmpty,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    )
                  else ...[
                    for (final item in items) ...[
                      _NotificationTile(
                        title:
                            locale == 'uz' ? item.titleUz : item.titleRu,
                        subtitle:
                            locale == 'uz' ? item.bodyUz : item.bodyRu,
                        imageUrl: item.imageUrl,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        state.markAllNotificationsRead();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.markAllRead,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationImage(imageUrl: imageUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationImage extends StatelessWidget {
  const _NotificationImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final src = imageUrl?.trim() ?? '';
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: src.isEmpty
          ? _placeholder()
          : src.startsWith('assets/')
              ? Image.asset(
                  src,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                )
              : Image.network(
                  src,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.notifications_none,
        size: 28,
        color: Colors.black.withValues(alpha: 0.4),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onOpen,
  });

  final ProductArgs product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final qty = state.cartQty(product.id);

    return SizedBox(
      width: 160,
      height: 190,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopProductImage(
                src: product.images.isEmpty ? null : product.images.first,
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ) ??
                    const TextStyle(
                      fontSize: 14,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                product.priceText,
                style:
                    textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.9),
                    ) ??
                    TextStyle(
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
              ),
              const Spacer(),
              SizedBox(
                height: 38,
                child: product.mode == ProductPricingMode.quantity
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: qty == 0
                            ? _TopAddButton(
                                key: const ValueKey('add'),
                                label: l10n.addButton,
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
                            : _TopQtyStepper(
                                key: const ValueKey('stepper'),
                                qty: qty,
                                onMinus: () => state.removeProduct(product.id),
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
                    : _TopAddButton(
                        label: l10n.addButton,
                        onPressed: onOpen,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopProductImage extends StatelessWidget {
  const _TopProductImage({required this.src});

  final String? src;

  @override
  Widget build(BuildContext context) {
    final source = src;
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: source == null || source.trim().isEmpty
          ? _placeholder()
          : source.startsWith('assets/')
              ? Image.asset(
                  source,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                )
              : Image.network(
                  source,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.photo_outlined,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}

class _TopAddButton extends StatelessWidget {
  const _TopAddButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopQtyStepper extends StatelessWidget {
  const _TopQtyStepper({
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
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TopStepperButton(label: '-', onTap: onMinus),
          Expanded(
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          _TopStepperButton(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _TopStepperButton extends StatelessWidget {
  const _TopStepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar();

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      selectedTab: AppBottomTab.menu,
      onMenuTap: () => Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      gapWidth: 60,
    );
  }
}
