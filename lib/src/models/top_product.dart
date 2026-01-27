class TopProductItem {
  const TopProductItem({required this.productId, required this.sortOrder});

  final int productId;
  final int sortOrder;

  factory TopProductItem.fromJson(Map<String, dynamic> json) {
    return TopProductItem(
      productId: _asInt(json['product_id']),
      sortOrder: _asInt(json['sort_order']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;
