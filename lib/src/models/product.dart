import '../api/api_config.dart';
import 'portion_option.dart';

enum ProductPricingMode { quantity, portion }

class ProductItem {
  const ProductItem({
    required this.id,
    required this.categoryId,
    required this.titleRu,
    required this.titleUz,
    required this.price,
    required this.priceTextRu,
    required this.priceTextUz,
    required this.descriptionTitleRu,
    required this.descriptionTitleUz,
    required this.descriptionTextRu,
    required this.descriptionTextUz,
    required this.pricingMode,
    required this.stock,
    required this.isActive,
    required this.images,
    required this.portionOptions,
  });

  final int id;
  final int categoryId;
  final String titleRu;
  final String titleUz;
  final int price;
  final String? priceTextRu;
  final String? priceTextUz;
  final String descriptionTitleRu;
  final String descriptionTitleUz;
  final String descriptionTextRu;
  final String descriptionTextUz;
  final ProductPricingMode pricingMode;
  final int stock;
  final bool isActive;
  final List<String> images;
  final List<PortionOptionItem> portionOptions;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final images = _asList(json['images'])
        .map((item) => ApiConfig.resolveImageUrl(item))
        .toList(growable: false);
    final portionList = _asMapList(json['portionOptions']);
    return ProductItem(
      id: _asInt(json['id']),
      categoryId: _asInt(json['category_id']),
      titleRu: _asString(json['title_ru']),
      titleUz: _asString(json['title_uz']),
      price: _asInt(json['price']),
      priceTextRu: _asNullableString(json['price_text_ru']),
      priceTextUz: _asNullableString(json['price_text_uz']),
      descriptionTitleRu: _asString(json['description_title_ru']),
      descriptionTitleUz: _asString(json['description_title_uz']),
      descriptionTextRu: _asString(json['description_text_ru']),
      descriptionTextUz: _asString(json['description_text_uz']),
      pricingMode: _parsePricingMode(_asString(json['pricing_mode'])),
      stock: _asInt(json['stock']),
      isActive: _asBool(json['is_active']),
      images: images,
      portionOptions:
          portionList.map(PortionOptionItem.fromJson).toList(growable: false),
    );
  }
}

ProductPricingMode _parsePricingMode(String value) {
  if (value.toLowerCase() == 'portion') return ProductPricingMode.portion;
  return ProductPricingMode.quantity;
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _asBool(Object? value) => value == true || value == 1;

List<String> _asList(Object? value) {
  if (value is! List) return <String>[];
  return value.map((e) => e.toString()).toList(growable: false);
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
