import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Default emulator and local device endpoints
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 maps to host machine localhost in standard Android Emulator
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      // iOS Simulator & macOS/Desktop
      return 'http://localhost:3000/api/v1';
    }
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Scans (F1, F2)
  static const String scans = '/scans';
  static String scanDetail(String scanId) => '/scans/$scanId';
  static String scanShoes(String scanId) => '/scans/$scanId/shoes';
  static String scanShoe(String scanId, String shoeId) => '/scans/$scanId/shoes/$shoeId';
  static String uploadPhoto(String scanId, String shoeId, String view) =>
      '/scans/$scanId/shoes/$shoeId/photos/$view';
  static String batchPhotos(String scanId) => '/scans/$scanId/photos/batch';
  static String finishScan(String scanId) => '/scans/$scanId/finish';
  static String scanResults(String scanId) => '/scans/$scanId/results';
  static String submitShoeResult(String scanId, String shoeId) =>
      '/scans/$scanId/shoes/$shoeId/result';

  // Match Feedback & Catalog (F3)
  static String confirmShoe(String scanId, String shoeId) =>
      '/scans/$scanId/shoes/$shoeId/confirm';
  static String rejectShoe(String scanId, String shoeId) =>
      '/scans/$scanId/shoes/$shoeId/reject';
  static const String catalogBrands = '/catalog/brands';
  static const String catalogSizes = '/catalog/sizes';
  static const String catalogCategories = '/catalog/categories';
  static const String catalogModels = '/catalog/models';
  static const String catalogColours = '/catalog/colours';
  static const String catalogOptions = '/catalog/options';
  static const String catalogPreview = '/catalog/preview';

  // Shoes & Profile (F4, F5, F6)
  static const String shoes = '/shoes';
  static const String shoesSummary = '/shoes/summary';
  static String shoeDetail(String shoeId) => '/shoes/$shoeId';
  static String shareShoe(String shoeId) => '/shoes/$shoeId/share';
  static String shoePhotos(String shoeId) => '/shoes/$shoeId/photos';
  static String shoePhoto(String shoeId, String photoId) => '/shoes/$shoeId/photos/$photoId';
  static String rescanShoe(String shoeId) => '/shoes/$shoeId/rescan';
  static String conditionFeedback(String shoeId) => '/shoes/$shoeId/condition-feedback';
}

