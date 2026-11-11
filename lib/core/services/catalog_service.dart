import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../../models/catalog_model.dart';

class CatalogService {
  final ApiClient _api = ApiClient();

  Future<List<CatalogBrand>> getBrands({String query = ''}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.catalogBrands,
        queryParameters: query.isNotEmpty ? {'q': query} : null,
      );
      final data = _api.extractData<Map<String, dynamic>>(response);
      final items = data['items'] as List? ?? [];
      return items.map((e) => CatalogBrand.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CatalogSize>> getSizes({String? brandId}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.catalogSizes,
        queryParameters: brandId != null ? {'brandId': brandId} : null,
      );
      final data = _api.extractData<Map<String, dynamic>>(response);
      final items = data['items'] as List? ?? [];
      return items.map((e) => CatalogSize.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CatalogShoeType>> getShoeTypes() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.catalogCategories);
      final data = _api.extractData<Map<String, dynamic>>(response);
      final items = data['items'] as List? ?? [];
      return items.map((e) => CatalogShoeType.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MarketplacePreviewItem>> getMarketplacePreview() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.catalogPreview);
      final data = _api.extractData<Map<String, dynamic>>(response);
      final items = data['items'] as List? ?? [];
      return items
          .map((e) => MarketplacePreviewItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

