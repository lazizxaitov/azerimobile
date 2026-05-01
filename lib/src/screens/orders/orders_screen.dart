import 'dart:async';

import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<void> _loadFuture;
  bool _didLoad = false;

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
        await AppStateScope.of(context).loadCustomerOrders();
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final currency = state.currencySymbol.isNotEmpty
        ? state.currencySymbol
        : l10n.currencySum;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(
              title: l10n.ordersTitle,
              showCartButton: false,
            ),
            Expanded(
              child: Container(
                color: pageBg,
                child: FutureBuilder<void>(
                  future: _loadFuture,
                  builder: (context, snapshot) {
                    final orders = state.orders;
                    if (orders.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.ordersEmpty,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.orderDetail,
                            arguments: order,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '#${order.id}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    _OrderStatusChip(
                                      status: order.status,
                                      localized: _localizedStatus(
                                        context,
                                        order.status,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(order.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${formatMoney(order.totalAmount)} $currency',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({
    required this.status,
    required this.localized,
  });

  final String status;
  final String localized;

  @override
  Widget build(BuildContext context) {
    final label = localized.trim().isNotEmpty ? localized : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '';
  final date = value.toLocal();
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String _localizedStatus(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status.toLowerCase()) {
    case 'paid':
    case 'accepted':
      return l10n.orderStatusAccepted;
    case 'in_delivery':
    case 'delivering':
      return l10n.orderStatusDelivering;
    case 'completed':
      return l10n.orderStatusDelivered;
    case 'canceled':
    case 'cancelled':
      return l10n.orderStatusCanceled;
    default:
      return status;
  }
}
