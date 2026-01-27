class OrderItemPayload {
  const OrderItemPayload({
    required this.productId,
    required this.titleRu,
    required this.titleUz,
    required this.price,
    required this.quantity,
  });

  final int productId;
  final String titleRu;
  final String titleUz;
  final int price;
  final int quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'titleRu': titleRu,
        'titleUz': titleUz,
        'price': price,
        'quantity': quantity,
      };
}

class OrderCreatePayload {
  const OrderCreatePayload({
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.addressId,
    this.addressLine,
    this.addressLabel,
    this.addressComment,
    this.comment,
    this.bonusUsed,
    required this.paymentMethod,
    required this.items,
  });

  final int? customerId;
  final String customerName;
  final String customerPhone;
  final int? addressId;
  final String? addressLine;
  final String? addressLabel;
  final String? addressComment;
  final String? comment;
  final int? bonusUsed;
  final String paymentMethod;
  final List<OrderItemPayload> items;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'addressId': addressId,
        'addressLine': addressLine,
      'addressLabel': addressLabel,
      'addressComment': addressComment,
      'comment': comment,
      'bonusUsed': bonusUsed,
      'paymentMethod': paymentMethod,
      'items': items.map((e) => e.toJson()).toList(growable: false),
    };
}

class OrderCreated {
  const OrderCreated({required this.id});

  final int id;

  factory OrderCreated.fromJson(Map<String, dynamic> json) {
    return OrderCreated(id: _asInt(json['id']));
  }
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.titleRu,
    required this.titleUz,
    required this.price,
    required this.quantity,
    required this.total,
  });

  final int productId;
  final String titleRu;
  final String titleUz;
  final int price;
  final int quantity;
  final int total;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: _asInt(json['product_id']),
      titleRu: _asString(json['title_ru']),
      titleUz: _asString(json['title_uz']),
      price: _asInt(json['price']),
      quantity: _asInt(json['quantity']),
      total: _asInt(json['total']),
    );
  }
}

class OrderHistory {
  const OrderHistory({
    required this.id,
    required this.customerId,
    required this.addressId,
    required this.totalAmount,
    required this.status,
    required this.comment,
    required this.bonusUsed,
    required this.bonusEarned,
    required this.createdAt,
    required this.items,
    required this.courier,
  });

  final int id;
  final int customerId;
  final int? addressId;
  final int totalAmount;
  final String status;
  final String? comment;
  final int bonusUsed;
  final int bonusEarned;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final CourierInfo? courier;

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final parsedItems = items is List
        ? items
            .whereType<Map<String, dynamic>>()
            .map(OrderItem.fromJson)
            .toList(growable: false)
        : <OrderItem>[];
    return OrderHistory(
      id: _asInt(json['id']),
      customerId: _asInt(json['customer_id']),
      addressId: _asNullableInt(json['customer_address_id']),
      totalAmount: _asInt(json['total_amount']),
      status: _asString(json['status']),
      comment: _asNullableString(json['comment']),
      bonusUsed: _asInt(json['bonus_used']),
      bonusEarned: _asInt(json['bonus_earned']),
      createdAt: _asDate(json['created_at']),
      items: parsedItems,
      courier: CourierInfo.fromJson(json['courier']),
    );
  }
}

class CourierInfo {
  const CourierInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.carNumber,
  });

  final int id;
  final String name;
  final String phone;
  final String carNumber;

  static CourierInfo? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return CourierInfo(
      id: _asInt(value['id']),
      name: _asString(value['name']),
      phone: _asString(value['phone']),
      carNumber: _asString(value['car_number']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

int? _asNullableInt(Object? value) => value is num ? value.toInt() : null;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
