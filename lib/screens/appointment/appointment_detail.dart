import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:cfv_mobile/controller/appointment_detail_controller.dart';
import 'package:maps_launcher/maps_launcher.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with appointmentId
    final controller = Get.put(AppointmentDetailController());

    // Load appointment if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.appointment.value == null) {
        controller.loadAppointmentDetail(appointmentId);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết lịch hẹn',
          style: TextStyle(color: Colors.grey[800], fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: () => _showMoreOptions(controller),
          ),
        ],
      ),
      body: Obx(() {
        // Show loading indicator
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Đang tải thông tin lịch hẹn...')],
            ),
          );
        }

        // Show error message
        if (controller.errorMessage.value.isNotEmpty && controller.appointment.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(controller.errorMessage.value, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => controller.refreshAppointmentDetail(), child: Text('Thử lại')),
              ],
            ),
          );
        }

        // Show appointment details
        final appointment = controller.appointment.value;
        if (appointment == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text('Không tìm thấy thông tin lịch hẹn'),
              ],
            ),
          );
        }

        final appointmentDate = appointment.appointmentDate ?? DateTime.now();
        final status = appointment.status?.toLowerCase() ?? 'unknown';

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(status, controller),
              SizedBox(height: 16),
              _buildAppointmentInfo(appointment, appointmentDate),
              SizedBox(height: 16),
              _buildLocationCard(appointment),
              SizedBox(height: 16),
              _buildDescriptionCard(appointment),
              if (status == 'cancelled') ...[SizedBox(height: 16), _buildCancellationInfo(appointment, controller)],
              SizedBox(height: 24),
              _buildActionButtons(status, appointmentDate, controller),
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(String status, AppointmentDetailController controller) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'ĐÃ XÁC NHẬN';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'CHỜ XÁC NHẬN';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'ĐÃ HỦY';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'KHÔNG XÁC ĐỊNH';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            SizedBox(width: 12),
            Text(
              statusText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo(AppointmentData appointment, DateTime appointmentDate) {
    final duration = int.tryParse(appointment.duration ?? '60') ?? 60; // Default 60 minutes
    final endTime = appointmentDate.add(Duration(minutes: duration));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.subject ?? 'Không có tiêu đề',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày hẹn',
              DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(appointmentDate),
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${DateFormat('HH:mm').format(appointmentDate)} - ${DateFormat('HH:mm').format(endTime)}',
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.hourglass_empty, 'Thời lượng', '$duration phút'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.category, 'Loại hẹn', appointment.appointmentType?.toUpperCase() ?? 'KHÔNG XÁC ĐỊNH'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(AppointmentData appointment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.location_on, color: Colors.red[400], size: 20),
                ),
                SizedBox(width: 10),
                Text(
                  'Địa điểm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Location text
            Text(
              appointment.location ?? 'Chưa xác định địa điểm',
              style: TextStyle(fontSize: 15, color: Colors.grey[900], height: 1.4),
            ),
            SizedBox(height: 14),

            // Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMap(appointment.location),
                icon: Icon(Icons.directions, size: 18),
                label: Text('Chỉ đường', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(AppointmentData appointment) {
    final description = appointment.description;
    if (description == null || description.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue[400], size: 20),
                SizedBox(width: 8),
                Text(
                  'Mô tả',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationInfo(AppointmentData appointment, AppointmentDetailController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.red[50]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.red[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Thông tin hủy lịch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildCancellationRow('Người hủy:', controller.getCancelledByDisplayText()),
            SizedBox(height: 8),
            _buildCancellationRow('Lý do hủy:', appointment.cancellationReason ?? 'Không có lý do'),
            SizedBox(height: 8),
            _buildCancellationRow(
              'Thời gian hủy:',
              appointment.updatedAt != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(appointment.updatedAt!)
                  : 'Không xác định',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red[600]),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 14, color: Colors.red[700])),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String status, DateTime appointmentDate, AppointmentDetailController controller) {
    switch (status) {
      case 'pending':
        return _buildCancelButton(controller);
      case 'confirmed':
        return _buildConfirmedActions(appointmentDate, controller);
      case 'cancelled':
        return _buildNewAppointmentButton();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildCancelButton(AppointmentDetailController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.isUpdating.value ? null : () => _showCancellationReasons(controller),
          icon: controller.isUpdating.value
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(Icons.cancel_outlined),
          label: Text(controller.isUpdating.value ? 'Đang xử lý...' : 'Hủy lịch hẹn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmedActions(DateTime appointmentDate, AppointmentDetailController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.isUpdating.value ? null : () => _showCancellationReasons(controller),
          icon: controller.isUpdating.value
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(Icons.cancel_outlined),
          label: Text(controller.isUpdating.value ? 'Đang xử lý...' : 'Hủy lịch hẹn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildNewAppointmentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _createNewAppointment(),
        icon: Icon(Icons.add_circle_outline),
        label: Text('Đặt lịch hẹn mới'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showCancellationReasons(AppointmentDetailController controller) {
    final List<String> cancellationReasons = [
      'Bận việc đột xuất',
      'Thay đổi kế hoạch',
      'Vấn đề sức khỏe',
      'Thời tiết không thuận lợi',
      'Lý do cá nhân',
      'Khác',
    ];

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 20),
            Text('Chọn lý do hủy lịch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...cancellationReasons.map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.pop(context);
                  _confirmCancellation(reason, controller);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmCancellation(String reason, AppointmentDetailController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xác nhận hủy lịch'),
        content: Text('Bạn có chắc chắn muốn hủy lịch hẹn này?\n\nLý do: $reason'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Không')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation(reason, controller);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text('Hủy lịch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCancellation(String reason, AppointmentDetailController controller) async {
    final success = await controller.cancelAppointment(cancellationReason: reason);

    if (success) {
      // Show success message
      Get.snackbar(
        'Thành công',
        controller.successMessage.value,
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } else {
      // Show error message
      Get.snackbar(
        'Lỗi',
        controller.errorMessage.value,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _createNewAppointment() {
    // Navigate to create appointment screen
    Get.snackbar(
      'Thông báo',
      'Chuyển đến trang đặt lịch mới',
      backgroundColor: Colors.blue[600],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  Future<void> _openMap(String? location) async {
    if (location != null) {
      final result = await MapsLauncher.launchQuery(location);
      if (!result) {
        Get.snackbar(
          'Lỗi',
          'Không thể mở Google Maps',
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    }
  }

  void _showMoreOptions(AppointmentDetailController controller) {
    showModalBottomSheet(
      context: Get.context!,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Chia sẻ'),
              onTap: () {
                Navigator.pop(context);
                // Share appointment details
              },
            ),
          ],
        ),
      ),
    );
  }
}
