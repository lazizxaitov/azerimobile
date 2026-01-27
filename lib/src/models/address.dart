class Address {
  const Address({
    required this.id,
    required this.customerId,
    required this.label,
    required this.addressLine,
    required this.comment,
    required this.isDefault,
  });

  final int id;
  final int customerId;
  final String label;
  final String addressLine;
  final String? comment;
  final bool isDefault;

  factory Address.fromCreateResponse(
    AddressPayload payload,
    Map<String, dynamic> json,
    int customerId,
  ) {
    return Address(
      id: _asInt(json['id']),
      customerId: customerId,
      label: payload.label,
      addressLine: payload.addressLine,
      comment: payload.comment,
      isDefault: payload.isDefault,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _asInt(json['id']),
      customerId: _asInt(json['customer_id']),
      label: _asString(json['label']),
      addressLine: _asString(json['address_line']),
      comment: _asNullableString(json['comment']),
      isDefault: _asBool(json['is_default']),
    );
  }
}

class AddressPayload {
  const AddressPayload({
    required this.label,
    required this.addressLine,
    this.comment,
    this.isDefault = false,
  });

  final String label;
  final String addressLine;
  final String? comment;
  final bool isDefault;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'addressLine': addressLine,
        'comment': comment,
        'isDefault': isDefault,
      };
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _asBool(Object? value) => value == true || value == 1;
