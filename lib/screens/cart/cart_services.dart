import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final String priceText;
  final String garden;
  final String phone;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.priceText,
    required this.garden,
    required this.phone,
    this.category = 'Củ Quả',
    this.quantity = 1,
  });

  double get totalPrice => double.parse(price.replaceAll(',', '')) * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? price,
    String? priceText,
    String? garden,
    String? phone,
    String? category,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      priceText: priceText ?? this.priceText,
      garden: garden ?? this.garden,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  String get formattedTotalPrice {
    return totalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void addItem(CartItem item) {
    // Check if item already exists in cart
    final existingIndex = _items.indexWhere((cartItem) => 
      cartItem.name == item.name && cartItem.garden == item.garden);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _items.add(item);
    }
    
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String name, String garden) {
    return _items.any((item) => item.name == name && item.garden == garden);
  }

  CartItem? getCartItem(String name, String garden) {
    try {
      return _items.firstWhere((item) => item.name == name && item.garden == garden);
    } catch (e) {
      return null;
    }
  }
}