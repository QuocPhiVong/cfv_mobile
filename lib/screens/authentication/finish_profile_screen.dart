import 'package:cfv_mobile/screens/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class FinishProfileScreen extends StatefulWidget {
  const FinishProfileScreen({super.key});

  @override
  State<FinishProfileScreen> createState() => _FinishProfileScreenState();
}

class _FinishProfileScreenState extends State<FinishProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;

  // Validation state
  String? _nameError;
  String? _genderError;
  String? _dateError;
  String? _addressError;
  bool _isFormValid = false;

  final List<String> _genderOptions = ['Nam', 'Nữ'];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _dateController.addListener(_validateForm);
  }

  // Name validation
  bool _isValidName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(name.trim());
  }

  // Date validation
  bool _isValidDate(String date) {
    if (date.isEmpty) return false;

    // Check format DD/MM/YYYY
    RegExp dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    if (!dateRegex.hasMatch(date)) return false;

    try {
      List<String> parts = date.split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Basic date validation
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      if (year < 1950 || year > DateTime.now().year) return false;

      // Create DateTime to validate the date
      DateTime parsedDate = DateTime(year, month, day);
      _selectedDate = parsedDate;

      // Check if person is at least 13 years old
      DateTime now = DateTime.now();
      int age = now.year - year;
      if (now.month < month || (now.month == month && now.day < day)) {
        age--;
      }

      return age >= 13;
    } catch (e) {
      return false;
    }
  }

  // Individual field validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }

    if (!_isValidName(value)) {
      return 'Họ và tên chỉ được chứa chữ cái và khoảng trắng';
    }

    return null;
  }

  String? _validateGender() {
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      return 'Vui lòng chọn giới tính';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ngày sinh';
    }

    if (!_isValidDate(value)) {
      return 'Ngày sinh không hợp lệ hoặc bạn chưa đủ 13 tuổi';
    }

    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }

    if (value.trim().length < 10) {
      return 'Địa chỉ phải có ít nhất 10 ký tự';
    }

    return null;
  }

  // Validate entire form
  void _validateForm() {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _genderError = _validateGender();
      _dateError = _validateDate(_dateController.text);
      _addressError = _validateAddress(_addressController.text);

      _isFormValid =
          _nameError == null &&
          _genderError == null &&
          _dateError == null &&
          _addressError == null &&
          _nameController.text.isNotEmpty &&
          _selectedGender != null &&
          _dateController.text.isNotEmpty &&
          _addressController.text.isNotEmpty;
    });
  }

  // Format date input
  void _formatDateInput(String value) {
    String formatted = value.replaceAll(RegExp(r'[^\d]'), '');

    if (formatted.length >= 2) {
      formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
    }
    if (formatted.length >= 5) {
      formatted = '${formatted.substring(0, 5)}/${formatted.substring(5)}';
    }
    if (formatted.length > 10) {
      formatted = formatted.substring(0, 10);
    }

    _dateController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Alternative date picker using showDialog
  Future<void> _showDatePickerDialog() async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    DateTime selectedDate = _selectedDate ?? initialDate; // ✅ Make it non-nullable

    await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chọn ngày sinh'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  children: [
                    // Year selector
                    Row(
                      children: [
                        const Text('Năm: '),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedDate.year,
                            isExpanded: true,
                            items: List.generate(75, (index) {
                              int year = DateTime.now().year - index;
                              return DropdownMenuItem(value: year, child: Text(year.toString()));
                            }),
                            onChanged: (int? newYear) {
                              if (newYear != null) {
                                setState(() {
                                  selectedDate = DateTime(newYear, selectedDate.month, selectedDate.day);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Month selector
                    Row(
                      children: [
                        const Text('Tháng: '),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedDate.month,
                            isExpanded: true,
                            items: List.generate(12, (index) {
                              int month = index + 1;
                              return DropdownMenuItem(value: month, child: Text('Tháng $month'));
                            }),
                            onChanged: (int? newMonth) {
                              if (newMonth != null) {
                                setState(() {
                                  selectedDate = DateTime(selectedDate.year, newMonth, selectedDate.day);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Day selector
                    Row(
                      children: [
                        const Text('Ngày: '),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedDate.day,
                            isExpanded: true,
                            items: List.generate(31, (index) {
                              int day = index + 1;
                              return DropdownMenuItem(value: day, child: Text('Ngày $day'));
                            }),
                            onChanged: (int? newDay) {
                              if (newDay != null) {
                                setState(() {
                                  selectedDate = DateTime(selectedDate.year, selectedDate.month, newDay);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = selectedDate;
                      _dateController.text =
                          '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
                    });
                    Navigator.pop(context);
                    _validateForm();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade600),
                  child: const Text('Chọn'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Full name field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Họ và tên',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: 'Nhập họ và tên',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _nameError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _nameError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _nameError != null ? Colors.red : Colors.teal.shade600),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_nameError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Gender field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Giới tính',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: Text('Nam / Nữ', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _genderError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _genderError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _genderError != null ? Colors.red : Colors.teal.shade600),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: _genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(value: gender, child: Text(gender));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                          _validateForm();
                        });
                      },
                    ),
                    if (_genderError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_genderError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Date of birth field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Ngày sinh',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                      decoration: InputDecoration(
                        hintText: '00/00/0000',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _dateError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _dateError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _dateError != null ? Colors.red : Colors.teal.shade600),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                          onPressed: _showDatePickerDialog,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: _formatDateInput,
                    ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_dateError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Address field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Địa chỉ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập địa chỉ',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _addressError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _addressError != null ? Colors.red : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _addressError != null ? Colors.red : Colors.teal.shade600),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    if (_addressError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_addressError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 60),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isFormValid && !_isLoading) ? _handleComplete : null,
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
                        : const Text('Hoàn thành', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleComplete() async {
    if (!_isFormValid) {
      _validateForm();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual profile completion API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Hồ sơ đã được hoàn thành thành công!'), backgroundColor: Colors.teal.shade600),
      );

      // Navigate to main app
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Có lỗi xảy ra. Vui lòng thử lại.'), backgroundColor: Colors.red.shade600),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _addressController.removeListener(_validateForm);
    _dateController.removeListener(_validateForm);
    _nameController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
