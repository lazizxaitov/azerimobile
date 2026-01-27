import '../api/api_config.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.nameRu,
    required this.nameUz,
    required this.slug,
    required this.imageUrl,
  });

  final int id;
  final String nameRu;
  final String nameUz;
  final String slug;
  final String imageUrl;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: _asInt(json['id']),
      nameRu: _asString(json['name_ru']),
      nameUz: _asString(json['name_uz']),
      slug: _asString(json['slug']),
      imageUrl: ApiConfig.resolveImageUrl(_asString(json['image_url'])),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';
