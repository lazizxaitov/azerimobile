import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/api_repository.dart';
import '../models/address.dart';
import '../models/banner.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/bonus.dart';
import '../models/notification_item.dart';
import '../models/order.dart';
import '../models/pickup_point.dart';
import '../models/product.dart' as api;
import '../models/product_args.dart' as ui;
import '../models/settings.dart';
import '../models/top_product.dart';
import '../utils/money_format.dart';
import 'app_preferences.dart';

class CartItemMeta {
  const CartItemMeta({
    required this.id,
    required this.title,
    required this.unitPrice,
    this.titleRu,
    this.titleUz,
    this.image,
    this.subtitle,
  });

  final String id;
  final String title;
  final int unitPrice;
  final String? titleRu;
  final String? titleUz;
  final String? image;
  final String? subtitle;

  String titleForLocale(String languageCode) {
    return switch (languageCode.toLowerCase()) {
      'uz' => titleUz?.trim().isNotEmpty == true ? titleUz! : title,
      'ru' => titleRu?.trim().isNotEmpty == true ? titleRu! : title,
      _ => title,
    };
  }
}

class AppState extends ChangeNotifier {
  bool _hasUnreadNotifications = false;
  bool _isAuthorized = false;
  Locale? _locale;
  final ApiRepository _api = ApiRepository();

  Future<void>? _initialLoadFuture;
  bool _isLoadingInitial = false;
  bool _isAutoRefreshing = false;
  String? _initialLoadError;
  List<BannerItem> _banners = const [];
  List<CategoryItem> _categories = const [];
  List<api.ProductItem> _products = const [];
  List<TopProductItem> _topProducts = const [];
  AppSettings? _settings;
  Customer? _customer;
  List<Address> _addresses = const [];
  List<NotificationItem> _notifications = const [];
  List<PickupPoint> _pickupPoints = const [];
  BonusBalance? _bonusBalance;
  List<OrderHistory> _orders = const [];
  final Map<int, List<api.ProductItem>> _categoryProductsCache =
      <int, List<api.ProductItem>>{};

  final Map<String, int> _cartQuantities = <String, int>{};
  final Map<String, CartItemMeta> _cartMeta = <String, CartItemMeta>{};
  Timer? _autoRefreshTimer;

  bool get hasUnreadNotifications => _hasUnreadNotifications;
  bool get isAuthorized => _isAuthorized;
  Locale? get locale => _locale;
  bool get isLoadingInitial => _isLoadingInitial;
  String? get initialLoadError => _initialLoadError;
  List<BannerItem> get banners => _banners;
  List<CategoryItem> get categories => _categories;
  List<api.ProductItem> get products => _products;
  List<TopProductItem> get topProductRefs => _topProducts;
  AppSettings? get settings => _settings;
  Customer? get customer => _customer;
  List<Address> get addresses => _addresses;
  List<NotificationItem> get notifications => _notifications;
  List<PickupPoint> get pickupPoints => _pickupPoints;
  BonusBalance? get bonusBalance => _bonusBalance;
  int get bonusBalanceValue => _bonusBalance?.balance ?? 0;
  List<OrderHistory> get orders => _orders;
  String get currencySymbol => _settings?.currency ?? '';

  int get cartItemCount =>
      _cartQuantities.values.fold<int>(0, (sum, e) => sum + e);
  bool get cartHasItems => cartItemCount > 0;

  UnmodifiableMapView<String, int> get cartQuantities =>
      UnmodifiableMapView(_cartQuantities);

  UnmodifiableMapView<String, CartItemMeta> get cartMeta =>
      UnmodifiableMapView(_cartMeta);

  String get languageCode => _locale?.languageCode ?? 'ru';

