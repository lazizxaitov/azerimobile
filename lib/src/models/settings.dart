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
    required this.cardPaymentUnavailableTitle,
    required this.cardPaymentUnavailableBody,
    required this.cardPaymentUnavailableTitleRu,
    required this.cardPaymentUnavailableTitleUz,
    required this.cardPaymentUnavailableTitleEn,
    required this.cardPaymentUnavailableBodyRu,
    required this.cardPaymentUnavailableBodyUz,
    required this.cardPaymentUnavailableBodyEn,
    required this.cardPaymentUnavailableCardNumber,
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
  final String? cardPaymentUnavailableTitle;
  final String? cardPaymentUnavailableBody;
  final String? cardPaymentUnavailableTitleRu;
  final String? cardPaymentUnavailableTitleUz;
  final String? cardPaymentUnavailableTitleEn;
  final String? cardPaymentUnavailableBodyRu;
  final String? cardPaymentUnavailableBodyUz;
  final String? cardPaymentUnavailableBodyEn;
  final String? cardPaymentUnavailableCardNumber;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final cardPaymentText =
        _asNullableString(json['card_payment_text']) ??
            _asNullableString(json['card_payment_unavailable_body']) ??
            _asNullableString(json['card_payment_unavailable_text']) ??
            _asNullableString(json['card_payment_disabled_body']) ??
            _asNullableString(json['card_payment_disabled_text']) ??
            _asNullableString(json['card_payment_off_body']) ??
            _asNullableString(json['card_payment_off_text']);
    final extractedCardNumber = _extractCardNumber(cardPaymentText);
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
      cardPaymentUnavailableTitle: _asNullableString(
        json['card_payment_unavailable_title'] ??
            json['card_payment_disabled_title'] ??
            json['card_payment_off_title'],
      ),
      cardPaymentUnavailableBody: cardPaymentText,
      cardPaymentUnavailableTitleRu:
          _asNullableString(json['card_payment_unavailable_title_ru']) ??
              _asNullableString(json['card_payment_disabled_title_ru']) ??
              _asNullableString(json['card_payment_off_title_ru']),
      cardPaymentUnavailableTitleUz:
          _asNullableString(json['card_payment_unavailable_title_uz']) ??
              _asNullableString(json['card_payment_disabled_title_uz']) ??
              _asNullableString(json['card_payment_off_title_uz']),
      cardPaymentUnavailableTitleEn:
          _asNullableString(json['card_payment_unavailable_title_en']) ??
              _asNullableString(json['card_payment_disabled_title_en']) ??
              _asNullableString(json['card_payment_off_title_en']),
      cardPaymentUnavailableBodyRu:
          _asNullableString(json['card_payment_unavailable_body_ru']) ??
              _asNullableString(json['card_payment_unavailable_text_ru']) ??
              _asNullableString(json['card_payment_disabled_body_ru']) ??
              _asNullableString(json['card_payment_disabled_text_ru']) ??
              _asNullableString(json['card_payment_off_body_ru']) ??
              _asNullableString(json['card_payment_off_text_ru']),
      cardPaymentUnavailableBodyUz:
          _asNullableString(json['card_payment_unavailable_body_uz']) ??
              _asNullableString(json['card_payment_unavailable_text_uz']) ??
              _asNullableString(json['card_payment_disabled_body_uz']) ??
              _asNullableString(json['card_payment_disabled_text_uz']) ??
              _asNullableString(json['card_payment_off_body_uz']) ??
              _asNullableString(json['card_payment_off_text_uz']),
      cardPaymentUnavailableBodyEn:
          _asNullableString(json['card_payment_unavailable_body_en']) ??
              _asNullableString(json['card_payment_unavailable_text_en']) ??
              _asNullableString(json['card_payment_disabled_body_en']) ??
              _asNullableString(json['card_payment_disabled_text_en']) ??
              _asNullableString(json['card_payment_off_body_en']) ??
              _asNullableString(json['card_payment_off_text_en']),
      cardPaymentUnavailableCardNumber: _asNullableString(
        json['card_payment_unavailable_card_number'] ??
            json['card_payment_card_number'] ??
            json['card_number'],
      ) ??
          extractedCardNumber,
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

  String? cardPaymentUnavailableTitleForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    final localized = switch (code) {
      'ru' => cardPaymentUnavailableTitleRu,
      'uz' => cardPaymentUnavailableTitleUz,
      'en' => cardPaymentUnavailableTitleEn,
      _ => null,
    };
    return localized ?? cardPaymentUnavailableTitle;
  }

  String? cardPaymentUnavailableBodyForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    final localized = switch (code) {
      'ru' => cardPaymentUnavailableBodyRu,
      'uz' => cardPaymentUnavailableBodyUz,
      'en' => cardPaymentUnavailableBodyEn,
      _ => null,
    };
    return localized ?? cardPaymentUnavailableBody;
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

String? _extractCardNumber(String? text) {
  if (text == null) return null;
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length < 12) return null;
  // Preserve spaces grouping if present; otherwise group by 4.
  final hasSpaces = RegExp(r'\\s').hasMatch(trimmed);
  if (hasSpaces) return trimmed;
  final grouped = digitsOnly.replaceAllMapped(
    RegExp(r'.{1,4}'),
    (m) => '${m.group(0)} ',
  ).trimRight();
  return grouped;
}
