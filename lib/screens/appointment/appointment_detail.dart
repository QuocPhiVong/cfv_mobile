import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  _AppointmentDetailScreenState createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool isLoading = false;

  // Cancellation reasons
  final List<String> cancellationReasons = [
    'Bận việc đột xuất',
    'Thay đổi kế hoạch',
    'Vấn đề sức khỏe',
    'Thời tiết không thuận lợi',
    'Lý do cá nhân',
    'Khác'
  ];

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final appointmentDate = DateTime.parse(appointment['appointmentDate']);
    final status = appointment['status'].toString().toLowerCase();
    
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
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(status),
            SizedBox(height: 16),
            _buildAppointmentInfo(appointment, appointmentDate),
            SizedBox(height: 16),
            _buildLocationCard(appointment),
            SizedBox(height: 16),
            _buildDescriptionCard(appointment),
            if (status == 'cancelled') ...[
              SizedBox(height: 16),
              _buildCancellationInfo(appointment),
            ],
            SizedBox(height: 24),
            _buildActionButtons(status, appointmentDate),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
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
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            SizedBox(width: 12),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo(Map<String, dynamic> appointment, DateTime appointmentDate) {
    final duration = appointment['duration'] ?? 60; // Default 60 minutes
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
              appointment['subject'] ?? 'Không có tiêu đề',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
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
            _buildInfoRow(
              Icons.hourglass_empty,
              'Thời lượng',
              '${duration} phút',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Loại hẹn',
              appointment['appointmentType']?.toString().toUpperCase() ?? 'KHÔNG XÁC ĐỊNH',
            ),
          ],
        ),
      ),
    );
  }

Widget _buildLocationCard(Map<String, dynamic> appointment) {
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
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on, color: Colors.red[400], size: 20),
              ),
              SizedBox(width: 10),
              Text(
                'Địa điểm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Location text
          Text(
            appointment['location'] ?? 'Chưa xác định địa điểm',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[900],
              height: 1.4,
            ),
          ),
          SizedBox(height: 14),

          // Directions button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openMap(appointment['location']),
              icon: Icon(Icons.directions, size: 18),
              label: Text('Chỉ đường', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildDescriptionCard(Map<String, dynamic> appointment) {
    final description = appointment['description'];
    if (description == null || description.toString().isEmpty) {
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationInfo(Map<String, dynamic> appointment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.red[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Thông tin hủy lịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildCancellationRow(
              'Người hủy:',
              appointment['cancelledBy']?.toString() == 'retailer' ? 'Nhà bán lẻ' : 'Thợ làm vườn',
            ),
            SizedBox(height: 8),
            _buildCancellationRow(
              'Lý do hủy:',
              appointment['cancellationReason']?.toString() ?? 'Không có lý do',
            ),
            SizedBox(height: 8),
            _buildCancellationRow(
              'Thời gian hủy:',
              DateFormat('dd/MM/yyyy HH:mm').format(
                DateTime.parse(appointment['updatedAt']),
              ),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[700],
            ),
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String status, DateTime appointmentDate) {
    switch (status) {
      case 'pending':
        return _buildCancelButton();
      case 'confirmed':
        return _buildConfirmedActions(appointmentDate);
      case 'cancelled':
        return _buildNewAppointmentButton();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _showCancellationReasons(),
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(Icons.cancel_outlined),
        label: Text(isLoading ? 'Đang xử lý...' : 'Hủy lịch hẹn'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmedActions(DateTime appointmentDate) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleConfirmedCancellation(appointmentDate),
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(Icons.cancel_outlined),
        label: Text(isLoading ? 'Đang xử lý...' : 'Hủy lịch hẹn'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleConfirmedCancellation(DateTime appointmentDate) {
    final now = DateTime.now();
    final timeDifference = appointmentDate.difference(now);
    
    if (timeDifference.inHours > 6) {
      _showCancellationReasons();
    } else {
      _showCancellationTimeError();
    }
  }

  void _showCancellationTimeError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600]),
            SizedBox(width: 8),
            Text('Không thể hủy'),
          ],
        ),
        content: Text(
          'Bạn chỉ có thể huỷ lịch hẹn trước giờ hẹn 6 tiếng.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showCancellationReasons() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn lý do hủy lịch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...cancellationReasons.map((reason) => ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                _confirmCancellation(reason);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )).toList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmCancellation(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xác nhận hủy lịch'),
        content: Text('Bạn có chắc chắn muốn hủy lịch hẹn này?\n\nLý do: $reason'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation(reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text('Hủy lịch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCancellation(String reason) async {
    setState(() {
      isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    // Show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hủy lịch hẹn thành công'),
        backgroundColor: Colors.green[600],
      ),
    );

    Navigator.pop(context, true); // Return true to indicate cancellation
  }

  void _createNewAppointment() {
    // Navigate to create appointment screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chuyển đến trang đặt lịch mới'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _openMap(String? location) {
    if (location != null) {
      // Open map application
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mở bản đồ: $location'),
          backgroundColor: Colors.blue[600],
        ),
      );
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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