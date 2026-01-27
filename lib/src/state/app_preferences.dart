import 'package:shared_preferences/shared_preferences.dart';

final class AppPreferences {
  AppPreferences._();

  static const _languageKey = 'app_language';
  static const _authorizedKey = 'app_authorized';
  static const _customerIdKey = 'customer_id';
  static const _cacheInitialKey = 'cache_initial_v1';
  static const _cacheCustomerKey = 'cache_customer_v1';
  static const _notificationsClearedAtKey = 'notifications_cleared_at';

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<bool> getAuthorized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authorizedKey) ?? false;
  }

  static Future<void> setAuthorized(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authorizedKey, value);
  }

  static Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_customerIdKey);
  }

  static Future<void> setCustomerId(int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_customerIdKey);
    } else {
      await prefs.setInt(_customerIdKey, value);
    }
  }

  static Future<String?> getInitialCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheInitialKey);
  }

  static Future<void> setInitialCache(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheInitialKey, value);
  }

  static Future<String?> getCustomerCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheCustomerKey);
  }

  static Future<void> setCustomerCache(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheCustomerKey, value);
  }

  static Future<DateTime?> getNotificationsClearedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_notificationsClearedAtKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static Future<void> setNotificationsClearedAt(DateTime? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_notificationsClearedAtKey);
    } else {
      await prefs.setInt(_notificationsClearedAtKey, value.millisecondsSinceEpoch);
    }
  }
}
