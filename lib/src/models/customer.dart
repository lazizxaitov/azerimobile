class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.birthDate,
  });

  final int id;
  final String name;
  final String phone;
  final String password;
  final String? birthDate; // YYYY-MM-DD

  factory Customer.fromRegistrationResponse(
    CustomerRegistration payload,
    Map<String, dynamic> json,
  ) {
    return Customer(
      id: _asInt(json['id']),
      name: payload.name,
      phone: payload.phone,
      password: payload.password,
      birthDate: payload.birthDate,
    );
  }

  factory Customer.fromProfileJson(Map<String, dynamic> json) {
    return Customer(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      password: '',
      birthDate: _asNullableString(json['birthDate'] ?? json['birth_date']),
    );
  }

  factory Customer.fromLoginJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is Map<String, dynamic>) {
      return Customer.fromProfileJson(item);
    }
    return Customer(id: 0, name: '', phone: '', password: '', birthDate: null);
  }
}

class CustomerRegistration {
  const CustomerRegistration({
    required this.name,
    required this.phone,
    required this.password,
    required this.birthDate,
  });

  final String name;
  final String phone;
  final String password;
  final String birthDate; // YYYY-MM-DD

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'phone': phone,
        'password': password,
        'birthDate': birthDate,
      };
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty) return null;
  return text;
}
