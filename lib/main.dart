import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/repositories/auth_repository.dart'; // Import the AuthenticationRepository
import 'package:cfv_mobile/screens/authentication/login_screen.dart';
import 'package:cfv_mobile/screens/home/main_screen.dart';
import 'package:cfv_mobile/data/services/api_services.dart'; // Assuming ApiService is still a singleton

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service (if it's a singleton that needs to be instantiated early)
  ApiService();

  // IMPORTANT: Register AuthenticationRepository first, as AuthenticationController depends on it.
  Get.put(AuthenticationRepository());

  // Then, initialize your AuthenticationController with GetX
  Get.put(AuthenticationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of your AuthenticationController
    final AuthenticationController authController = Get.find<AuthenticationController>();

    return GetMaterialApp( // Use GetMaterialApp instead of MaterialApp
      title: 'Clean Food Viet',
      theme: ThemeData(
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Use Obx to reactively build the home screen based on authController's state
      home: Obx(() {
        // Show loading screen while initializing or checking auth status
        if (authController.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on authentication status
        if (authController.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}