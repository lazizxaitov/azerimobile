class AppSettings {
  const AppSettings({
    required this.cafeName,
    required this.phone,
    required this.address,
    required this.workHours,
    required this.deliveryFee,
    required this.minOrder,
    required this.currency,
    required this.bonusRedeemAmount,
    required this.instagram,
    required this.telegram,
  });

  final String cafeName;
  final String phone;
  final String address;
  final String workHours;
  final int deliveryFee;
  final int minOrder;
  final String currency;
  final int bonusRedeemAmount;
  final String? instagram;
  final String? telegram;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      cafeName: _asString(json['cafe_name']),
      phone: _asString(json['phone']),
      address: _asString(json['address']),
      workHours: _asString(json['work_hours']),
      deliveryFee: _asInt(json['delivery_fee']),
      minOrder: _asInt(json['min_order']),
      currency: _asString(json['currency']),
      bonusRedeemAmount: _asInt(json['bonus_redeem_amount']),
      instagram: _asNullableString(json['instagram']),
      telegram: _asNullableString(json['telegram']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}
