import 'package:get/get.dart'; // Import GetX
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:cfv_mobile/data/repositories/auth_repository.dart';
import 'package:cfv_mobile/data/responses/auth_response.dart'; // Assuming your User model is here
import 'package:cfv_mobile/data/services/storage_service.dart'; // Assuming you have a StorageService

class AuthenticationController extends GetxController {
  // Get the instance of AuthenticationRepository that was put in main.dart
  final AuthenticationRepository _repository = AuthenticationRepository.instance;

  // Reactive state variables
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;
  final Rx<User?> _currentUser = Rx<User?>(null); // Nullable User object
  final RxString _errorMessage = RxString(''); // For error messages

  // Getters for accessing reactive state values
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  User? get currentUser => _currentUser.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Perform initial authentication status check when the controller is initialized
    checkAuthStatus();
  }

  /// Checks the authentication status from local storage on app start.
  Future<void> checkAuthStatus() async {
    _isLoading.value = true;
    update(); // Notify GetBuilder listeners of loading state

    try {
      final token = await StorageService.getToken();
      final isLoggedIn = await StorageService.getLoginStatus();
      final userDataMap = await StorageService.getUserData();

      debugPrint('Auth check - Token: ${token != null ? 'Present' : 'Missing'}');
      debugPrint('Auth check - Login status: $isLoggedIn');

      if (token != null && token.isNotEmpty && isLoggedIn) {
        _isAuthenticated.value = true;
        if (userDataMap != null) {
          try {
            _currentUser.value = User.fromJson(userDataMap);
          } catch (e) {
            debugPrint('Error parsing stored user data: $e');
            // If user data is corrupted, clear auth state
            await StorageService.clearAll();
            _isAuthenticated.value = false;
            _currentUser.value = null;
          }
        }
        debugPrint('User is authenticated and data loaded.');
      } else {
        _isAuthenticated.value = false;
        _currentUser.value = null;
        // Ensure consistency: if token or login status is missing, clear all
        await StorageService.clearAll();
        debugPrint('User is not authenticated or session invalid. Cleared local storage.');
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi kiểm tra xác thực ban đầu: ${e.toString()}';
      _isAuthenticated.value = false;
      _currentUser.value = null;
      debugPrint('Error during initial auth status check: $e');
    } finally {
      _isLoading.value = false;
      update(); // Notify GetBuilder listeners that loading is complete
    }
  }

  /// Handles user login with phone number and password.
  /// Determines success by the presence of a 'token' in the API response.
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = ''; // Clear previous error
    update();

    try {
      final response = await _repository.onLogin(
        phoneNumber: phoneNumber,
        password: password,
      );

      // Check if the response from the repository is not null
      if (response != null) {
        // Extract the token directly from the response map
        final String? token = response['token'];

        if (token != null && token.isNotEmpty) {
          // Login successful: token is present
          final Map<String, dynamic>? userDataMap = response['user']; // Assuming 'user' key exists for user data
          User? user;
          if (userDataMap != null) {
            try {
              user = User.fromJson(userDataMap);
            } catch (e) {
              debugPrint('Error parsing user data from login response: $e');
              _errorMessage.value = 'Đăng nhập thành công nhưng lỗi đọc dữ liệu người dùng.';
              // Decide if this is a critical error or if you can proceed without user details
            }
          }

          // Save token and user data to storage
          await StorageService.saveToken(token);
          await StorageService.saveLoginStatus(true);
          if (user != null) {
            await StorageService.saveUserData(user.toJson());
          }

          _isAuthenticated.value = true;
          _currentUser.value = user;
          _errorMessage.value = ''; // Clear any success-related messages
          debugPrint('Login successful for $phoneNumber. Token and user data saved.');
          return true;
        } else {
          // Login failed: Response received, but no token (or empty token)
          // The API might send a 'message' field in this case
          _errorMessage.value = response['message'] ?? 'Đăng nhập thất bại: Không nhận được token.';
          _isAuthenticated.value = false;
          _currentUser.value = null;
          debugPrint('Login failed: ${errorMessage}');
          return false;
        }
      } else {
        // Login failed: Null response from repository (e.g., network error or unhandled exception in repo)
        _errorMessage.value = 'Đăng nhập thất bại: Không có phản hồi từ máy chủ.';
        _isAuthenticated.value = false;
        _currentUser.value = null;
        debugPrint('Login failed: Null response from repository.');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi đăng nhập: ${e.toString()}';
      _isAuthenticated.value = false;
      _currentUser.value = null;
      debugPrint('Login error caught in controller: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  /// Handles user registration.
  /// Assumes success is indicated by 'success: true' in the API response.
  Future<bool> register({
    required String username,
    required String phoneNumber,
    required String address,
    required String avatar,
    required String password,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    update();

    try {
      final response = await _repository.onRegister(
        username: username,
        phoneNumber: phoneNumber,
        address: address,
        avatar: avatar,
        password: password,
      );

      if (response != null && response['success'] == true) {
        _errorMessage.value = 'Đăng ký thành công. Vui lòng đăng nhập.';
        debugPrint('Registration successful for $phoneNumber');
        return true;
      } else {
        _errorMessage.value = response?['message'] ?? 'Đăng ký thất bại.';
        debugPrint('Registration failed: ${errorMessage}');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi đăng ký: ${e.toString()}';
      debugPrint('Registration error caught in controller: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  /// Handles user logout, clearing local storage and authentication state.
  Future<void> logout() async {
    _isLoading.value = true;
    update();
    try {
      await StorageService.clearAll(); // Clear all stored data
      _isAuthenticated.value = false;
      _currentUser.value = null;
      _errorMessage.value = '';
      debugPrint('Logout successful. Local storage cleared.');
    } catch (e) {
      _errorMessage.value = 'Lỗi đăng xuất: ${e.toString()}';
      debugPrint('Logout error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage.value = '';
    update();
  }
}