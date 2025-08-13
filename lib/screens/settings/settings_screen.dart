import 'package:cfv_mobile/screens/appointment/appointment_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:cfv_mobile/controller/auth_controller.dart'; // Import your AuthController
import 'package:cfv_mobile/screens/authentication/login_screen.dart'; // Import LoginScreen
import 'package:cfv_mobile/screens/order/order_history.dart';
import 'package:cfv_mobile/screens/settings/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of your AuthenticationController
    final AuthenticationController authController = Get.find<AuthenticationController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // User profile section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Obx(() {
                // Use Obx to react to changes in currentUser
                final user = authController.currentUser;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Tên người dùng', // Display user's name
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.phoneNumber ?? 'Số điện thoại', // Display user's phone number
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Handle view profile action
                              Get.to(() => ProfileScreen()); // Use Get.to for navigation
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Xem hồ sơ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade700),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade400),
                      child: Icon(Icons.person, color: Colors.grey.shade600, size: 24),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 30),

            // Menu items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Đơn hàng của bạn',
                    onTap: () {
                      Get.to(() => OrderListScreen()); // Use Get.to for navigation
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Quản lý lịch hẹn',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AppointmentListScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.location_pin,
                    title: 'Địa chỉ',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AppointmentListScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Gửi báo cáo',
                    onTap: () {
                      print('Send report tapped');
                      // Example: Get.to(() => ReportScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.power_settings_new,
                    title: 'Đăng xuất',
                    onTap: () {
                      _showLogoutDialog(context, authController); // Pass authController
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isLogout ? Colors.red.shade600 : Colors.grey.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red.shade600 : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 20), height: 1, color: Colors.grey.shade200);
  }

  void _showLogoutDialog(BuildContext context, AuthenticationController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Đăng xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
                await _handleLogout(authController); // Call the logout function
              },
              child: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Modified _handleLogout to use the AuthenticationController
  Future<void> _handleLogout(AuthenticationController authController) async {
    print('Attempting user logout...');
    await authController.logout(); // Call the logout method from the controller

    // After logout, navigate to the LoginScreen and remove all previous routes
    Get.offAll(() => const LoginScreen());
    print('User logged out and navigated to LoginScreen');
  }
}
