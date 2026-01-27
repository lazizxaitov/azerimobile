class PortionOptionItem {
  const PortionOptionItem({
    required this.id,
    required this.labelRu,
    required this.labelUz,
    required this.price,
  });

  final int id;
  final String labelRu;
  final String labelUz;
  final int price;

  factory PortionOptionItem.fromJson(Map<String, dynamic> json) {
    return PortionOptionItem(
      id: _asInt(json['id']),
      labelRu: _asString(json['label_ru']),
      labelUz: _asString(json['label_uz']),
      price: _asInt(json['price']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';
