class CartResponse {
  final String? cartId;
  final String retailerId;
  final String gardenerId;
  final String gardenerName;
  final String? contractImage;
  final List<CartItemModel>? cartItems;
  double get totalPrice =>
      cartItems?.fold(0.0, (sum, item) => (sum ?? 0.0) + ((item.price ?? 0.0) * (item.quantity ?? 1))) ?? 0.0;
  int get itemCount => cartItems?.fold(0, (count, item) => (count ?? 0) + (item.quantity ?? 0)) ?? 0;

  CartResponse(this.cartId, this.retailerId, this.gardenerId, this.gardenerName, this.contractImage, {this.cartItems});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      json['cartId'],
      json['retailerId'],
      json['gardenerId'],
      json['gardenerName'],
      json['contractImage'],
      cartItems: (json['cartItems'] as List<dynamic>?)?.map((item) => CartItemModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'retailerId': retailerId,
      'gardenerId': gardenerId,
      'gardenerName': gardenerName,
      'cartItems': cartItems?.map((item) => item.toJson()).toList(),
      if (contractImage != null) 'contractImage': contractImage,
    };
  }

  copyWith({required String contractImage}) {
    return CartResponse(cartId, retailerId, gardenerId, gardenerName, contractImage, cartItems: cartItems);
  }
}

class CartItemModel {
  final String? cartItemId;
  String? cartId;
  final String? productId;
  final String? productName;
  final double? price;
  int? quantity;
  final String? productUnit;
  final double? depositAmount;
  final int? depositPercentage;
  final String? postId;

  CartItemModel({
    this.cartItemId,
    this.cartId,
    this.productId,
    this.productName,
    this.price,
    this.quantity,
    this.productUnit,
    this.depositAmount,
    this.depositPercentage = 0,
    this.postId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    cartItemId: json["cartItemId"],
    cartId: json["cartId"],
    productId: json["productId"],
    productName: json["productName"],
    price: json["price"],
    quantity: json["quantity"],
    productUnit: json["productUnit"],
    depositAmount: json["depositAmount"] ?? (json["price"] ?? 0) * (json["depositPercentage"] / 100),
    depositPercentage: json["depositPercentage"],
    postId: json["postId"],
  );

  Map<String, dynamic> toJson() => {
    "cartItemId": cartItemId,
    "cartId": cartId,
    "productId": productId,
    "productName": productName,
    "price": price,
    "quantity": quantity,
    "productUnit": productUnit,
    "depositAmount": depositAmount ?? (price ?? 0) * (depositPercentage ?? 0.0),
    "depositPercentage": depositPercentage,
    "postId": postId,
  };
}
