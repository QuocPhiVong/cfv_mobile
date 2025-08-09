import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:get/get.dart'; // Using the import path from your desired repo
import 'package:flutter/foundation.dart'; // For debugPrint

class AuthenticationRepository extends GetxController {
  // Provides a static instance getter for easy access throughout your app
  static AuthenticationRepository get instance => Get.find();

  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    debugPrint('AuthenticationRepository onReady: Native splash screen removed.');
  }

  /// Handles user login with phone number and password.
  /// Returns a Map<String, dynamic>? representing the API response data, or null on error.
  Future<Map<String, dynamic>?> onLogin({required String phoneNumber, required String password}) async {
    try {
      debugPrint('Attempting login with phone: $phoneNumber');
      final response = await _apiService.dio.post(
        '/login', // Updated API endpoint
        data: {
          'phoneNumber': phoneNumber, // Changed from 'email' to 'phoneNumber'
          'password': password,
        },
      );
      debugPrint('Login API response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('Login error: $e');
      return null; // Return null to indicate failure
    }
  }

  /// Handles user registration with various details, using phone number as primary identifier.
  /// Returns a Map<String, dynamic>? representing the API response data, or null on error.
  Future<Map<String, dynamic>?> onRegister({
    required String username,
    required String phoneNumber, // Changed from 'email' to 'phoneNumber'
    required String address,
    required String avatar,
    required String password,
  }) async {
    try {
      debugPrint('Attempting registration for phone: $phoneNumber');
      final response = await _apiService.dio.post(
        '/register', // Updated API endpoint
        data: {
          "user-name": username,
          "password": password,
          "phone-number": phoneNumber, // Changed from 'email' to 'phone-number'
          "address": address,
          "avatar": avatar,
        },
      );
      debugPrint('Register API response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('Register error: $e');
      return null; // Return null to indicate failure
    }
  }

  /// Fetches user profile information based on their phone number.
  /// Returns a Map<String, dynamic>? representing the API response data, or null on error.
  Future<Map<String, dynamic>?> onFetchProfile({
    required String phoneNumber, // Changed from 'mail' to 'phoneNumber'
  }) async {
    try {
      debugPrint('Attempting to fetch profile for phone: $phoneNumber');
      final response = await _apiService.dio.get('/v1/accounts/$phoneNumber/info'); // Updated API endpoint
      debugPrint('Fetch profile API response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      return null; // Return null to indicate failure
    }
  }
}
