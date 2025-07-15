import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:cfv_mobile/screens/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service (this will create the singleton and initialize Dio)
  ApiService();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthenticationController()..initializeAuth(),
        ),
      ],
      child: MaterialApp(
        title: 'Clean Food Viet',
        theme: ThemeData(
          fontFamily: 'Manrope',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: Consumer<AuthenticationController>(
          builder: (context, authController, child) {
            // Show loading screen while initializing
            if (authController.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Navigate based on authentication status
            return const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}