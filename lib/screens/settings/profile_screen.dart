import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ'];

  // Sample user data (would come from signup and finish profile screens)
  String _userName = 'Vòng Quốc Phi';
  String _userPhone = '0982912617';
  String _userGender = 'Nam';
  String _userBirthDate = '11/11/2002';
  String _userAddress = '39 Thạnh Xuân 18, P. Thạnh Xuân, Quận 12';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = _userName;
    _phoneController.text = _userPhone;
    _dateController.text = _userBirthDate;
    _addressController.text = _userAddress;
    _selectedGender = _userGender;
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Cancel editing - restore original values
        _initializeControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      _userName = _nameController.text;
      _userPhone = _phoneController.text;
      _userGender = _selectedGender ?? 'Nam';
      _userBirthDate = _dateController.text;
      _userAddress = _addressController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.teal.shade600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Hồ sơ',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            child: Text(
              _isEditing ? 'Lưu' : 'Sửa',
              style: TextStyle(color: Colors.teal.shade600, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (_isEditing)
            TextButton(
              onPressed: _toggleEdit,
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade400),
                    child: Icon(Icons.person, color: Colors.grey.shade600, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(_userPhone, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Personal Information Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    _buildInfoField(
                      label: 'Họ và tên',
                      value: _userName,
                      controller: _nameController,
                      isEditing: _isEditing,
                    ),

                    const SizedBox(height: 16),

                    // Phone Field
                    _buildInfoField(
                      label: 'Số điện thoại',
                      value: _userPhone,
                      controller: _phoneController,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // Gender Field
                    _buildGenderField(),

                    const SizedBox(height: 16),

                    // Birth Date Field
                    _buildInfoField(
                      label: 'Ngày sinh',
                      value: _userBirthDate,
                      controller: _dateController,
                      isEditing: _isEditing,
                    ),

                    const SizedBox(height: 16),

                    // Address Field
                    _buildInfoField(
                      label: 'Địa chỉ',
                      value: _userAddress,
                      controller: _addressController,
                      isEditing: _isEditing,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.teal.shade600),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới tính',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.teal.shade600),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(value: gender, child: Text(gender));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(_userGender, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
