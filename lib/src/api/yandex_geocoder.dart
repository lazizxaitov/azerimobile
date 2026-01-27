import 'dart:convert';

import 'package:http/http.dart' as http;

import 'yandex_config.dart';

class YandexGeocoder {
  const YandexGeocoder();

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
    String language = 'ru_RU',
  }) async {
    final uri = Uri.https('geocode-maps.yandex.ru', '/1.x', {
      'apikey': YandexConfig.geocoderKey,
      'geocode': '$longitude,$latitude',
      'format': 'json',
      'lang': language,
      'results': '1',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final responseNode = decoded['response'];
    if (responseNode is! Map<String, dynamic>) return null;
    final collection = responseNode['GeoObjectCollection'];
    if (collection is! Map<String, dynamic>) return null;
    final featureMember = collection['featureMember'];
    if (featureMember is! List || featureMember.isEmpty) return null;
    final first = featureMember.first;
    if (first is! Map<String, dynamic>) return null;
    final geoObject = first['GeoObject'];
    if (geoObject is! Map<String, dynamic>) return null;
    final meta = geoObject['metaDataProperty'];
    if (meta is! Map<String, dynamic>) return null;
    final geocoderMeta = meta['GeocoderMetaData'];
    if (geocoderMeta is! Map<String, dynamic>) return null;
    final text = geocoderMeta['text'];
    if (text is! String || text.trim().isEmpty) return null;
    return text.trim();
  }
}
