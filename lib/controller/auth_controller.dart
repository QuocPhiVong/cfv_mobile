import 'package:cfv_mobile/data/repositories/auth_repository.dart';
import 'package:cfv_mobile/data/responses/auth_response.dart';
import 'package:flutter/material.dart';

class AuthenticationController extends ChangeNotifier {
  final AuthenticationRepository _repository = AuthenticationRepository();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  // Initialize authentication state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.initializeAuth();
      _isAuthenticated = await _repository.isAuthenticated();
      
      if (_isAuthenticated) {
        _currentUser = await _repository.getCurrentUser();
      }
    } catch (e) {
      _errorMessage = 'Lỗi khởi tạo xác thực: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.success) {
        _isAuthenticated = true;
        _currentUser = response.data?.user;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập: ${e.toString()}';
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register method
  Future<bool> register({
    required String phoneNumber,
    required String password,
    required String name,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.register(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
        email: email,
      );

      if (response.success) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng ký: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi đăng xuất: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}