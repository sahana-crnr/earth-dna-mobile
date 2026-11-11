import 'package:flutter/material.dart';
import '../core/services/catalog_service.dart';
import '../core/services/shoes_service.dart';
import '../core/storage/token_storage.dart';
import '../models/catalog_model.dart';
import '../models/shoe_model.dart';

class ShoesProvider extends ChangeNotifier {
  final ShoesService _shoesService = ShoesService();
  final CatalogService _catalogService = CatalogService();

  List<ShoeCardModel> _shoes = [];
  List<MarketplacePreviewItem> _marketplaceItems = [];
  ShoeSummaryModel? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  List<String> _selectedActionTaken = [];
  List<String> _selectedCondition = [];
  List<String> _selectedRecommendedAction = [];
  List<String> _selectedResaleBucket = [];

  List<ShoeCardModel> get shoes => _shoes;
  List<MarketplacePreviewItem> get marketplaceItems => _marketplaceItems;
  ShoeSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get selectedActionTaken => _selectedActionTaken;
  List<String> get selectedCondition => _selectedCondition;
  List<String> get selectedRecommendedAction => _selectedRecommendedAction;
  List<String> get selectedResaleBucket => _selectedResaleBucket;

  int get activeFilterCount =>
      _selectedActionTaken.length +
      _selectedCondition.length +
      _selectedRecommendedAction.length +
      _selectedResaleBucket.length;

  Future<void> fetchShoesAndSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final marketplaceFuture = _catalogService.getMarketplacePreview();
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        // Unauthenticated visitor: display empty collection without 401 errors
        _shoes = [];
        _summary = null;
        _marketplaceItems = await marketplaceFuture;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final results = await Future.wait([
        _shoesService.getShoes(
          actionTaken: _selectedActionTaken,
          condition: _selectedCondition,
          recommendedAction: _selectedRecommendedAction,
          resaleBucket: _selectedResaleBucket,
        ),
        _shoesService.getSummary(),
        marketplaceFuture,
      ]);

      _shoes = results[0] as List<ShoeCardModel>;
      _summary = results[1] as ShoeSummaryModel;
      _marketplaceItems = results[2] as List<MarketplacePreviewItem>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilters({
    List<String>? actionTaken,
    List<String>? condition,
    List<String>? recommendedAction,
    List<String>? resaleBucket,
  }) {
    if (actionTaken != null) _selectedActionTaken = actionTaken;
    if (condition != null) _selectedCondition = condition;
    if (recommendedAction != null) _selectedRecommendedAction = recommendedAction;
    if (resaleBucket != null) _selectedResaleBucket = resaleBucket;

    fetchShoesAndSummary();
  }

  void resetFilters() {
    _selectedActionTaken = [];
    _selectedCondition = [];
    _selectedRecommendedAction = [];
    _selectedResaleBucket = [];
    fetchShoesAndSummary();
  }

  Future<ShoeProfileModel?> getShoeProfile(String shoeId) async {
    try {
      return await _shoesService.getShoeDetail(shoeId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteShoe(String shoeId) async {
    try {
      await _shoesService.deleteShoe(shoeId);
      _shoes.removeWhere((s) => s.id == shoeId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

