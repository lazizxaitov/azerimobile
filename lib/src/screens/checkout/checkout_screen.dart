import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../models/address.dart';
import '../../models/order.dart';
import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../utils/money_format.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/address_map_picker.dart';

enum OrderType { delivery, pickup }

enum PaymentMethod { card, cash }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  OrderType _orderType = OrderType.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.card;

  Address? _deliveryAddressItem;
  String? _pickupStore;

  bool _useBonus = false;
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _orderCommentController = TextEditingController();


  String? _orderComment;
  bool _isSubmitting = false;

  bool get _isCardEnabled =>
      AppStateScope.of(context).settings?.paymentCardEnabled ?? true;

  bool get _isCashEnabled =>
      AppStateScope.of(context).settings?.paymentCashEnabled ?? true;

  @override
  void dispose() {
    _bonusController.dispose();
    _orderCommentController.dispose();
    super.dispose();
  }

  void _ensurePaymentMethodAllowed() {
    if (_paymentMethod == PaymentMethod.card && !_isCardEnabled) {
      if (_isCashEnabled) {
        setState(() => _paymentMethod = PaymentMethod.cash);
      }
      return;
    }
    if (_paymentMethod == PaymentMethod.cash && !_isCashEnabled) {
      if (_isCardEnabled) {
        setState(() => _paymentMethod = PaymentMethod.card);
      }
    }
  }

  Future<void> _selectPaymentMethod(PaymentMethod method) async {
    if (method == PaymentMethod.cash && !_isCashEnabled) return;

    if (method == PaymentMethod.card && !_isCardEnabled) {
      await _showCardPaymentUnavailableDialog();
      return;
    }

    setState(() => _paymentMethod = method);
    if (!mounted) return;
    if (method != PaymentMethod.card) return;

    final settings = AppStateScope.of(context).settings;
    if (settings == null) return;
    final localeCode = Localizations.localeOf(context).languageCode;
    final title = settings.cardPaymentInfoTitleForLocale(localeCode);
    final body = settings.cardPaymentInfoBodyForLocale(localeCode);
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    await _showCardPaymentInfoDialog(
      title: title,
      body: body,
    );
  }

  Future<void> _showCardPaymentUnavailableDialog() async {
    final settings = AppStateScope.of(context).settings;
    if (settings == null) return;
    final localeCode = Localizations.localeOf(context).languageCode;
    final title = settings.cardPaymentUnavailableTitleForLocale(localeCode);
    final body = settings.cardPaymentUnavailableBodyForLocale(localeCode) ??
        settings.cardPaymentInfoBodyForLocale(localeCode);
    final cardNumber = settings.cardPaymentUnavailableCardNumber?.trim();
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty) &&
        (cardNumber == null || cardNumber.isEmpty)) {
      return;
    }
    await _showCardPaymentInfoDialog(
      title: (title == null || title.trim().isEmpty)
          ? AppLocalizations.of(context)!.payByCard
          : title,
      body: body,
      cardNumber: cardNumber,
    );
  }

  Future<void> _showCardPaymentInfoDialog({
    required String? title,
    required String? body,
    String? cardNumber,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  (title == null || title.trim().isEmpty)
                      ? l10n.payByCard
                      : title.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                if (body != null && body.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    body.trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                if (cardNumber != null && cardNumber.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _CopyCardNumber(
                    cardNumber: cardNumber.trim(),
                    onCopied: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.copied),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensurePaymentMethodAllowed();
    });

    final subtotal = state.cartQuantities.entries.fold<int>(0, (sum, e) {
      final meta = state.cartMeta[e.key];
      final unitPrice = meta?.unitPrice ?? 0;
      return sum + e.value * unitPrice;
    });

    final totalItems = state.cartItemCount;
    final settingsDelivery = state.settings?.deliveryFee ?? 50000;
    final deliveryFee = (_orderType == OrderType.delivery && totalItems > 0)
        ? settingsDelivery
        : 0;
    final bonusAvailable = state.bonusBalanceValue;
    final bonusLimit = _effectiveBonusLimit(bonusAvailable);
    final bonusError = _useBonus ? _bonusValidationError(bonusAvailable) : null;
    final bonusDiscount =
        (_useBonus && bonusError == null)
            ? _bonusToUseFor(subtotal, bonusAvailable, bonusLimit)
            : 0;
    final total = subtotal + deliveryFee - bonusDiscount;
    final currency = state.currencySymbol.isNotEmpty
        ? state.currencySymbol
        : l10n.currencySum;

    final hasPlace = _orderType == OrderType.delivery
        ? (_deliveryAddressItem?.addressLine.trim().isNotEmpty ?? false)
        : (_pickupStore?.trim().isNotEmpty ?? false);
    final canConfirm = totalItems > 0 && hasPlace && bonusError == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(
              title: l10n.checkoutTitle,
              showCartButton: false,
            ),
            Expanded(
              child: Container(
                color: pageBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(l10n.orderType),
                          const SizedBox(height: 12),
                          _Segmented(
                            leftLabel: l10n.deliveryOption,
                            rightLabel: l10n.pickupOption,
                            leftSelected: _orderType == OrderType.delivery,
                            onLeft: () =>
                                setState(() => _orderType = OrderType.delivery),
                            onRight: () =>
                                setState(() => _orderType = OrderType.pickup),
                          ),
                          const SizedBox(height: 14),
                          if (_orderType == OrderType.delivery)
                            _SelectButton(
                              label:
                                  _deliveryAddressItem?.addressLine
                                              .trim()
                                              .isNotEmpty ==
                                          true
                                      ? _deliveryAddressItem!.addressLine
                                      : l10n.deliveryAddress,
                              onTap: _pickDeliveryAddress,
                            )
                          else
                            _SelectButton(
                              label: _pickupStore?.trim().isNotEmpty == true
                                  ? _pickupStore!
                                  : l10n.pickupPlace,
                              onTap: _pickStore,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(l10n.paymentMethod),
                          const SizedBox(height: 12),
                          _Segmented(
                            leftLabel: l10n.payByCard,
                            rightLabel: l10n.payByCash,
                            leftSelected: _paymentMethod == PaymentMethod.card,
                            leftEnabled: _isCardEnabled,
                            rightEnabled: _isCashEnabled,
                            onLeftDisabledTap: _showCardPaymentUnavailableDialog,
                            onLeft: () => _selectPaymentMethod(
                              PaymentMethod.card,
                            ),
                            onRight: () => _selectPaymentMethod(
                              PaymentMethod.cash,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _BonusToggle(
                            value: _useBonus,
                            onChanged: _handleUseBonusChanged,
                          ),
                          if (_useBonus) ...[
                            const SizedBox(height: 10),
                            Text(
                              l10n.youHaveBonuses(
                                formatMoney(bonusAvailable),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _BonusInput(
                              controller: _bonusController,
                              hintText: l10n.bonusAmountHint,
                              onChanged: (_) => setState(() {}),
                              errorText: bonusError,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            l10n.orderComment,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _CommentInput(
                            controller: _orderCommentController,
                            hintText: l10n.commentPlaceholder,
                            onChanged: (value) {
                              final trimmed = value.trim();
                              setState(
                                () => _orderComment =
                                    trimmed.isEmpty ? null : value,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              color: pageBg,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(
            children: [
              Container(
                height: 1,
                color: Colors.black.withValues(alpha: 0.08),
              ),
              _Card(
                child: Column(
                  children: [
                        _Row(
                          label: l10n.totalSum,
                          value: '${formatMoney(subtotal)} $currency',
                        ),
                        if (_orderType == OrderType.delivery) ...[
                          const SizedBox(height: 12),
                          _Row(
                            label: l10n.delivery,
                            value: '${formatMoney(deliveryFee)} $currency',
                          ),
                        ],
                        if (_useBonus) ...[
                          const SizedBox(height: 12),
                          _Row(
                            label: l10n.discount,
                            value: '${formatMoney(bonusDiscount)} $currency',
                          ),
                        ],
                        const Divider(height: 26, thickness: 1),
                        _Row(
                          label: l10n.grandTotal,
                          value: '${formatMoney(total)} $currency',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ConfirmButton(
                    enabled: canConfirm && !_isSubmitting,
                    onTap: _submitOrder,
                  ),
                ],
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

  void _handleUseBonusChanged(bool v) {
    setState(() {
      _useBonus = v;
      if (!_useBonus) _bonusController.text = '';
    });
  }

  String? _bonusValidationError(int bonusAvailable) {
    final raw = int.tryParse(_bonusController.text.replaceAll(' ', '')) ?? 0;
    if (raw <= 0) return null;
    if (raw > bonusAvailable) {
      return AppLocalizations.of(context)!.bonusNotEnough;
    }
    return null;
  }

  int _bonusToUseFor(int subtotal, int balance, int limit) {
    final raw = int.tryParse(_bonusController.text.replaceAll(' ', '')) ?? 0;
    final nonNegative = raw < 0 ? 0 : raw;
    final clampedToBalance = nonNegative > balance
        ? balance
        : nonNegative;
    final clampedToLimit =
        clampedToBalance > limit ? limit : clampedToBalance;
    return clampedToLimit > subtotal ? subtotal : clampedToLimit;
  }

  int _effectiveBonusLimit(int bonusAvailable) {
    final settingsLimit = AppStateScope.of(context).settings?.bonusRedeemAmount;
    if (settingsLimit == null || settingsLimit <= 0) {
      return bonusAvailable;
    }
    return settingsLimit > bonusAvailable ? bonusAvailable : settingsLimit;
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    final state = AppStateScope.of(context);
    final subtotal = state.cartQuantities.entries.fold<int>(0, (sum, e) {
      final meta = state.cartMeta[e.key];
      final unitPrice = meta?.unitPrice ?? 0;
      return sum + e.value * unitPrice;
    });
    final bonusAvailable = state.bonusBalanceValue;
    final bonusLimit = _effectiveBonusLimit(bonusAvailable);
    final bonusError = _useBonus ? _bonusValidationError(bonusAvailable) : null;
    if (_useBonus && bonusError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bonusError)),
      );
      return;
    }
    final bonusDiscount =
        _useBonus ? _bonusToUseFor(subtotal, bonusAvailable, bonusLimit) : 0;
    final items = state.cartQuantities.entries
        .map((entry) {
          final meta = state.cartMeta[entry.key];
          final productId = _parseProductId(entry.key);
          final titleRu = meta?.titleRu ?? meta?.title ?? '';
          final titleUz = meta?.titleUz ?? meta?.title ?? '';
          return OrderItemPayload(
            productId: productId,
            titleRu: titleRu,
            titleUz: titleUz,
            price: meta?.unitPrice ?? 0,
            quantity: entry.value,
          );
        })
        .where((item) => item.productId > 0 && item.quantity > 0)
        .toList(growable: false);

    if (items.isEmpty) return;

    final payload = OrderCreatePayload(
      customerId: state.customer?.id,
      customerName: state.customer?.name ?? '',
      customerPhone: state.customer?.phone ?? '',
      addressId:
          _orderType == OrderType.delivery ? _deliveryAddressItem?.id : null,
      addressLine: _orderType == OrderType.delivery
          ? _deliveryAddressItem?.addressLine
          : null,
      addressLabel: _orderType == OrderType.delivery
          ? _deliveryAddressItem?.label
          : null,
      addressComment: _orderType == OrderType.delivery
          ? _deliveryAddressItem?.comment
          : null,
      comment: _orderComment,
      bonusUsed: _useBonus ? bonusDiscount : 0,
      paymentMethod: _paymentMethod == PaymentMethod.card ? 'card' : 'cash',
      items: items,
    );

    setState(() => _isSubmitting = true);
    try {
      await state.createOrder(payload);
      if (!mounted) return;
      state.clearCart();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.orderSuccess,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int _parseProductId(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return 0;
    final base = trimmed.split(':').first;
    return int.tryParse(base) ?? 0;
  }

  Future<void> _pickDeliveryAddress() async {
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    await state.loadCustomerAddresses();
    if (!mounted) return;
    final addressOptions = state.addresses;
    final selected = await showModalBottomSheet<Address>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return _AddressPickerSheet(
          title: l10n.deliveryAddress,
          options: addressOptions,
          emptyLabel: l10n.noAddresses,
          addLabel: l10n.addNewAddress,
          onAdd: () => _addNewAddress(context),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _deliveryAddressItem = selected);
  }

  Future<void> _pickStore() async {
    final l10n = AppLocalizations.of(context)!;
    final state = AppStateScope.of(context);
    final options = state.pickupPoints
        .map((p) {
          final title = p.title.trim();
          final address = p.address.trim();
          if (title.isNotEmpty && address.isNotEmpty) {
            return '$title - $address';
          }
          return title.isNotEmpty ? title : address;
        })
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return _PickerSheet(
          title: l10n.pickupPlace,
          options: options,
          emptyLabel: l10n.noPickupPoints,
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _pickupStore = selected);
  }

  Future<void> _addNewAddress(BuildContext parentContext) async {
    final l10n = AppLocalizations.of(parentContext)!;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final commentController = TextEditingController();
    final result = await showModalBottomSheet<AddressPayload>(
      context: parentContext,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: true,
      builder: (context) {
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
                    l10n.newAddressTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: AddressMapPicker(
                      addressController: addressController,
                      languageCode:
                          Localizations.localeOf(context).languageCode,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: nameController,
                    hintText: l10n.addressNameHint,
                  ),
                  const SizedBox(height: 10),
                  _Field(
                    controller: addressController,
                    hintText: l10n.addressAutoHint,
                  ),
                  const SizedBox(height: 10),
                  _Field(
                    controller: commentController,
                    hintText: l10n.addressCommentHint,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final label = nameController.text.trim();
                          final addressLine = addressController.text.trim();
                          final comment = commentController.text.trim();
                          if (label.isEmpty || addressLine.isEmpty) {
                            Navigator.of(context).pop();
                            return;
                          }
                          Navigator.of(context).pop(
                            AddressPayload(
                              label: label,
                              addressLine: addressLine,
                              comment: comment.isEmpty ? null : comment,
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            l10n.save,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
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
      },
    );
    nameController.dispose();
    addressController.dispose();
    commentController.dispose();
    if (!mounted || result == null) return;
    if (!parentContext.mounted) return;
    try {
      final created =
          await AppStateScope.of(parentContext).addAddress(result);
      if (!parentContext.mounted) return;
      Navigator.of(parentContext).pop(created);
      return;
    } catch (_) {
      return;
    }
  }

  // Comment input is inline; modal removed.
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    this.leftEnabled = true,
    this.rightEnabled = true,
    this.onLeftDisabledTap,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final bool leftEnabled;
  final bool rightEnabled;
  final VoidCallback? onLeftDisabledTap;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: leftLabel,
              selected: leftSelected,
              enabled: leftEnabled,
              onTap: leftEnabled ? onLeft : onLeftDisabledTap,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _Segment(
              label: rightLabel,
              selected: !leftSelected,
              enabled: rightEnabled,
              onTap: rightEnabled ? onRight : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled;
    final resolvedSelected = selected && isActive;
    return Material(
      color: resolvedSelected ? const Color(0xFFCFB07A) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Opacity(
            opacity: isActive ? 1.0 : 0.42,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: resolvedSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectButton extends StatelessWidget {
  const _SelectButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextButtonCard extends StatelessWidget {
  const _TextButtonCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BonusToggle extends StatelessWidget {
  const _BonusToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const trackOff = Color(0x24000000);
    const trackOn = Color(0xFFCFB07A);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.useBonus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 46,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: value ? trackOn : trackOff,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
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

class _BonusInput extends StatelessWidget {
  const _BonusInput({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: false,
            fillColor: Colors.transparent,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.45),
            ),
            errorText: errorText,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _CopyCardNumber extends StatelessWidget {
  const _CopyCardNumber({
    required this.cardNumber,
    required this.onCopied,
  });

  final String cardNumber;
  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: cardNumber));
          onCopied();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cardNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.copy,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.copy_rounded,
                size: 18,
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w800 : FontWeight.w700;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: weight,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: weight,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              onTap: onTap,
              child: Center(
                child: Text(
                  l10n.confirmOrder,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: false,
            fillColor: Colors.transparent,
            hintText: hintText,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet({
    required this.title,
    required this.options,
    required this.addLabel,
    required this.onAdd,
    this.emptyLabel,
  });

  final String title;
  final List<Address> options;
  final String addLabel;
  final VoidCallback onAdd;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              if (options.isEmpty && emptyLabel != null) ...[
                Text(
                  emptyLabel!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                for (final o in options) ...[
                  SizedBox(
                    height: 44,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.of(context).pop(o),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  o.addressLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              SizedBox(
                height: 44,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onAdd,
                    child: Center(
                      child: Text(
                        addLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
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

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    this.emptyLabel,
  });

  final String title;
  final List<String> options;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              if (options.isEmpty && emptyLabel != null) ...[
                Text(
                  emptyLabel!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                for (final o in options) ...[
                  SizedBox(
                    height: 44,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.of(context).pop(o),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              o,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            filled: false,
            fillColor: Colors.transparent,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
