import 'package:get/get.dart';

class AppController {
  static Map<String, double> productDepositPercentage = {};
  
  static double getProductDepositPercentage(String productId) {
    return productDepositPercentage[productId] ?? 0;
  }
}