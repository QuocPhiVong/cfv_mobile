import 'package:cfv_mobile/screens/appointment/appointment_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  String selectedFilter = 'All';
  
  // Fake data matching your API schema
  final List<Map<String, dynamic>> appointments = [
    {
      "appointmentId": {"random": "apt_003", "time": "2025-08-12T12:00:48.951Z"},
      "gardenerId": {"random": "grd_003", "time": "2025-08-12T12:00:48.951Z"},
      "retailerId": {"random": "ret_003", "time": "2025-08-12T12:00:48.951Z"},
      "appointmentDate": "2025-08-14T09:00:00.000Z",
      "subject": "Gặp nhau cuối tuần",
      "location": "789 Maple Drive, Greenfield",
      "status": "confirmed",
      "appointmentType": "Trực tuyến",
      "createdAt": "2025-08-12T12:00:48.951Z",
      "updatedAt": "2025-08-12T12:00:48.951Z",
      "duration": 60,
      "description": "UIA Skibidi Dop Dop Yes Yes"
    },
    {
      "appointmentId": {"random": "apt_003", "time": "2025-08-12T12:00:48.951Z"},
      "gardenerId": {"random": "grd_003", "time": "2025-08-12T12:00:48.951Z"},
      "retailerId": {"random": "ret_003", "time": "2025-08-12T12:00:48.951Z"},
      "appointmentDate": "2025-08-14T09:00:00.000Z",
      "subject": "Gặp nhau cuối tuần",
      "location": "789 Maple Drive, Greenfield",
      "status": "pending",
      "appointmentType": "Trực tuyến",
      "createdAt": "2025-08-12T12:00:48.951Z",
      "updatedAt": "2025-08-12T12:00:48.951Z",
      "duration": 60,
      "description": "UIA Skibidi Dop Dop Yes Yes"
    },
    {
      "appointmentId": {"random": "apt_003", "time": "2025-08-12T12:00:48.951Z"},
      "gardenerId": {"random": "grd_003", "time": "2025-08-12T12:00:48.951Z"},
      "retailerId": {"random": "ret_003", "time": "2025-08-12T12:00:48.951Z"},
      "appointmentDate": "2025-08-14T09:00:00.000Z",
      "subject": "Gặp nhau cuối tuần",
      "location": "789 Maple Drive, Greenfield",
      "status": "cancelled",
      "appointmentType": "Trực tuyến",
      "createdAt": "2025-08-12T12:00:48.951Z",
      "updatedAt": "2025-08-12T12:00:48.951Z",
      "cancelledBy": "Vòng Quốc Phi",
      "cancellationReason": "Bận đột xuất",
      "duration": 60,
      "description": "UIA Skibidi Dop Dop Yes Yes"
    },
  ];

  List<Map<String, dynamic>> get filteredAppointments {
    if (selectedFilter == 'All') return appointments;
    return appointments.where((apt) => 
      apt['status'].toString().toLowerCase() == selectedFilter.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Quản lý lịch hẹn',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredAppointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Confirmed', 'Pending', 'Cancelled'];
    
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.green[700] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = DateTime.parse(appointment['appointmentDate']);
    final status = appointment['status'].toString();
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          // Navigate to appointment detail screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(
                appointment: appointment,
              ),
            ),
          );
          
          // Handle result if appointment was cancelled or updated
          if (result == true) {
            // Refresh the appointment list
            setState(() {
              // In a real app, you would fetch updated data from API
              // For now, we'll just trigger a rebuild
            });
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lịch hẹn đã được cập nhật'),
                backgroundColor: Colors.green[600],
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment['subject'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(appointmentDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment['location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    appointment['appointmentType'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (appointment['cancellationReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.red[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancelled: ${appointment['cancellationReason']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Không có lịch hẹn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Thử điều chỉnh bộ lọc hoặc tạo lịch hẹn mới',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}