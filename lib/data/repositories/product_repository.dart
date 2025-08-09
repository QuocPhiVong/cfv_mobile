import 'package:cfv_mobile/data/responses/product_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxController {
  // Provides a static instance getter for easy access throughout your app
  static ProductRepository get instance => Get.find();

  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    debugPrint('ProductRepository onReady: Initialized successfully.');
  }

  Future<ProductModel?> fetchProductDetails(String productId) async {
    try {
      final response = await _apiService.dio.get('/products/$productId');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return null; // Return null to indicate failure
    }
  }

  Future<ProductPriceModel?> fetchProductPrices(String productId) async {
    try {
      final response = await _apiService.dio.get('/products/$productId/prices');
      return ProductPriceModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching product prices: $e');
      return null; // Return null to indicate failure
    }
  }

  Future<ProductCertificateModel?> fetchProductCertificates(String productId) async {
    try {
      final response = await _apiService.dio.get('/products/$productId/product-certificates');
      return response.data; // Assuming the response is a list of certificates
    } catch (e) {
      debugPrint('Error fetching product certificates: $e');
      return null; // Return null to indicate failure
    }
  }
}
