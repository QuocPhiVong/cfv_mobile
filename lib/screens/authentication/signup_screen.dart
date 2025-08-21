import 'package:cfv_mobile/screens/authentication/otp_verification_screen.dart';
import 'package:flutter/material.dart';
// Import the OTP verification screen
// import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Validation state
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to validate on text change
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
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

  // Password strength validation
  bool _isStrongPassword(String password) {
    // At least 8 characters, contains uppercase, lowercase, number
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasLowercase && hasDigits;
  }

  String? _validatePhone(String? value) {
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

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (!_isStrongPassword(value)) {
      return 'Mật khẩu phải chứa chữ hoa, chữ thường và số';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  // Validate entire form
  void _validateForm() {
    setState(() {
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);

      _isFormValid =
          _phoneError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _phoneController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _acceptTerms;
    });
  }

  // Get password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    String password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    List<String> requirements = [];

    if (password.length >= 8) {
      strength++;
    } else {
      requirements.add('8 ký tự');
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    } else {
      requirements.add('chữ hoa');
    }

    if (password.contains(RegExp(r'[a-z]'))) {
      strength++;
    } else {
      requirements.add('chữ thường');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    } else {
      requirements.add('số');
    }

    Color strengthColor;
    String strengthText;

    switch (strength) {
      case 0:
      case 1:
        strengthColor = Colors.red;
        strengthText = 'Yếu';
        break;
      case 2:
        strengthColor = Colors.orange;
        strengthText = 'Trung bình';
        break;
      case 3:
        strengthColor = Colors.blue;
        strengthText = 'Mạnh';
        break;
      case 4:
        strengthColor = Colors.green;
        strengthText = 'Rất mạnh';
        break;
      default:
        strengthColor = Colors.grey;
        strengthText = '';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Độ mạnh: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(
                strengthText,
                style: TextStyle(fontSize: 12, color: strengthColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (requirements.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Cần: ${requirements.join(', ')}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Welcome text
                  const Text(
                    'Tạo tài khoản mới,\nĐăng ký để bắt đầu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                  ),

                  const SizedBox(height: 40),

                  // Phone number field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SĐT',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Nhập số điện thoại',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _phoneError != null ? Colors.red : Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _phoneError != null ? Colors.red : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _phoneError != null ? Colors.red : Colors.teal.shade600),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      if (_phoneError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_phoneError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mật khẩu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.teal.shade600),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_passwordError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      _buildPasswordStrengthIndicator(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Confirm password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xác nhận mật khẩu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Nhập lại mật khẩu',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError != null ? Colors.red : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError != null ? Colors.red : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError != null ? Colors.red : Colors.teal.shade600,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_confirmPasswordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_confirmPasswordError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Terms and conditions checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                            _validateForm();
                          });
                        },
                        activeColor: Colors.teal.shade600,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              children: [
                                const TextSpan(text: 'Tôi đồng ý với '),
                                TextSpan(
                                  text: 'Điều khoản sử dụng',
                                  style: TextStyle(color: Colors.teal.shade600, fontWeight: FontWeight.w600),
                                ),
                                const TextSpan(text: ' và '),
                                TextSpan(
                                  text: 'Chính sách bảo mật',
                                  style: TextStyle(color: Colors.teal.shade600, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isFormValid && !_isLoading) ? _handleRegister : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login text
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Đã có tài khoản? ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(color: Colors.teal.shade600, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_isFormValid) {
      _validateForm();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual registration API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpVerificationScreen(phoneNumber: _phoneController.text.trim())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Đăng ký thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red.shade600),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
