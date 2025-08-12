import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/repositories/cart_repository.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository.instance;

  Rx<bool> isLoading = true.obs;
  RxList<CartResponse> cartItems = RxList<CartResponse>();

  @override
  void onReady() {
    super.onReady();
    debugPrint('CartController onReady: Initialized successfully.');
  }

  void removeItem(String cartId) {
    cartItems.removeWhere((item) => item.cartId == cartId);

    _cartRepository.updateCart(
      retailerId: Get.find<AuthenticationController>().currentUser?.accountId ?? '',
      cartItems: cartItems, // Assuming CartItemModel has a constructor
    );
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
      List<CartResponse> temp = cartItems.value.toList();

      temp.add(CartResponse(null, retailerId, gardenerId, gardenerName, cartItems: [cartItem]));

      final response = await _cartRepository.updateCart(retailerId: retailerId, cartItems: temp);
      debugPrint('Added to cart successfully: $response');
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCarts(String userId) async {
    isLoading.value = true;
    try {
      final data = await _cartRepository.fetchCartDetails(userId);
      if (data != null) {
        cartItems.value = data ?? [];
        debugPrint('Cart details loaded successfully controller: ${data.length}');
      } else {
        debugPrint('Failed to load cart details for user ID: $userId');
      }
    } catch (e) {
      debugPrint('Error loading cart details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateQuantity(String? cartId, String? cartItemId, int i) {
    debugPrint('Updating quantity for item $cartItemId in cart $cartId to $i');
    final cart = cartItems.value.firstWhereOrNull((cart) => cart.cartId == cartId);
    if (cart != null) {
      final item = cart.cartItems?.firstWhereOrNull((item) => item.cartItemId == cartItemId);
      if (item != null) {
        item.quantity = i;
        _cartRepository.updateCart(
          retailerId: Get.find<AuthenticationController>().currentUser?.accountId ?? '',
          cartItems: cartItems.value,
        );
      }
    }
  }
}
