import '../models/address.dart';
import '../models/banner.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/bonus.dart';
import '../models/notification_item.dart';
import '../models/order.dart';
import '../models/pickup_point.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../models/top_product.dart';
import 'api_client.dart';

class ApiRepository {
  ApiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<BannerItem>> fetchBanners() async {
    final json = await _client.getJson('/api/public/banners');
    final items = _asList(json['items']);
    return items
        .map(BannerItem.fromJson)
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<List<CategoryItem>> fetchCategories() async {
    final json = await _client.getJson('/api/public/categories');
    final items = _asList(json['items']);
    return items.map(CategoryItem.fromJson).toList();
  }

  Future<List<ProductItem>> fetchProducts() async {
    final json = await _client.getJson('/api/public/products');
    final items = _asList(json['items']);
    return items
        .map(ProductItem.fromJson)
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<List<ProductItem>> fetchProductsByCategory(int categoryId) async {
    final json =
        await _client.getJson('/api/public/categories/$categoryId/products');
    final items = _asList(json['items']);
    return items
        .map(ProductItem.fromJson)
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<List<TopProductItem>> fetchTopProducts() async {
    final json = await _client.getJson('/api/public/top-products');
    final items = _asList(json['items']);
    return items.map(TopProductItem.fromJson).toList();
  }

  Future<AppSettings> fetchSettings() async {
    final json = await _client.getJson('/api/public/settings');
    final item = json['item'];
    if (item is! Map<String, dynamic>) {
      throw ApiException(200, 'Invalid settings payload');
    }
    return AppSettings.fromJson(item);
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final json = await _client.getJson('/api/public/notifications');
    final items = _asList(json['items']);
    return items.map(NotificationItem.fromJson).toList(growable: false);
  }

  Future<List<PickupPoint>> fetchPickupPoints() async {
    final json = await _client.getJson('/api/public/pickup-points');
    final items = _asList(json['items']);
    return items.map(PickupPoint.fromJson).toList(growable: false);
  }

  Future<Customer> fetchCustomerProfile(int customerId) async {
    final json =
        await _client.getJson('/api/public/customers/$customerId/profile');
    final item = json['item'];
    if (item is! Map<String, dynamic>) {
      throw ApiException(200, 'Invalid profile payload');
    }
    return Customer.fromProfileJson(item);
  }

  Future<Customer> updateCustomerProfile(
    int customerId, {
    required String name,
    required String phone,
  }) async {
    final json = await _client.patchJson(
      '/api/public/customers/$customerId/profile',
      {'name': name, 'phone': phone},
    );
    final item = json['item'];
    if (item is! Map<String, dynamic>) {
      throw ApiException(200, 'Invalid profile payload');
    }
    return Customer.fromProfileJson(item);
  }

  Future<List<OrderHistory>> fetchCustomerOrders(int customerId) async {
    final json =
        await _client.getJson('/api/public/customers/$customerId/orders');
    final items = _asList(json['items']);
    return items.map(OrderHistory.fromJson).toList(growable: false);
  }

  Future<BonusBalance> fetchCustomerBonuses(int customerId) async {
    final json =
        await _client.getJson('/api/public/customers/$customerId/bonuses');
    return BonusBalance.fromJson(json);
  }

  Future<Customer> registerCustomer(CustomerRegistration payload) async {
    final json =
        await _client.postJson('/api/public/customers', payload.toJson());
    return Customer.fromRegistrationResponse(payload, json);
  }

  Future<Customer> loginCustomer({
    required String phone,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/public/auth/login',
      {'phone': phone, 'password': password},
    );
    return Customer.fromLoginJson(json);
  }

  Future<List<Address>> fetchCustomerAddresses(int customerId) async {
    final json =
        await _client.getJson('/api/public/customers/$customerId/addresses');
    final items = _asList(json['items']);
    return items.map(Address.fromJson).toList(growable: false);
  }

  Future<Address> addAddress(int customerId, AddressPayload payload) async {
    final json = await _client.postJson(
      '/api/public/customers/$customerId/addresses',
      payload.toJson(),
    );
    return Address.fromCreateResponse(payload, json, customerId);
  }

  Future<OrderCreated> createOrder(OrderCreatePayload payload) async {
    final json =
        await _client.postJson('/api/public/orders', payload.toJson());
    return OrderCreated.fromJson(json);
  }

  List<Map<String, dynamic>> _asList(Object? value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
}
