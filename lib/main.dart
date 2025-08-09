import 'package:cfv_mobile/controller/cart_controller.dart';
import 'package:cfv_mobile/controller/home_controller.dart';
import 'package:cfv_mobile/controller/product_controller.dart';
import 'package:cfv_mobile/data/repositories/cart_repository.dart';
import 'package:cfv_mobile/data/repositories/home_repository.dart';
import 'package:cfv_mobile/data/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/repositories/auth_repository.dart'; // Import the AuthenticationRepository
import 'package:cfv_mobile/screens/authentication/login_screen.dart';
import 'package:cfv_mobile/screens/home/main_screen.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);

  // Initialize API service (if it's a singleton that needs to be instantiated early)
  ApiService();

  // IMPORTANT: Register AuthenticationRepository first, as AuthenticationController depends on it.
  Get.put(AuthenticationRepository());
  Get.put(HomeRepository());
  Get.put(ProductRepository());
  Get.put(CartRepository());

  // Then, initialize your AuthenticationController with GetX
  Get.put(AuthenticationController());
  Get.put(HomeController());
  Get.put(ProductController());
  Get.put(CartController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of your AuthenticationController
    final AuthenticationController authController = Get.find<AuthenticationController>();

    return GetMaterialApp(
      // Use GetMaterialApp instead of MaterialApp
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
