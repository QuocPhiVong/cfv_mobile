import 'package:cfv_mobile/data/repositories/cart_repository.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository.instance;

  Rx<bool> isLoading = true.obs;
  RxList<CartItemModel> cartItems = RxList<CartItemModel>();

  @override
  void onReady() {
    super.onReady();
    debugPrint('CartController onReady: Initialized successfully.');
  }

  Future<void> addToCart(String retailerId, CartItemModel cartItem) async {
    isLoading.value = true;
    try {
      await loadCarts(retailerId); // Ensure cart is loaded before adding items
      List<CartItemModel> temp = cartItems.value;

      temp.add(cartItem);

      final response = await _cartRepository.addToCart(retailerId, temp);
      if (response != null) {
        debugPrint('Added to cart successfully: $response');
        await loadCarts(retailerId); // Refresh cart items after adding
      } else {
        debugPrint('Failed to add items to cart for retailer ID: $retailerId');
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCarts(String userId) async {
    isLoading.value = true;
    try {
      final data = await _cartRepository.fetchCartDetails(userId);
      if (data != null) {
        cartItems.value = data.cartItems ?? [];
        debugPrint('Cart details loaded successfully: ${data.toString()}');
      } else {
        debugPrint('Failed to load cart details for user ID: $userId');
      }
    } catch (e) {
      debugPrint('Error loading cart details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
