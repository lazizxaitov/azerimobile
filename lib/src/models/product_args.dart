enum ProductPricingMode { quantity, portion }

class PortionOption {
  const PortionOption({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;
  final int price;
}

class ProductArgs {
  const ProductArgs({
    required this.id,
    required this.title,
    required this.price,
    required this.priceText,
    required this.descriptionTitle,
    required this.descriptionText,
    required this.mode,
    this.images = const [],
    this.portionOptions = const <PortionOption>[],
    this.titleRu,
    this.titleUz,
  });

  final String id;
  final String title;
  final int price;
  final String priceText;
  final String descriptionTitle;
  final String descriptionText;
  final ProductPricingMode mode;
  final List<String> images;
  final List<PortionOption> portionOptions;
  final String? titleRu;
  final String? titleUz;
}
