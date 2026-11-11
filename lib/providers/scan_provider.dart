import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/scan_service.dart';
import '../core/storage/token_storage.dart';
import '../models/scan_session_model.dart';

class ScanProvider extends ChangeNotifier {
  final ScanService _scanService = ScanService();

  ScanSession? _currentSession;
  int _activeShoeIndex = 0;
  String _activeView = 'top'; // top, right, left, sole
  String? _lastCapturedView;
  bool _isUploading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // Local files mapped: shoeIndex -> { 'top': XFile, 'right': XFile, ... }
  final Map<int, Map<String, XFile>> _localCapturedPhotos = {};

  ScanSession? get currentSession => _currentSession;
  ScanSession? get session => _currentSession;
  int get activeShoeIndex => _activeShoeIndex;
  String get activeView => _activeView;
  String? get lastCapturedView => _lastCapturedView;
  bool get isUploading => _isUploading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  static const List<String> viewsOrder = ['top', 'right', 'left', 'sole'];

  ScanShoe? get currentShoe {
    if (_currentSession == null || _currentSession!.shoes.isEmpty) return null;
    if (_activeShoeIndex < _currentSession!.shoes.length) {
      return _currentSession!.shoes[_activeShoeIndex];
    }
    return _currentSession!.shoes.last;
  }

  XFile? getLocalPhoto(int shoeIndex, String view) {
    return _localCapturedPhotos[shoeIndex]?[view];
  }

  bool isViewCaptured(int shoeIndex, String view) {
    if (_localCapturedPhotos[shoeIndex]?.containsKey(view) == true) {
      return true;
    }
    final shoe = (_currentSession != null &&
            shoeIndex < _currentSession!.shoes.length)
        ? _currentSession!.shoes[shoeIndex]
        : null;
    return shoe?.photoForView(view) != null;
  }

  int getCapturedCount(int shoeIndex) {
    int count = 0;
    for (final v in viewsOrder) {
      if (isViewCaptured(shoeIndex, v)) {
        count++;
      }
    }
    return count;
  }

  bool isShoeComplete(int shoeIndex) {
    return getCapturedCount(shoeIndex) >= 4;
  }

  void removePhoto(int shoeIndex, String view) {
    _localCapturedPhotos[shoeIndex]?.remove(view);
    if (_currentSession != null &&
        shoeIndex < _currentSession!.shoes.length) {
      final shoe = _currentSession!.shoes[shoeIndex];
      shoe.photos.removeWhere(
        (p) => p.view.toLowerCase() == view.toLowerCase(),
      );
    }
    _activeView = view;
    _lastCapturedView = null;
    notifyListeners();
  }

