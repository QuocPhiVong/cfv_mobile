class AddressResponse {
  final List<AddressModel>? addresses;

  AddressResponse({this.addresses});

  factory AddressResponse.fromJson(List<dynamic> json) =>
      AddressResponse(addresses: List<AddressModel>.from(json.map((x) => AddressModel.fromJson(x))));
}

class AddressModel {
  final String? addressId;
  final String? addressLine;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  AddressModel({this.addressId, this.addressLine, this.city, this.province, this.postalCode, this.country});

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    addressId: json["addressId"],
    addressLine: json["addressLine"],
    city: json["city"],
    province: json["province"],
    postalCode: json["postalCode"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "addressId": addressId,
    "addressLine": addressLine,
    "city": city,
    "province": province,
    "postalCode": postalCode,
    "country": country,
  };
}

class OrderResponse {
  final List<OrderModel>? orders;

  OrderResponse({this.orders});

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      OrderResponse(orders: List<OrderModel>.from(json["items"].map((x) => OrderModel.fromJson(x))));
}

class OrderModel {
  final String? orderId;
  final String? retailerId;
  final String? retailerName;
  final String? gardenerId;
  final String? status;
  final int? totalAmount;
  final int? shippingCost;
  final DateTime? createdAt;
  final int? productTypeAmount;

  OrderModel({
    this.orderId,
    this.retailerId,
    this.retailerName,
    this.gardenerId,
    this.status,
    this.totalAmount,
    this.shippingCost,
    this.createdAt,
    this.productTypeAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    orderId: json["orderId"],
    retailerId: json["retailerId"],
    retailerName: json["retailerName"],
    gardenerId: json["gardenerId"],
    status: json["status"],
    totalAmount: json["totalAmount"],
    shippingCost: json["shippingCost"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    productTypeAmount: json["productTypeAmount"],
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "retailerId": retailerId,
    "retailerName": retailerName,
    "gardenerId": gardenerId,
    "status": status,
    "totalAmount": totalAmount,
    "shippingCost": shippingCost,
    "createdAt": createdAt?.toIso8601String(),
    "productTypeAmount": productTypeAmount,
  };
}
