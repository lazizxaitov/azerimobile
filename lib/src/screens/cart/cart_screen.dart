import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);

    final state = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final entries = [
      for (final e in state.cartQuantities.entries)
        _CartEntry(id: e.key, qty: e.value, meta: state.cartMeta[e.key]),
    ]..sort((a, b) => a.id.compareTo(b.id));

    final totalItems = entries.fold<int>(0, (sum, e) => sum + e.qty);
    final subtotal = entries.fold<int>(
      0,
      (sum, e) => sum + e.qty * e.unitPrice,
    );
    final delivery = totalItems == 0
        ? 0
        : (state.settings?.deliveryFee ?? 50000);
    const discountPercent = 0;
    final currency = state.currencySymbol.isNotEmpty
        ? state.currencySymbol
        : l10n.currencySum;

    Future<void> showAuthRequiredDialog() {
      return showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'auth_required',
        barrierColor: Colors.black.withValues(alpha: 0.08),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (dialogContext, animation, secondaryAnimation) =>
            _AuthRequiredDialog(onLogin: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(AppRoutes.login);
            }, onRegister: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(AppRoutes.register);
            }),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(
              title: l10n.cartTitle,
              onCartTap: () {},
              titleStyle:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.black,
                  ) ??
                  const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.black,
                  ),
            ),
            Expanded(
              child: Container(
                color: pageBg,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                        child: _CartListCard(
                          entries: entries,
                          onMinus: state.removeProduct,
                          onPlus: state.addProduct,
                          currency: currency,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: _SummaryCard(
                        subtotal: subtotal,
                        delivery: delivery,
                        discountPercent: discountPercent,
                        currency: currency,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: _PayButton(
                        enabled: totalItems > 0,
                        onPressed: () {
                          if (!state.isAuthorized) {
                            showAuthRequiredDialog();
                            return;
                          }
                          Navigator.of(context).pushNamed(AppRoutes.checkout);
                        },
                      ),
                    ),
                  ],
                ),
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
}

class _CartEntry {
  const _CartEntry({required this.id, required this.qty, required this.meta});

  final String id;
  final int qty;
  final CartItemMeta? meta;

  String get title => meta?.title ?? '';
  String titleForLocale(String languageCode) {
    if (meta == null) return '';
    return meta!.titleForLocale(languageCode);
  }
  int get unitPrice => meta?.unitPrice ?? 0;
  String? get image => meta?.image;
  String? get subtitle => meta?.subtitle;
}

class _CartListCard extends StatelessWidget {
  const _CartListCard({
    required this.entries,
    required this.onMinus,
    required this.onPlus,
    required this.currency,
  });

  final List<_CartEntry> entries;
  final void Function(String productId) onMinus;
  final void Function(String productId) onPlus;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE6),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: entries.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.cartEmpty,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            )
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 78),
                child: Divider(
                  height: 26,
                  thickness: 1,
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ),
              itemBuilder: (context, index) => _CartLineRow(
                entry: entries[index],
                onMinus: () => onMinus(entries[index].id),
                onPlus: () => onPlus(entries[index].id),
                currency: currency,
              ),
            ),
    );
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({
    required this.entry,
    required this.onMinus,
    required this.onPlus,
    required this.currency,
  });

  final _CartEntry entry;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final resolvedTitle = entry.titleForLocale(localeCode);
    final title = resolvedTitle.isEmpty ? l10n.productDefault : resolvedTitle;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 58,
            height: 58,
            child: _CartImage(src: entry.image),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MarqueeText(
                text: title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              if (entry.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  entry.subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${formatMoney(entry.unitPrice)} $currency',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _QtyStepper(qty: entry.qty, onMinus: onMinus, onPlus: onPlus),
      ],
    );
  }
}

class _CartImage extends StatelessWidget {
  const _CartImage({required this.src});

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
      color: Colors.white.withValues(alpha: 0.65),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(label: '–', onTap: onMinus),
        const SizedBox(width: 10),
        SizedBox(
          width: 20,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _QtyButton(label: '+', onTap: onPlus),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: const Color(0xFFCFB07A),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueeText extends StatelessWidget {
  const _MarqueeText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final painter = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final isOverflow = painter.width > constraints.maxWidth;

        if (!isOverflow) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }

        const gap = 24.0;
        const speed = 60.0;
        const pause = Duration(milliseconds: 1000);

        return SizedBox(
          height: painter.height + 2,
          child: _Marquee(
            distance: painter.width + gap,
            gap: gap,
            speed: speed,
            pause: pause,
            child: Text(text, style: style),
          ),
        );
      },
    );
  }
}

class _Marquee extends StatefulWidget {
  const _Marquee({
    required this.child,
    required this.distance,
    required this.gap,
    required this.speed,
    required this.pause,
  });

  final Widget child;
  final double distance;
  final double gap;
  final double speed;
  final Duration pause;

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  @override
  void didUpdateWidget(covariant _Marquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distance != widget.distance ||
        oldWidget.speed != widget.speed ||
        oldWidget.pause != widget.pause ||
        oldWidget.gap != widget.gap) {
      _configure();
    }
  }

  void _configure() {
    final moveMillis = (widget.distance / widget.speed * 1000).round();
    final moveDuration = Duration(
      milliseconds: moveMillis < 400 ? 400 : moveMillis,
    );
    _controller
      ..stop()
      ..reset()
      ..duration = widget.pause * 2 + moveDuration;

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: widget.pause.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -widget.distance),
        weight: moveDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(-widget.distance),
        weight: widget.pause.inMilliseconds.toDouble(),
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                child!,
                SizedBox(width: widget.gap),
                child,
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.delivery,
    required this.discountPercent,
    required this.currency,
  });

  final int subtotal;
  final int delivery;
  final int discountPercent;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE6),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        children: [
          _SummaryRow(
            label: AppLocalizations.of(context)!.totalSum,
            value: '${formatMoney(subtotal)} $currency',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: AppLocalizations.of(context)!.delivery,
            value: '${formatMoney(delivery)} $currency',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: AppLocalizations.of(context)!.discount,
            value: '$discountPercent%',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          height: 64,
          width: double.infinity,
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
                  AppLocalizations.of(context)!.payButton,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
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
