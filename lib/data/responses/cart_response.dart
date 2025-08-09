class CartResponse {
  final List<CartItemModel>? cartItems;

  CartResponse({this.cartItems});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(cartItems: (json['items'] as List?)?.map((item) => CartItemModel.fromJson(item)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'items': cartItems?.map((item) => item.toJson()).toList()};
  }
}

class CartItemModel {
  final String? cartItemId;
  String? cartId;
  final String? productId;
  final String? productName;
  final double? price;
  final int? quantity;
  final String? productUnit;

  CartItemModel({
    this.cartItemId,
    this.cartId,
    this.productId,
    this.productName,
    this.price,
    this.quantity,
    this.productUnit,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    cartItemId: json["cartItemId"],
    cartId: json["cartId"],
    productId: json["productId"],
    productName: json["productName"],
    price: json["price"],
    quantity: json["quantity"],
    productUnit: json["productUnit"],
  );

  Map<String, dynamic> toJson() => {
    "cartItemId": cartItemId,
    "cartId": cartId,
    "productId": productId,
    "productName": productName,
    "price": price,
    "quantity": quantity,
    "productUnit": productUnit,
  };
}
