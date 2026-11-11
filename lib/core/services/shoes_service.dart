import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../../models/shoe_model.dart';

class ShoesService {
  final ApiClient _api = ApiClient();

  Future<List<ShoeCardModel>> getShoes({
    List<String>? actionTaken,
    List<String>? condition,
    List<String>? recommendedAction,
    List<String>? resaleBucket,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (actionTaken != null && actionTaken.isNotEmpty) {
      queryParams['actionTaken'] = actionTaken.join(',');
    }
    if (condition != null && condition.isNotEmpty) {
      queryParams['condition'] = condition.join(',');
    }
    if (recommendedAction != null && recommendedAction.isNotEmpty) {
      queryParams['recommendedAction'] = recommendedAction.join(',');
    }
    if (resaleBucket != null && resaleBucket.isNotEmpty) {
      queryParams['resaleBucket'] = resaleBucket.join(',');
    }

    final response = await _api.dio.get(
      ApiEndpoints.shoes,
      queryParameters: queryParams,
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    final items = data['items'] as List? ?? [];
    return items.map((e) => ShoeCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ShoeSummaryModel> getSummary() async {
    final response = await _api.dio.get(ApiEndpoints.shoesSummary);
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ShoeSummaryModel.fromJson(data);
  }

  Future<ShoeProfileModel> getShoeDetail(String shoeId) async {
    final response = await _api.dio.get(ApiEndpoints.shoeDetail(shoeId));
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ShoeProfileModel.fromJson(data);
  }

  Future<ShoeProfileModel> updateShoe(String shoeId, Map<String, dynamic> updates) async {
    final response = await _api.dio.patch(
      ApiEndpoints.shoeDetail(shoeId),
      data: updates,
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ShoeProfileModel.fromJson(data);
  }

  Future<void> deleteShoe(String shoeId) async {
    await _api.dio.delete(ApiEndpoints.shoeDetail(shoeId));
  }

  Future<Map<String, dynamic>> shareShoe(String shoeId) async {
    final response = await _api.dio.post(ApiEndpoints.shareShoe(shoeId));
    return _api.extractData<Map<String, dynamic>>(response);
  }

  Future<Map<String, dynamic>> rescanShoe(String shoeId) async {
    final response = await _api.dio.post(ApiEndpoints.rescanShoe(shoeId));
    return _api.extractData<Map<String, dynamic>>(response);
  }

  Future<void> sendConditionFeedback({
    required String shoeId,
    required String code,
    required String reason,
  }) async {
    await _api.dio.post(
      ApiEndpoints.conditionFeedback(shoeId),
      data: {
        'suggestedConditionCode': code,
        'reason': reason,
      },
    );
  }
}

