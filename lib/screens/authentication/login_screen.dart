import "package:cfv_mobile/controller/auth_controller.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../home/main_screen.dart";
import "signup_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  // Validation state
  String? _phoneError;
  String? _passwordError;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to validate on text change
    _phoneNumberController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  // Vietnamese phone number validation
  bool _isValidVietnamesePhone(String phone) {
    // Remove all spaces and special characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Vietnamese phone number patterns
    // Mobile: 03x, 05x, 07x, 08x, 09x (10 digits total)
    // With country code: +84 followed by 9 digits
    RegExp mobilePattern = RegExp(r'^(0[3|5|7|8|9][0-9]{8})$');
    RegExp internationalPattern = RegExp(r'^(\+84[3|5|7|8|9][0-9]{8})$');

    return mobilePattern.hasMatch(cleanPhone) || internationalPattern.hasMatch(cleanPhone);
  }

  // Password validation
  bool _isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }

  // Validate individual fields
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    if (!_isValidVietnamesePhone(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (!_isValidPassword(value)) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  // Validate entire form
  void _validateForm() {
    if (mounted) {
      setState(() {
        _phoneError = _validatePhoneNumber(_phoneNumberController.text);
        _passwordError = _validatePassword(_passwordController.text);
        _isFormValid = _phoneError == null &&
            _passwordError == null &&
            _phoneNumberController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    }
  }

  // Handle login
  void _handleLogin() async {
    if (!_isFormValid) {
      _validateForm();
      return;
    }

    // Capture context safely before async gap
    final currentContext = context;
    final authController = Provider.of<AuthenticationController>(currentContext, listen: false);

    final success = await authController.login(
      phoneNumber: _phoneNumberController.text.trim(),
      password: _passwordController.text,
    );

    // Check if the widget is still mounted after the async operation
    if (!mounted) {
      debugPrint('LoginScreen is no longer mounted after login attempt.');
      return;
    }

    if (success && authController.isAuthenticated) {
      // Show snackbar using captured context
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: const Text('Đăng nhập thành công!'),
          backgroundColor: Colors.teal.shade600,
          duration: const Duration(seconds: 1),
        ),
      );
      // Wait a bit so the snackbar can appear before navigating
      await Future.delayed(const Duration(milliseconds: 300));

      // Check again before navigation, as another async gap occurred
      if (!mounted) {
        debugPrint('LoginScreen is no longer mounted after snackbar delay.');
        return;
      }

      debugPrint('Attempting to navigate to MainScreen...');
      // Navigate safely using pushReplacement
      Navigator.of(currentContext).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      final errorMsg = authController.errorMessage ?? 'Đăng nhập thất bại';
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // app logo
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade600,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // welcome text
                const Text(
                  'Chào mừng quay trở lại!\nVui lòng đăng nhập để tiếp tục',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 40),
                // phone number input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Nhập số điện thoại của bạn',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _phoneError != null ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _phoneError != null ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _phoneError != null ? Colors.red : Colors.teal.shade600,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    if (_phoneError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _phoneError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // password input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mật khẩu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu của bạn',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _passwordError != null ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _passwordError != null ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _passwordError != null ? Colors.red : Colors.teal.shade600,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _passwordError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password action
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Colors.teal.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // login button
                Consumer<AuthenticationController>(
                  builder: (context, authController, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isFormValid && !authController.isLoading) ? _handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: authController.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // sign up text
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            color: Colors.teal.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}