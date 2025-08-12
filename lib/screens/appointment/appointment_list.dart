import 'package:cfv_mobile/screens/appointment/appointment_detail.dart';
import 'package:cfv_mobile/controller/appointment_controller.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentListScreen extends GetView<AppointmentController> {
  final RxString selectedFilterRx = 'All'.obs;

  AppointmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    Get.put(AppointmentController());
    
    // Load appointments on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.appointments.isEmpty) {
        controller.getAppointments(refresh: true);
      }
    });

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
            child: Obx(() => _buildBody()),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.appointments.isEmpty) {
      return _buildLoadingState();
    }
    
    if (controller.errorMessage.isNotEmpty && controller.appointments.isEmpty) {
      return _buildErrorState();
    }
    
    final filteredAppointments = _getFilteredAppointments();
    
    if (filteredAppointments.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildAppointmentList(filteredAppointments);
  }

  List<AppointmentData> _getFilteredAppointments() {
    if (selectedFilterRx.value == 'All') {
      return controller.appointments;
    }
    return controller.appointments.where((apt) => 
      apt.status?.toLowerCase() == selectedFilterRx.value.toLowerCase()
    ).toList();
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
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: Obx(() {
              final isSelected = selectedFilterRx.value == filter;
              return FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  selectedFilterRx.value = filter;
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.green[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green[700] : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentData> appointments) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.getAppointments(refresh: true);
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: appointments.length + (controller.isLoading.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == appointments.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentData appointment) {
    final appointmentDate = appointment.appointmentDate ?? DateTime.now();
    final status = appointment.status ?? 'unknown';
    
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
          final result = await Get.to(() => AppointmentDetailScreen(
            appointmentId: appointment.appointmentId ?? '',
          ));
          
          // Handle result if appointment was cancelled or updated
          if (result == true) {
            // Refresh the appointment list
            await controller.getAppointments(refresh: true);
            
            // Show success message
            Get.snackbar(
              'Thành công',
              'Lịch hẹn đã được cập nhật',
              backgroundColor: Colors.green[600],
              colorText: Colors.white,
              duration: Duration(seconds: 2),
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
                      appointment.subject ?? 'No subject',
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
                      appointment.location ?? appointment.address ?? 'No location',
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
                    (appointment.appointmentType ?? 'Unknown').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (appointment.cancellationReason != null) ...[
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
                          'Cancelled: ${appointment.cancellationReason}',
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang tải lịch hẹn...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.getAppointments(refresh: true);
            },
            child: Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
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