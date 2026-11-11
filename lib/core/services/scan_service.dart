import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../../models/scan_session_model.dart';

class ScanService {
  final ApiClient _api = ApiClient();

  Future<ScanSession> createSession() async {
    final response = await _api.dio.post(ApiEndpoints.scans, data: {});
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<ScanSession> getSession(String scanId) async {
    final response = await _api.dio.get(ApiEndpoints.scanDetail(scanId));
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<ScanSession> addShoe(String scanId) async {
    final response = await _api.dio.post(
      ApiEndpoints.scanShoes(scanId),
      data: {},
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<ScanSession> deleteShoe(String scanId, String shoeId) async {
    final response = await _api.dio.delete(
      ApiEndpoints.scanShoe(scanId, shoeId),
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<ScanSession> uploadPhoto({
    required String scanId,
    required String shoeId,
    required String view, // top, right, left, sole
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: '$view.jpg'),
      'takenAt': DateTime.now().toIso8601String(),
    });

    final response = await _api.dio.put(
      ApiEndpoints.uploadPhoto(scanId, shoeId, view),
      data: formData,
    );

    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<ScanSession> finishScan(String scanId) async {
    final response = await _api.dio.post(
      ApiEndpoints.finishScan(scanId),
      data: {},
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    return ScanSession.fromJson(data);
  }

  Future<Map<String, dynamic>> getResults(String scanId) async {
    final response = await _api.dio.get(ApiEndpoints.scanResults(scanId));
    return _api.extractData<Map<String, dynamic>>(response);
  }

  Future<Map<String, dynamic>> confirmShoe({
    required String scanId,
    required String shoeId,
    String? brandId,
    String? model,
    String? color,
    String? sizeId,
    String? gender,
  }) async {
    final response = await _api.dio.post(
      ApiEndpoints.confirmShoe(scanId, shoeId),
      data: {
        'brandId': ?brandId,
        'model': ?model,
        'color': ?color,
        'sizeId': ?sizeId,
        'gender': ?gender,
      },
    );
    return _api.extractData<Map<String, dynamic>>(response);
  }

  Future<Map<String, dynamic>> rejectShoe({
    required String scanId,
    required String shoeId,
    required String brandId,
    required String model,
    required String color,
    required String sizeId,
    String? gender,
  }) async {
    final response = await _api.dio.post(
      ApiEndpoints.rejectShoe(scanId, shoeId),
      data: {
        'brandId': brandId,
        'model': model,
        'color': color,
        'sizeId': sizeId,
        'gender': ?gender,
      },
    );
    return _api.extractData<Map<String, dynamic>>(response);
  }

  Future<void> deleteSession(String scanId) async {
    await _api.dio.delete(ApiEndpoints.scanDetail(scanId));
  }
}
