import '../api/api_config.dart';

class BannerItem {
  const BannerItem({
    required this.id,
    required this.titleRu,
    required this.titleUz,
    required this.imageUrl,
    required this.linkUrl,
    required this.sortOrder,
    required this.isActive,
  });

  final int id;
  final String titleRu;
  final String titleUz;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;
  final bool isActive;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: _asInt(json['id']),
      titleRu: _asString(json['title_ru']),
      titleUz: _asString(json['title_uz']),
      imageUrl: ApiConfig.resolveImageUrl(_asString(json['image_url'])),
      linkUrl: _asNullableString(json['link_url']),
      sortOrder: _asInt(json['sort_order']),
      isActive: _asBool(json['is_active']),
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

bool _asBool(Object? value) => value == true || value == 1;
