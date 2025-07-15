import 'package:cfv_mobile/data/responses/auth_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import '../services/storage_service.dart';
import 'package:flutter/foundation.dart';

class AuthenticationRepository {
  final ApiService _apiService = ApiService();

  // Login method
  Future<AuthenticationResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      debugPrint('Attempting login with phone: $phoneNumber');
      
      final response = await _apiService.post(
        '/login',
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );

      debugPrint('Raw API response: ${response.data}');
      debugPrint('Response type: ${response.data.runtimeType}');
      
      final authResponse = AuthenticationResponse.fromJson(response.data);
      
      debugPrint('Parsed auth response - Success: ${authResponse.success}');
      debugPrint('Parsed auth response - Message: ${authResponse.message}');
      debugPrint('Parsed auth response - Token: ${authResponse.data?.token != null ? 'Present' : 'Missing'}');
      
      // If login successful, save token and user data
      if (authResponse.success && authResponse.data?.token != null) {
        debugPrint('Login successful, saving token...');
        
        final token = authResponse.data!.token!;
        debugPrint('Token to save: ${token.substring(0, 20)}...');
        
        final tokenSaved = await StorageService.saveToken(token);
        final loginStatusSaved = await StorageService.saveLoginStatus(true);
        
        debugPrint('Token saved: $tokenSaved, Login status saved: $loginStatusSaved');
        
        if (authResponse.data?.user != null) {
          final userDataSaved = await StorageService.saveUserData(authResponse.data!.user!.toJson());
          debugPrint('User data saved: $userDataSaved');
          debugPrint('User name: ${authResponse.data!.user!.name}');
        }
        
        // Set token for future API calls
        _apiService.setAuthToken(token);
        debugPrint('Auth token set for future API calls');
        
        // Verify token was saved
        final savedToken = await StorageService.getToken();
        debugPrint('Verified saved token: ${savedToken != null ? 'Present' : 'Missing'}');
        
      } else {
        debugPrint('Login failed - Success: ${authResponse.success}, Token: ${authResponse.data?.token}');
        debugPrint('Error message: ${authResponse.message}');
      }

      return authResponse;
    } catch (e) {
      debugPrint('Login error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return AuthenticationResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  // Register method (if needed)
  Future<AuthenticationResponse> register({
    required String phoneNumber,
    required String password,
    required String name,
    String? email,
  }) async {
    try {
      final response = await _apiService.post(
        '/register',
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
          'name': name,
          if (email != null) 'email': email,
        },
      );

      return AuthenticationResponse.fromJson(response.data);
    } catch (e) {
      return AuthenticationResponse(
        success: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Logout method
  Future<bool> logout() async {
    try {
      // Call logout API if available
      // await _apiService.post('/logout');
      
      // Clear local storage
      await StorageService.clearAll();
      
      // Remove auth token from API service
      _apiService.removeAuthToken();
      
      debugPrint('Logout completed');
      return true;
    } catch (e) {
      // Even if API call fails, clear local storage
      await StorageService.clearAll();
      _apiService.removeAuthToken();
      debugPrint('Logout completed with error: $e');
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final result = await StorageService.isAuthenticated();
    debugPrint('Is authenticated: $result');
    return result;
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Initialize authentication (call on app start)
  Future<void> initializeAuth() async {
    final token = await StorageService.getToken();
    final isLoggedIn = await StorageService.getLoginStatus();
    
    debugPrint('Initialize auth - Token: ${token != null ? 'Present' : 'Missing'}');
    debugPrint('Initialize auth - Login status: $isLoggedIn');
    
    if (token != null && token.isNotEmpty && isLoggedIn) {
      _apiService.setAuthToken(token);
      debugPrint('Auth token restored from storage');
    }
  }
}