  Future<void> loadInitialData() {
    _initialLoadFuture ??= _loadInitialData();
    return _initialLoadFuture!;
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) async {
      if (_isAutoRefreshing) return;
      _isAutoRefreshing = true;
      try {
        await refreshInitialData();
        final customerId = _customer?.id ?? 0;
        if (customerId > 0) {
          await refreshCustomerBundle(customerId);
        }
      } finally {
        _isAutoRefreshing = false;
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoadingInitial) return;
    _isLoadingInitial = true;
    _initialLoadError = null;
    notifyListeners();
    await _restoreInitialCache();
    try {
      final results = await Future.wait([
        _api.fetchBanners(),
        _api.fetchCategories(),
        _api.fetchProducts(),
        _api.fetchTopProducts(),
        _api.fetchSettings(),
        _api.fetchPickupPoints(),
      ]);
      _banners = results[0] as List<BannerItem>;
      _categories = results[1] as List<CategoryItem>;
      _products = results[2] as List<api.ProductItem>;
      _topProducts = results[3] as List<TopProductItem>;
      _settings = results[4] as AppSettings;
      _pickupPoints = results[5] as List<PickupPoint>;
      await _persistInitialCache();
    } catch (e) {
      _initialLoadError = e.toString();
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> refreshInitialData() async {
    if (_isLoadingInitial) return;
    _isLoadingInitial = true;
    _initialLoadError = null;
    try {
      final results = await Future.wait([
        _api.fetchBanners(),
        _api.fetchCategories(),
        _api.fetchProducts(),
        _api.fetchTopProducts(),
        _api.fetchSettings(),
        _api.fetchPickupPoints(),
      ]);
      _banners = results[0] as List<BannerItem>;
      _categories = results[1] as List<CategoryItem>;
      _products = results[2] as List<api.ProductItem>;
      _topProducts = results[3] as List<TopProductItem>;
      _settings = results[4] as AppSettings;
      _pickupPoints = results[5] as List<PickupPoint>;
      await _persistInitialCache();
      notifyListeners();
    } catch (e) {
      _initialLoadError = e.toString();
    } finally {
      _isLoadingInitial = false;
    }
  }

  Future<void> refreshNotifications() async {
    await _restoreLocalNotifications();
    notifyListeners();
  }

  Future<void> refreshPickupPoints() async {
    try {
      final items = await _api.fetchPickupPoints();
      _pickupPoints = items;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCustomerProfile() async {
    final id = _customer?.id ?? 0;
    if (id == 0) return;
    try {
      final profile = await _api.fetchCustomerProfile(id);
      _customer = profile;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCustomerProfileById(int customerId) async {
    if (customerId <= 0) return;
    try {
      final profile = await _api.fetchCustomerProfile(customerId);
      _customer = profile;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCustomerBundle(int customerId) async {
    if (customerId <= 0) return;
    await _restoreCustomerCache(customerId);
    try {
      final results = await Future.wait([
        _safeProfile(customerId),
        _safeBonuses(customerId),
        _safeAddresses(customerId),
        _safeOrders(customerId),
      ]);
      final profile = results[0] as Customer?;
      final bonuses = results[1] as BonusBalance?;
      final addresses = results[2] as List<Address>?;
      final orders = results[3] as List<OrderHistory>?;
      if (profile != null) _customer = profile;
      if (bonuses != null) _bonusBalance = bonuses;
      if (addresses != null) _addresses = addresses;
      if (orders != null) _orders = orders;
      notifyListeners();
      await _persistCustomerCache(customerId);
    } catch (_) {}
  }

  Future<void> refreshCustomerBundle(int customerId) async {
    if (customerId <= 0) return;
    try {
      final results = await Future.wait([
        _safeProfile(customerId),
        _safeBonuses(customerId),
        _safeAddresses(customerId),
        _safeOrders(customerId),
      ]);
      final profile = results[0] as Customer?;
      final bonuses = results[1] as BonusBalance?;
      final addresses = results[2] as List<Address>?;
      final orders = results[3] as List<OrderHistory>?;
      if (profile != null) _customer = profile;
      if (bonuses != null) _bonusBalance = bonuses;
      if (addresses != null) _addresses = addresses;
      if (orders != null) _orders = orders;
      notifyListeners();
      await _persistCustomerCache(customerId);
    } catch (_) {}
  }

  Future<void> loadCustomerOrders() async {
    final id = _customer?.id ?? 0;
    if (id == 0) return;
    try {
      final items = await _api.fetchCustomerOrders(id);
      _orders = items;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCustomerBonuses() async {
    final id = _customer?.id ?? 0;
    if (id == 0) return;
    try {
      _bonusBalance = await _api.fetchCustomerBonuses(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<Customer?> _safeProfile(int customerId) async {
    try {
      return await _api.fetchCustomerProfile(customerId);
    } catch (_) {
      return null;
    }
  }

  Future<BonusBalance?> _safeBonuses(int customerId) async {
    try {
      return await _api.fetchCustomerBonuses(customerId);
    } catch (_) {
      return null;
    }
  }

  Future<List<Address>?> _safeAddresses(int customerId) async {
    try {
      return await _api.fetchCustomerAddresses(customerId);
    } catch (_) {
      return null;
    }
  }

  Future<List<OrderHistory>?> _safeOrders(int customerId) async {
    try {
      return await _api.fetchCustomerOrders(customerId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadCustomerAddresses() async {
    final id = _customer?.id ?? 0;
    if (id == 0) return;
    try {
      final items = await _api.fetchCustomerAddresses(id);
      _addresses = items;
      notifyListeners();
    } catch (_) {}
  }

  void markAllNotificationsRead() {
    if (_notifications.isEmpty) return;
    _notifications = _notifications
        .map(
          (n) => NotificationItem(
            id: n.id,
            titleRu: n.titleRu,
            titleUz: n.titleUz,
            bodyRu: n.bodyRu,
            bodyUz: n.bodyUz,
            imageUrl: n.imageUrl,
            isRead: true,
            createdAt: n.createdAt,
          ),
        )
        .toList(growable: false);
    _hasUnreadNotifications = false;
    notifyListeners();
    _persistLocalNotifications();
  }

  Future<void> addLocalNotification({
    required String titleRu,
    required String titleUz,
    required String bodyRu,
    required String bodyUz,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    final item = NotificationItem(
      id: now.millisecondsSinceEpoch,
      titleRu: titleRu,
      titleUz: titleUz,
      bodyRu: bodyRu,
      bodyUz: bodyUz,
      imageUrl: imageUrl,
      isRead: false,
      createdAt: now,
    );
    _notifications = [item, ..._notifications];
    _hasUnreadNotifications = true;
    notifyListeners();
    await _persistLocalNotifications();
  }

  Future<List<api.ProductItem>> loadCategoryProducts(int categoryId) async {
    final cached = _categoryProductsCache[categoryId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final products = await _api.fetchProductsByCategory(categoryId);
    _categoryProductsCache[categoryId] = products;
    notifyListeners();
    return products;
  }

  Future<List<api.ProductItem>> refreshCategoryProducts(int categoryId) async {
    final products = await _api.fetchProductsByCategory(categoryId);
    _categoryProductsCache[categoryId] = products;
    notifyListeners();
    return products;
  }

  List<api.ProductItem> categoryProducts(int categoryId) {
    return _categoryProductsCache[categoryId] ?? const [];
  }

  List<api.ProductItem> topProducts() {
    if (_topProducts.isEmpty || _products.isEmpty) return const [];
    final map = {for (final p in _products) p.id: p};
    final items = _topProducts
        .where((t) => map.containsKey(t.productId))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items.map((t) => map[t.productId]!).toList(growable: false);
  }

  ui.ProductArgs mapProductToArgs(
    api.ProductItem product, {
    String? languageCode,
  }) {
    final code = (languageCode ?? this.languageCode).toLowerCase();
    final title = code == 'uz' ? product.titleUz : product.titleRu;
    final descTitle =
        code == 'uz' ? product.descriptionTitleUz : product.descriptionTitleRu;
    final descText =
        code == 'uz' ? product.descriptionTextUz : product.descriptionTextRu;
    final priceText = _resolvePriceText(product, code);
    return ui.ProductArgs(
      id: product.id.toString(),
      title: title,
      price: product.price,
      priceText: priceText,
      descriptionTitle: descTitle,
      descriptionText: descText,
      mode: product.pricingMode == api.ProductPricingMode.portion
          ? ui.ProductPricingMode.portion
          : ui.ProductPricingMode.quantity,
      images: product.images,
      portionOptions: product.portionOptions
          .map(
            (o) => ui.PortionOption(
              id: o.id.toString(),
              label: code == 'uz' ? o.labelUz : o.labelRu,
              price: o.price,
            ),
          )
          .toList(growable: false),
      titleRu: product.titleRu,
      titleUz: product.titleUz,
    );
  }

  String _resolvePriceText(api.ProductItem product, String code) {
    final text =
        code == 'uz' ? product.priceTextUz : product.priceTextRu;
    if (text != null && text.trim().isNotEmpty) return text;
    final currency = currencySymbol.isNotEmpty ? currencySymbol : 'сум';
    return '${formatMoney(product.price)} $currency';
  }

  Future<Customer> registerCustomer({
    required String name,
    required String phone,
    required String password,
  }) async {
    final customer = await _api.registerCustomer(
      CustomerRegistration(name: name, phone: phone, password: password),
    );
    _customer = customer;
    setAuthorized(true);
    await loadCustomerBonuses();
    await loadCustomerAddresses();
    notifyListeners();
    return customer;
  }

  Future<Customer> loginCustomer({
    required String phone,
    required String password,
  }) async {
    final customer = await _api.loginCustomer(phone: phone, password: password);
    _customer = customer;
    setAuthorized(true);
    await loadCustomerBonuses();
    await loadCustomerAddresses();
    notifyListeners();
    return customer;
  }

  Future<Address> addAddress(AddressPayload payload) async {
    final customerId = _customer?.id ?? 0;
    if (customerId == 0) {
      throw StateError('Customer not registered');
    }
    final address = await _api.addAddress(customerId, payload);
    _addresses = [..._addresses, address];
    notifyListeners();
    return address;
  }

  Future<OrderCreated> createOrder(OrderCreatePayload payload) async {
    return _api.createOrder(payload);
  }

  void setHasUnreadNotifications(bool value) {
    if (_hasUnreadNotifications == value) return;
    _hasUnreadNotifications = value;
    notifyListeners();
  }

  void setAuthorized(bool value) {
    if (_isAuthorized == value) return;
    _isAuthorized = value;
    if (!value) {
      _customer = null;
      _addresses = const [];
      _bonusBalance = null;
      _orders = const [];
    }
    notifyListeners();
  }

  Future<void> _restoreInitialCache() async {
    await _restoreLocalNotifications();
    final raw = await AppPreferences.getInitialCache();
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      final banners = json['banners'];
      final categories = json['categories'];
      final products = json['products'];
      final topProducts = json['topProducts'];
      final settings = json['settings'];
      final pickupPoints = json['pickupPoints'];
      _banners = _decodeList(banners, BannerItem.fromJson);
      _categories = _decodeList(categories, CategoryItem.fromJson);
      _products = _decodeList(products, api.ProductItem.fromJson);
      _topProducts = _decodeList(topProducts, TopProductItem.fromJson);
      if (settings is Map<String, dynamic>) {
        _settings = AppSettings.fromJson(settings);
      }
      _pickupPoints = _decodeList(pickupPoints, PickupPoint.fromJson);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persistInitialCache() async {
    final payload = jsonEncode({
      'banners': _banners.map(_bannerToJson).toList(growable: false),
      'categories':
          _categories.map(_categoryToJson).toList(growable: false),
      'products': _products.map(_productToJson).toList(growable: false),
      'topProducts':
          _topProducts.map(_topProductToJson).toList(growable: false),
      'settings': _settings == null ? null : _settingsToJson(_settings!),
      'pickupPoints':
          _pickupPoints.map(_pickupPointToJson).toList(growable: false),
    });
    await AppPreferences.setInitialCache(payload);
  }

  Future<void> _restoreCustomerCache(int customerId) async {
    final raw = await AppPreferences.getCustomerCache();
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      if (json['customerId'] != customerId) return;
      final customer = json['customer'];
      final bonuses = json['bonuses'];
      final addresses = json['addresses'];
      final orders = json['orders'];
      if (customer is Map<String, dynamic>) {
        _customer = Customer.fromProfileJson(customer);
      }
      if (bonuses is Map<String, dynamic>) {
        _bonusBalance = BonusBalance.fromJson(bonuses);
      }
      _addresses = _decodeList(addresses, Address.fromJson);
      _orders = _decodeList(orders, OrderHistory.fromJson);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persistCustomerCache(int customerId) async {
    final payload = jsonEncode({
      'customerId': customerId,
      'customer': _customer == null
          ? null
          : {
              'id': _customer!.id,
              'name': _customer!.name,
              'phone': _customer!.phone,
            },
      'bonuses': _bonusBalance == null
          ? null
          : {
              'balance': _bonusBalance!.balance,
              'transactions': _bonusBalance!.transactions
                  .map(
                    (t) => {
                      'id': t.id,
                      'delta': t.delta,
                      'balance_after': t.balanceAfter,
                      'reason': t.reason,
                      'order_id': t.orderId,
                      'created_at': t.createdAt?.toIso8601String(),
                    },
                  )
                  .toList(growable: false),
            },
      'addresses': _addresses
          .map(
            (a) => {
              'id': a.id,
              'customer_id': a.customerId,
              'label': a.label,
              'address_line': a.addressLine,
              'comment': a.comment,
              'is_default': a.isDefault ? 1 : 0,
            },
          )
          .toList(growable: false),
      'orders': _orders
          .map(
            (o) => {
              'id': o.id,
              'customer_id': o.customerId,
              'customer_address_id': o.addressId,
              'total_amount': o.totalAmount,
              'status': o.status,
              'comment': o.comment,
              'bonus_used': o.bonusUsed,
              'bonus_earned': o.bonusEarned,
              'created_at': o.createdAt?.toIso8601String(),
              'items': o.items
                  .map(
                    (i) => {
                      'product_id': i.productId,
                      'title_ru': i.titleRu,
                      'title_uz': i.titleUz,
                      'price': i.price,
                      'quantity': i.quantity,
                      'total': i.total,
                    },
                  )
                  .toList(growable: false),
              'courier': o.courier == null
                  ? null
                  : {
                      'id': o.courier!.id,
                      'name': o.courier!.name,
                      'phone': o.courier!.phone,
                      'car_number': o.courier!.carNumber,
                    },
            },
          )
          .toList(growable: false),
    });
    await AppPreferences.setCustomerCache(payload);
  }

  List<T> _decodeList<T>(
    Object? value,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (value is! List) return <T>[];
    return value
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(growable: false);
  }

  Map<String, dynamic> _bannerToJson(BannerItem item) => {
        'id': item.id,
        'title_ru': item.titleRu,
        'title_uz': item.titleUz,
        'image_url': item.imageUrl,
        'link_url': item.linkUrl,
        'sort_order': item.sortOrder,
        'is_active': item.isActive ? 1 : 0,
      };

  Map<String, dynamic> _categoryToJson(CategoryItem item) => {
        'id': item.id,
        'name_ru': item.nameRu,
        'name_uz': item.nameUz,
        'slug': item.slug,
        'image_url': item.imageUrl,
      };

  Map<String, dynamic> _productToJson(api.ProductItem item) => {
        'id': item.id,
        'category_id': item.categoryId,
        'title_ru': item.titleRu,
        'title_uz': item.titleUz,
        'price': item.price,
        'price_text_ru': item.priceTextRu,
        'price_text_uz': item.priceTextUz,
        'description_title_ru': item.descriptionTitleRu,
        'description_title_uz': item.descriptionTitleUz,
        'description_text_ru': item.descriptionTextRu,
        'description_text_uz': item.descriptionTextUz,
        'pricing_mode':
            item.pricingMode == api.ProductPricingMode.portion
                ? 'portion'
                : 'quantity',
        'stock': item.stock,
        'is_active': item.isActive ? 1 : 0,
        'images': item.images,
        'portionOptions': item.portionOptions
            .map(
              (o) => {
                'id': o.id,
                'label_ru': o.labelRu,
                'label_uz': o.labelUz,
                'price': o.price,
              },
            )
            .toList(growable: false),
      };

  Map<String, dynamic> _topProductToJson(TopProductItem item) => {
        'product_id': item.productId,
        'sort_order': item.sortOrder,
      };

  Map<String, dynamic> _settingsToJson(AppSettings settings) => {
        'cafe_name': settings.cafeName,
        'phone': settings.phone,
        'address': settings.address,
        'work_hours': settings.workHours,
        'delivery_fee': settings.deliveryFee,
        'min_order': settings.minOrder,
        'currency': settings.currency,
        'bonus_redeem_amount': settings.bonusRedeemAmount,
        'instagram': settings.instagram,
        'telegram': settings.telegram,
        'payment_card_enabled': settings.paymentCardEnabled ? 1 : 0,
        'payment_cash_enabled': settings.paymentCashEnabled ? 1 : 0,
        'card_payment_info_title': settings.cardPaymentInfoTitle,
        'card_payment_info_body': settings.cardPaymentInfoBody,
        'card_payment_info_title_ru': settings.cardPaymentInfoTitleRu,
        'card_payment_info_title_uz': settings.cardPaymentInfoTitleUz,
        'card_payment_info_title_en': settings.cardPaymentInfoTitleEn,
        'card_payment_info_body_ru': settings.cardPaymentInfoBodyRu,
        'card_payment_info_body_uz': settings.cardPaymentInfoBodyUz,
        'card_payment_info_body_en': settings.cardPaymentInfoBodyEn,
      };

  Map<String, dynamic> _notificationToJson(NotificationItem item) => {
        'id': item.id,
        'title_ru': item.titleRu,
        'title_uz': item.titleUz,
        'body_ru': item.bodyRu,
        'body_uz': item.bodyUz,
        'image_url': item.imageUrl,
        'created_at': item.createdAt?.toIso8601String(),
        'is_read': item.isRead ? 1 : 0,
      };

  Future<void> _restoreLocalNotifications() async {
    final raw = await AppPreferences.getLocalNotifications();
    if (raw == null || raw.isEmpty) {
      _notifications = const [];
      _hasUnreadNotifications = false;
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      _notifications = decoded
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList(growable: false);
      _hasUnreadNotifications =
          _notifications.any((n) => n.isRead == false);
    } catch (_) {}
  }

  Future<void> _persistLocalNotifications() async {
    final payload = jsonEncode(
      _notifications.map(_notificationToJson).toList(growable: false),
    );
    await AppPreferences.setLocalNotifications(payload);
  }

  Map<String, dynamic> _pickupPointToJson(PickupPoint item) => {
        'id': item.id,
        'title': item.title,
        'address': item.address,
        'phone': item.phone,
        'work_hours': item.workHours,
        'lat': item.lat,
        'lng': item.lng,
      };

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setCartHasItems(bool value) {
    final next = value ? 1 : 0;
    setCartQty('__legacy__', next);
  }

  void addCartItem([int delta = 1]) {
    addProduct('__legacy__', delta);
  }

  void removeCartItem([int delta = 1]) {
    removeProduct('__legacy__', delta);
  }

  void clearCart() {
    if (_cartQuantities.isEmpty) return;
    _cartQuantities.clear();
    _cartMeta.clear();
    notifyListeners();
  }

  int cartQty(String productId) => _cartQuantities[productId] ?? 0;

  void addProduct(String productId, [int delta = 1, CartItemMeta? meta]) {
    if (productId.trim().isEmpty) return;
    if (delta <= 0) return;
    if (meta != null) _cartMeta[productId] = meta;
    final next = cartQty(productId) + delta;
    _cartQuantities[productId] = next;
    notifyListeners();
  }

  void removeProduct(String productId, [int delta = 1]) {
    if (productId.trim().isEmpty) return;
    if (delta <= 0) return;
    final next = cartQty(productId) - delta;
    if (next <= 0) {
      _cartQuantities.remove(productId);
      _cartMeta.remove(productId);
    } else {
      _cartQuantities[productId] = next;
    }
    notifyListeners();
  }

  void setCartQty(String productId, int qty) {
    if (productId.trim().isEmpty) return;
    final next = qty < 0 ? 0 : qty;
    if (next == 0) {
      if (_cartQuantities.remove(productId) == null) return;
    } else {
      if (_cartQuantities[productId] == next) return;
      _cartQuantities[productId] = next;
    }
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
