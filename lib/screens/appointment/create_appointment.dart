import 'package:cfv_mobile/controller/create_appointment_controller.dart';
import 'package:cfv_mobile/data/services/storage_service.dart';
import 'package:cfv_mobile/screens/appointment/appointment_success.dart';
import 'package:cfv_mobile/controller/appointment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GardenerData {
  final String name;
  final String phone;
  final String address;
  final String gardenerId;

  GardenerData({required this.name, required this.phone, required this.address, required this.gardenerId});
}

class CreateAppointmentScreen extends StatefulWidget {
  final GardenerData? gardenerData;
  const CreateAppointmentScreen({super.key, this.gardenerData});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CreateAppointmentController _appointmentController = Get.put(CreateAppointmentController());

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = '30 phút';
  String _selectedMethod = 'Trực tiếp';
  bool _showSubjectSuggestions = false;

  final List<String> _subjectSuggestions = [
    'Tham quan vườn trồng',
    'Tư vấn kỹ thuật trồng trọt',
    'Đặt mua sản phẩm số lượng lớn',
    'Hợp tác kinh doanh',
    'Học hỏi kinh nghiệm',
    'Thảo luận về giá cả',
    'Xem quy trình sản xuất',
    'Khác',
  ];

  final List<String> _durationOptions = [
    '30 phút',
    '1 tiếng',
    '1 tiếng 30 phút',
    '2 tiếng',
    '2 tiếng 30 phút',
    '3 tiếng',
  ];

  final List<String> _methodOptions = ['Trực tiếp', 'Trực tuyến'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo lịch hẹn',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Information Section
                  const Text(
                    'Thông tin lịch hẹn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject field with suggestions
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _subjectController,
                          onTap: () {
                            setState(() {
                              _showSubjectSuggestions = true;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Chủ đề',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      if (_showSubjectSuggestions) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _subjectSuggestions.map((suggestion) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  suggestion,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () {
                                  _subjectController.text = suggestion;
                                  setState(() {
                                    _showSubjectSuggestions = false;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Garden information
                  _buildInfoRow('Tên vườn', widget.gardenerData?.name ?? 'Vườn Xanh Miền Tây'),
                  _buildInfoRow('Số điện thoại', widget.gardenerData?.phone ?? '0901 234 567'),
                  _buildInfoRow(
                    'Địa chỉ cụ thể',
                    widget.gardenerData?.address ?? '123 Đường Cần Thơ, An Giang' ,
                  ),

                  const SizedBox(height: 32),

                  // Time Section
                  const Text(
                    'Thời gian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date field
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Chọn ngày',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate != null
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Start time field
                  GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thời gian bắt đầu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  _selectedTime != null
                                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Chọn giờ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedTime != null
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Duration dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Thời lượng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDuration,
                                  isExpanded: true,
                                  items: _durationOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedDuration = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Hình thức dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Hình thức',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMethod,
                                  isExpanded: true,
                                  items: _methodOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedMethod = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description Section
                  const Text(
                    'Mô tả chi tiết',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Mô tả',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Create appointment button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Error message
                Obx(() {
                  if (_appointmentController.errorMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _appointmentController.errorMessage.value,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // Create button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: _appointmentController.isCreating.value ? null : _createAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: _appointmentController.isCreating.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Đang tạo...',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : const Text(
                              'Tạo lịch hẹn',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<String?> _getAccountId() async {
    final userData = await StorageService.getUserData();
    final accountId = userData?['accountId'];
    if (accountId == null) {
      debugPrint('AccountId not found in user data');
    }
    return accountId;
  }

  Future<void> _createAppointment() async {
    // Validate required fields
    if (_subjectController.text.isEmpty) {
      _appointmentController.errorMessage.value = 'Vui lòng nhập chủ đề';
      return;
    }

    if (_selectedDate == null) {
      _appointmentController.errorMessage.value = 'Vui lòng chọn ngày';
      return;
    }

    if (_selectedTime == null) {
      _appointmentController.errorMessage.value = 'Vui lòng chọn thời gian';
      return;
    }

    // Combine date and time
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Convert duration from Vietnamese to minutes
    int durationMinutes = _convertDurationToSeconds(_selectedDuration);

    try {
      final retailerId = await _getAccountId();
      final success = await _appointmentController.createAppointment(
        subject: _subjectController.text,
        description: _descriptionController.text,
        appointmentDate: appointmentDateTime,
        duration: durationMinutes,
        appointmentType: _selectedMethod,
        gardenerId: widget.gardenerData?.gardenerId ?? '',
        retailerId: retailerId ?? '',
        location: widget.gardenerData?.address ?? '',
      );

      if (success) {
        // Create appointment data for success screen
        final appointmentData = {
          'subject': _subjectController.text,
          'gardenName': widget.gardenerData?.name ?? '',
          'phone': widget.gardenerData?.phone ?? '',
          'address': widget.gardenerData?.address ?? '',
          'date': '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          'startTime': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
          'duration': _selectedDuration,
          'method': _selectedMethod,
          'description': _descriptionController.text,
          'appointmentId': '',
        };

        // Navigate to success screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentSuccessScreen(appointmentData: appointmentData),
          ),
        );
      }
    } catch (e) {
      _appointmentController.errorMessage.value = 'Có lỗi xảy ra khi tạo lịch hẹn. Vui lòng thử lại.';
    }
  }

  /// Convert Vietnamese duration string to minutes
  int _convertDurationToSeconds(String duration) {
    switch (duration) {
      case '30 phút':
        return 30;
      case '1 tiếng':
        return 60;
      case '1 tiếng 30 phút':
        return 90;
      case '2 tiếng':
        return 120;
      case '2 tiếng 30 phút':
        return 150;
      case '3 tiếng':
        return 180;
      default:
        return 30;
    }
  }
}
