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

  Future<bool> addToCart({
    required String retailerId,
    required String gardenerId,
    required String gardenerName,
    required CartItemModel cartItem,
  }) async {
    isLoading.value = true;
    try {
      await loadCarts(retailerId); // Ensure cart is loaded before adding items
      List<CartItemModel> temp = cartItems.value;

      temp.add(cartItem);

      for (CartItemModel item in temp) {
        item.cartId = cartItems.value.isNotEmpty ? cartItems.value.first.cartId : null;
      }

      final response = await _cartRepository.addToCart(
        cartId: cartItem.cartId,
        retailerId: retailerId,
        cartItem: temp,
        gardenerId: gardenerId,
        gardenerName: gardenerName,
      );
      if (response != null) {
        debugPrint('Added to cart successfully: $response');
        await loadCarts(retailerId); // Refresh cart items after adding
        return true;
      } else {
        debugPrint('Failed to add items to cart for retailer ID: $retailerId');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      isLoading.value = false;

      return false;
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
