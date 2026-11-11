import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final cachedJson = await TokenStorage.getUserJson();
        if (cachedJson != null) {
          _currentUser = UserModel.fromJson(jsonDecode(cachedJson));
        }
        // Fetch fresh profile in background
        final fresh = await _authService.getProfile();
        if (fresh != null) {
          _currentUser = fresh;
        }
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? country,
    String? zipCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        country: country,
        zipCode: zipCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed. Email may already be in use.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not request password reset. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? country,
    String? zipCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(
        fullName: fullName,
        country: country,
        zipCode: zipCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Local fallback: update in-memory and storage so edits apply immediately
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: fullName ?? _currentUser!.fullName,
          country: country ?? _currentUser!.country,
          zipCode: zipCode ?? _currentUser!.zipCode,
          role: _currentUser!.role,
          createdAt: _currentUser!.createdAt,
        );
        await TokenStorage.saveUserJson(jsonEncode(_currentUser!.toJson()));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}

