import 'dart:math';

import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartRepository extends GetxController {
  // Provides a static instance getter for easy access throughout your app
  static CartRepository get instance => Get.find();

  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    debugPrint('CartRepository onReady: Initialized successfully.');
  }

  Future<bool> updateCart({String? retailerId, List<CartResponse> cartItems = const []}) async {
    try {
      debugPrint('Updating cart: $cartItems');
      final response = await _apiService.dio.put('/retailer/$retailerId/carts', data: cartItems);
      return true;
    } catch (e) {
      debugPrint('Error updating cart: $e');
      return false;
    }
  }

  Future<List<CartResponse>?> fetchCartDetails(String userId) async {
    try {
      final response = await _apiService.dio.get('/retailer/$userId/carts');
      if (response.data != null && response.data is List) {
        debugPrint('Cart details loaded successfully: ${(response.data as List).length} items found.');
        return (response.data as List).map((e) => CartResponse.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        debugPrint('Failed to load cart details for user ID: $userId');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading cart details: $e');
      return null;
    }
  }
}