  Future<void> startNewScan() async {
    _isUploading = true;
    _errorMessage = null;
    _localCapturedPhotos.clear();
    _activeShoeIndex = 0;
    _activeView = 'top';
    _lastCapturedView = null;
    notifyListeners();

    try {
      // Ensure the client holds a valid JWT token before creating a scan session
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        final authService = AuthService();
        final guestId = DateTime.now().millisecondsSinceEpoch;
        await authService.register(
          fullName: 'Planetary Healer',
          email: 'healer_$guestId@earthdna.local',
          password: 'HealerPass123!',
          country: 'USA',
        );
      }

      _currentSession = await _scanService.createSession();
      // Add first shoe
      _currentSession = await _scanService.addShoe(_currentSession!.id);
    } catch (e) {
      // Create local fallback session so camera workflow works offline
      _errorMessage = 'Offline mode: $e';
      _currentSession = ScanSession(
        id: 'local_session_${DateTime.now().millisecondsSinceEpoch}',
        status: 'draft',
        canFinish: false,
        shoes: [
          ScanShoe(
            id: 'local_shoe_0',
            position: 1,
            label: 'Shoe 01',
            status: 'capturing',
            complete: false,
            missing: ['top', 'right', 'left', 'sole'],
            photos: [],
          ),
        ],
      );
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> captureAndUploadView({
    required XFile imageFile,
  }) async {
    // If no session exists, initialize fallback
    _currentSession ??= ScanSession(
      id: 'local_session_${DateTime.now().millisecondsSinceEpoch}',
      status: 'draft',
      canFinish: false,
      shoes: [
        ScanShoe(
          id: 'local_shoe_0',
          position: 1,
          label: 'Shoe 01',
          status: 'capturing',
          complete: false,
          missing: ['top', 'right', 'left', 'sole'],
          photos: [],
        ),
      ],
    );

    _isUploading = true;
    notifyListeners();

    try {
      final capturedView = _activeView;
      _lastCapturedView = capturedView;

      // Record locally for immediate preview
      if (!_localCapturedPhotos.containsKey(_activeShoeIndex)) {
        _localCapturedPhotos[_activeShoeIndex] = {};
      }
      _localCapturedPhotos[_activeShoeIndex]![capturedView] = imageFile;

      // Add to current shoe's local photos list
      if (currentShoe != null) {
        currentShoe!.photos.removeWhere((p) => p.view == capturedView);
        currentShoe!.photos.add(
          ScanPhoto(
            view: capturedView,
            url: imageFile.path,
            bytes: null,
            takenAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      // Try backend upload if not a local mock session
      if (_currentSession != null &&
          !_currentSession!.id.startsWith('local_')) {
        try {
          _currentSession = await _scanService.uploadPhoto(
            scanId: _currentSession!.id,
            shoeId: currentShoe!.id,
            view: capturedView,
            file: imageFile,
          );
        } catch (uploadError) {
          debugPrint('Backend upload skipped/offline: $uploadError');
        }
      }

      // Auto-advance to the next uncaptured view in sequence
      final currentIndex = viewsOrder.indexOf(capturedView);
      String? nextUncaptured;
      for (int i = 1; i <= viewsOrder.length; i++) {
        final candidate = viewsOrder[(currentIndex + i) % viewsOrder.length];
        if (!isViewCaptured(_activeShoeIndex, candidate)) {
          nextUncaptured = candidate;
          break;
        }
      }

      if (nextUncaptured != null) {
        _activeView = nextUncaptured;
      }

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Capture failed: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  void setActiveView(String view) {
    _activeView = view;
    _lastCapturedView = null;
    notifyListeners();
  }

  void clearLastCapturedConfirmation() {
    if (_lastCapturedView != null) {
      _lastCapturedView = null;
      notifyListeners();
    }
  }

  void switchActiveShoe(int index) {
    _activeShoeIndex = index;
    _activeView = 'top';
    _lastCapturedView = null;
    notifyListeners();
  }

  Future<bool> addAnotherShoe() async {
    if (_currentSession == null) return false;
    if (_currentSession!.shoes.length >= 4) {
      _errorMessage = 'Maximum 4 shoes per scan session reached.';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    notifyListeners();

    try {
      if (!_currentSession!.id.startsWith('local_')) {
        _currentSession = await _scanService.addShoe(_currentSession!.id);
      } else {
        final newIndex = _currentSession!.shoes.length;
        _currentSession!.shoes.add(
          ScanShoe(
            id: 'local_shoe_$newIndex',
            position: newIndex + 1,
            label: 'Shoe 0${newIndex + 1}',
            status: 'capturing',
            complete: false,
            missing: ['top', 'right', 'left', 'sole'],
            photos: [],
          ),
        );
      }
      _activeShoeIndex = _currentSession!.shoes.length - 1;
      _activeView = 'top';
      _lastCapturedView = null;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add shoe: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> finishScanSession() async {
    if (_currentSession == null) return false;
    _isProcessing = true;
    notifyListeners();

    try {
      if (!_currentSession!.id.startsWith('local_')) {
        _currentSession = await _scanService.finishScan(_currentSession!.id);
      }
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to finish scan: $e';
      _isProcessing = false;
      notifyListeners();
      return true; // Still allow continuation
    }
  }

  Future<Map<String, dynamic>?> pollResults() async {
    if (_currentSession == null) return null;
    try {
      return await _scanService.getResults(_currentSession!.id);
    } catch (_) {
      return null;
    }
  }
}

