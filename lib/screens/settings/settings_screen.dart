import 'package:cfv_mobile/screens/order/order_history.dart';
import 'package:cfv_mobile/screens/settings/profile_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vòng Quốc Phi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0982912617',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Handle view profile action
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                ],
              ),
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
                      print('Orders tapped');
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Quản lý lịch hẹn',
                    onTap: () {
                      print('Manage appointments tapped');
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Lịch sử đặt hàng',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistoryScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Gửi báo cáo',
                    onTap: () {
                      print('Send report tapped');
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.power_settings_new,
                    title: 'Đăng xuất',
                    onTap: () {
                      _showLogoutDialog(context);
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
            Icon(
              icon,
              size: 24,
              color: isLogout ? Colors.red.shade600 : Colors.grey.shade600,
            ),
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
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất không?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout logic here
                _handleLogout(context);
              },
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    // Add your logout logic here
    // For example: clear user data, navigate to login screen
    print('User logged out');
    
    // Example navigation to login screen
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    //   (route) => false,
    // );
  }
}