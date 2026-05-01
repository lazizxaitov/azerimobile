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
    required this.paymentCardEnabled,
    required this.paymentCashEnabled,
    required this.cardPaymentInfoTitle,
    required this.cardPaymentInfoBody,
    required this.cardPaymentInfoTitleRu,
    required this.cardPaymentInfoTitleUz,
    required this.cardPaymentInfoTitleEn,
    required this.cardPaymentInfoBodyRu,
    required this.cardPaymentInfoBodyUz,
    required this.cardPaymentInfoBodyEn,
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
  final bool paymentCardEnabled;
  final bool paymentCashEnabled;
  final String? cardPaymentInfoTitle;
  final String? cardPaymentInfoBody;
  final String? cardPaymentInfoTitleRu;
  final String? cardPaymentInfoTitleUz;
  final String? cardPaymentInfoTitleEn;
  final String? cardPaymentInfoBodyRu;
  final String? cardPaymentInfoBodyUz;
  final String? cardPaymentInfoBodyEn;

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
      paymentCardEnabled: _asBool(
        json['payment_card_enabled'] ??
            json['pay_by_card_enabled'] ??
            json['card_payment_enabled'],
        fallback: true,
      ),
      paymentCashEnabled: _asBool(
        json['payment_cash_enabled'] ??
            json['pay_by_cash_enabled'] ??
            json['cash_payment_enabled'],
        fallback: true,
      ),
      cardPaymentInfoTitle: _asNullableString(
        json['card_payment_info_title'] ?? json['card_payment_title'],
      ),
      cardPaymentInfoBody: _asNullableString(
        json['card_payment_info_body'] ??
            json['card_payment_info_text'] ??
            json['card_payment_text'],
      ),
      cardPaymentInfoTitleRu:
          _asNullableString(json['card_payment_info_title_ru']),
      cardPaymentInfoTitleUz:
          _asNullableString(json['card_payment_info_title_uz']),
      cardPaymentInfoTitleEn:
          _asNullableString(json['card_payment_info_title_en']),
      cardPaymentInfoBodyRu:
          _asNullableString(json['card_payment_info_body_ru']) ??
              _asNullableString(json['card_payment_info_text_ru']),
      cardPaymentInfoBodyUz:
          _asNullableString(json['card_payment_info_body_uz']) ??
              _asNullableString(json['card_payment_info_text_uz']),
      cardPaymentInfoBodyEn:
          _asNullableString(json['card_payment_info_body_en']) ??
              _asNullableString(json['card_payment_info_text_en']),
    );
  }

  String? cardPaymentInfoTitleForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    final localized = switch (code) {
      'ru' => cardPaymentInfoTitleRu,
      'uz' => cardPaymentInfoTitleUz,
      'en' => cardPaymentInfoTitleEn,
      _ => null,
    };
    return localized ?? cardPaymentInfoTitle;
  }

  String? cardPaymentInfoBodyForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    final localized = switch (code) {
      'ru' => cardPaymentInfoBodyRu,
      'uz' => cardPaymentInfoBodyUz,
      'en' => cardPaymentInfoBodyEn,
      _ => null,
    };
    return localized ?? cardPaymentInfoBody;
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _asBool(Object? value, {required bool fallback}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return fallback;
  if (text == '1' || text == 'true' || text == 'yes') return true;
  if (text == '0' || text == 'false' || text == 'no') return false;
  return fallback;
}
