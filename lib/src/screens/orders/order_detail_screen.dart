import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order.dart';
import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Object? order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderHistory? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.order is OrderHistory ? widget.order as OrderHistory : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final currency = state.currencySymbol.isNotEmpty
        ? state.currencySymbol
        : l10n.currencySum;

    final OrderHistory? data = _current;

    if (data == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              AppTopBar(title: l10n.orderDetailsTitle, showCartButton: false),
              const Expanded(child: Center(child: Text('...'))),
            ],
          ),
        ),
      );
    }

    final status = data.status.toLowerCase();
    final isAccepted = status == 'paid' ||
        status == 'accepted' ||
        status == 'in_delivery' ||
        status == 'completed';
    final isDelivering = status == 'in_delivery' || status == 'completed';
    final isDelivered = status == 'completed';
    final isCanceled = status == 'canceled' || status == 'cancelled';
    final showCourier = !isDelivered && !isCanceled && data.courier != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(
              title: l10n.orderDetailsTitle,
              showCartButton: false,
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF8F7F3),
                child: RefreshIndicator(
                  color: const Color(0xFFCFB07A),
                  onRefresh: _refreshOrder,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    children: [
                      _InfoCard(
                        orderId: data.id,
                        createdAt: data.createdAt,
                        total: data.totalAmount,
                        currency: currency,
                        status: data.status,
                      ),
                      const SizedBox(height: 12),
                      _StatusCard(
                        accepted: isAccepted,
                        delivering: isDelivering,
                        delivered: isDelivered,
                        canceled: isCanceled,
                      ),
                      if (showCourier) ...[
                        const SizedBox(height: 12),
                        _CourierCard(courier: data.courier!),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        l10n.orderItemsTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.items.map((item) {
                        final title = state.languageCode == 'uz'
                            ? item.titleUz
                            : item.titleRu;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${formatMoney(item.total)} $currency',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppBottomTab.profile,
        onMenuTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    );
  }

  Future<void> _refreshOrder() async {
    final state = AppStateScope.of(context);
    await state.loadCustomerOrders();
    final orderId = _current?.id ?? 0;
    if (orderId == 0) return;
    final latest = state.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => _current!,
    );
    if (!mounted) return;
    setState(() => _current = latest);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.orderId,
    required this.createdAt,
    required this.total,
    required this.currency,
    required this.status,
  });

  final int orderId;
  final DateTime? createdAt;
  final int total;
  final String currency;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#$orderId',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          if (createdAt != null)
            Text(
              _formatDate(createdAt),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${formatMoney(total)} $currency',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _localizedStatus(context, status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.accepted,
    required this.delivering,
    required this.delivered,
    required this.canceled,
  });

  final bool accepted;
  final bool delivering;
  final bool delivered;
  final bool canceled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (canceled) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Color(0xFFD32F2F)),
            const SizedBox(width: 10),
            Text(
              l10n.orderStatusCanceled,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(
            label: l10n.orderStatusAccepted,
            active: accepted,
          ),
          _StatusRow(
            label: l10n.orderStatusDelivering,
            active: delivering,
          ),
          _StatusRow(
            label: l10n.orderStatusDelivered,
            active: delivered,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.active,
    this.isLast = false,
  });

  final String label;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFFCFB07A) : const Color(0x33000000),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard({required this.courier});

  final CourierInfo courier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.courierInfoTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _CourierLine(label: l10n.courierName, value: courier.name),
          _CourierLine(label: l10n.courierPhone, value: courier.phone),
          if (courier.carNumber.trim().isNotEmpty)
            _CourierLine(label: l10n.courierCar, value: courier.carNumber),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _callNumber(courier.phone),
                child: Text(
                  l10n.callCourier,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _CourierLine extends StatelessWidget {
  const _CourierLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _callNumber(String phone) async {
  final value = phone.trim();
  if (value.isEmpty) return;
  final uri = Uri.parse('tel:$value');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
