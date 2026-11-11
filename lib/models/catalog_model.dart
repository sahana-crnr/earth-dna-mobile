class CatalogBrand {
  final String id;
  final String name;
  final String slug;

  CatalogBrand({required this.id, required this.name, required this.slug});

  factory CatalogBrand.fromJson(Map<String, dynamic> json) {
    return CatalogBrand(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class CatalogSize {
  final String id;
  final String label;
  final String system;
  final String? brandId;

  CatalogSize({
    required this.id,
    required this.label,
    this.system = 'US',
    this.brandId,
  });

  factory CatalogSize.fromJson(Map<String, dynamic> json) {
    return CatalogSize(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      system: json['system'] as String? ?? 'US',
      brandId: json['brandId'] as String?,
    );
  }
}

class CatalogShoeType {
  final String id;
  final String name;
  final String slug;

  CatalogShoeType({required this.id, required this.name, required this.slug});

  factory CatalogShoeType.fromJson(Map<String, dynamic> json) {
    return CatalogShoeType(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class MarketplacePreviewItem {
  final String id;
  final String title;
  final String price;
  final String? asset;
  final String? imageUrl;
  final String? brand;

  const MarketplacePreviewItem({
    this.id = '',
    required this.title,
    required this.price,
    this.asset,
    this.imageUrl,
    this.brand,
  });

  factory MarketplacePreviewItem.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as String? ?? '';
    final model = json['model'] as String? ?? '';
    final title = json['title'] as String? ??
        (brand.isNotEmpty ? '$brand · $model' : 'Footwear');
    return MarketplacePreviewItem(
      id: json['id'] as String? ?? '',
      title: title.trim(),
      price: json['price'] as String? ??
          (json['msrp'] != null ? '\$${json['msrp']}' : '\$35'),
      imageUrl: json['imageUrl'] as String?,
      brand: brand,
    );
  }
}

