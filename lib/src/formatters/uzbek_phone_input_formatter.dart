import 'package:flutter/services.dart';

class UzbekPhoneInputFormatter extends TextInputFormatter {
  UzbekPhoneInputFormatter({this.countryCode = '998'});

  final String countryCode;

  static const _maxNationalDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = _digitsOnly(newValue.text);
    if (digits.isEmpty) digits = countryCode;
    if (!digits.startsWith(countryCode)) {
      digits = countryCode + digits;
    }

    final maxTotal = countryCode.length + _maxNationalDigits;
    if (digits.length > maxTotal) digits = digits.substring(0, maxTotal);

    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    final cc = countryCode;
    final national = digits.length > cc.length ? digits.substring(cc.length) : '';

    final b = StringBuffer('+$cc');
    b.write(' ');

    if (national.isEmpty) return b.toString();

    final p1 = national.substring(0, national.length.clamp(0, 2));
    b.write(p1);
    if (national.length <= 2) return b.toString();

    b.write(' ');
    final p2 = national.substring(2, national.length.clamp(2, 5));
    b.write(p2);
    if (national.length <= 5) return b.toString();

    b.write(' ');
    final p3 = national.substring(5, national.length.clamp(5, 7));
    b.write(p3);
    if (national.length <= 7) return b.toString();

    b.write(' ');
    final p4 = national.substring(7, national.length.clamp(7, 9));
    b.write(p4);
    return b.toString();
  }

  String _digitsOnly(String input) {
    final b = StringBuffer();
    for (final c in input.runes) {
      final ch = String.fromCharCode(c);
      if (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57) b.write(ch);
    }
    return b.toString();
  }
}

