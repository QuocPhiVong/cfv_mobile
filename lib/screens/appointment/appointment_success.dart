import 'package:cfv_mobile/screens/appointment/appointment_detail.dart';
import 'package:cfv_mobile/screens/appointment/appointment_list.dart';
import 'package:flutter/material.dart';

class AppointmentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentSuccessScreen({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Success icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                      child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 80),
                    ),
                    const SizedBox(height: 24),
                    // Success message
                    const Text(
                      'Lịch hẹn đã được tạo thành công!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chúng tôi sẽ liên hệ với bạn để xác nhận lịch hẹn.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Appointment summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin lịch hẹn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('Chủ đề', appointmentData['subject'] ?? '', Icons.topic),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Tên vườn', appointmentData['gardenName'] ?? '', Icons.agriculture),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Số điện thoại', appointmentData['phone'] ?? '', Icons.phone),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Địa chỉ', appointmentData['address'] ?? '', Icons.location_on),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Thời gian hẹn',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Ngày: ${appointmentData['date'] ?? ''}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời gian bắt đầu: ${appointmentData['startTime'] ?? ''}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời lượng: ${appointmentData['duration'] ?? ''}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hình thức: ${appointmentData['method'] ?? ''}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          if (appointmentData['description'] != null &&
                              appointmentData['description'].toString().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSummaryRow('Mô tả chi tiết', appointmentData['description'] ?? '', Icons.description),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Column(
              children: [
                // Xem chi tiết button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AppointmentDetailScreen(appointmentId: appointmentData['id']),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                // Về trang chủ button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to home screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Về trang chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
