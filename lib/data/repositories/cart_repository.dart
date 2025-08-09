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

  Future<dynamic> addToCart(String retailerId, List<CartItemModel> cartItem) async {
    try {
      await fetchCartDetails(retailerId);

      final response = await _apiService.dio.post(
        '/retailer/$retailerId/carts',
        data: {
          // "cartId": {},
          "retailerId": retailerId,
          // "gardenerId": {},
          // "gardenerName": "string",
          "cartItems": cartItem.map((item) => item.toJson()).toList(),
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return null;
    }
  }

  Future<CartResponse?> fetchCartDetails(String userId) async {
    try {
      final response = await _apiService.dio.get('/retailer/$userId/carts');
      if (response.data != null) {
        debugPrint('Cart details loaded successfully: ${response.data} items found.');
        return CartResponse.fromJson(response.data);
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
