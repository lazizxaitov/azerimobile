class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
  });

  final int id;
  final String name;
  final String phone;
  final String password;

  factory Customer.fromRegistrationResponse(
    CustomerRegistration payload,
    Map<String, dynamic> json,
  ) {
    return Customer(
      id: _asInt(json['id']),
      name: payload.name,
      phone: payload.phone,
      password: payload.password,
    );
  }

  factory Customer.fromProfileJson(Map<String, dynamic> json) {
    return Customer(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      password: '',
    );
  }

  factory Customer.fromLoginJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is Map<String, dynamic>) {
      return Customer.fromProfileJson(item);
    }
    return Customer(id: 0, name: '', phone: '', password: '');
  }
}

class CustomerRegistration {
  const CustomerRegistration({
    required this.name,
    required this.phone,
    required this.password,
  });

  final String name;
  final String phone;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'phone': phone,
        'password': password,
      };
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';
