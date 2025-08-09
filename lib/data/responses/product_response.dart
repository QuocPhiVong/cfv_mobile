class ProductModel {
  final String? productId;
  final String? productName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final String? productCategory;
  final List<String>? productTags;
  final String? productPriceId;
  final double? price;
  final String? currency;
  final DateTime? availabledDate;
  final String? weightUnit;

  ProductModel({
    this.productId,
    this.productName,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.productCategory,
    this.productTags,
    this.productPriceId,
    this.price,
    this.currency,
    this.availabledDate,
    this.weightUnit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productId: json["productId"],
    productName: json["productName"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    status: json["status"],
    productCategory: json["productCategory"],
    productTags: json["productTags"] == null ? [] : List<String>.from(json["productTags"]!.map((x) => x)),
    productPriceId: json["productPriceId"],
    price: json["price"],
    currency: json["currency"],
    availabledDate: json["availabledDate"] == null ? null : DateTime.parse(json["availabledDate"]),
    weightUnit: json["weightUnit"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "productName": productName,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "status": status,
    "productCategory": productCategory,
    "productTags": productTags == null ? [] : List<dynamic>.from(productTags!.map((x) => x)),
    "productPriceId": productPriceId,
    "price": price,
    "currency": currency,
    "availabledDate": availabledDate?.toIso8601String(),
    "weightUnit": weightUnit,
  };
}

class ProductResponse {
  List<ProductPriceModel>? productPrices;

  ProductResponse({this.productPrices});
  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      productPrices: json['items'] != null
          ? List<ProductPriceModel>.from(json['productPrices'].map((x) => ProductPriceModel.fromJson(x)))
          : [],
    );
  }
}

class ProductPriceModel {
  final String? productPriceId;
  final double? price;
  final String? currency;
  final String? weightUnit;
  final DateTime? availabledDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCurrent;

  ProductPriceModel({
    this.productPriceId,
    this.price,
    this.currency,
    this.weightUnit,
    this.availabledDate,
    this.createdAt,
    this.updatedAt,
    this.isCurrent,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) => ProductPriceModel(
    productPriceId: json["productPriceId"],
    price: json["price"],
    currency: json["currency"],
    weightUnit: json["weightUnit"],
    availabledDate: json["availabledDate"] == null ? null : DateTime.parse(json["availabledDate"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    isCurrent: json["isCurrent"],
  );

  Map<String, dynamic> toJson() => {
    "productPriceId": productPriceId,
    "price": price,
    "currency": currency,
    "weightUnit": weightUnit,
    "availabledDate": availabledDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "isCurrent": isCurrent,
  };
}

class ProductCertificateModel {
  final String? productPriceId;
  final int? price;
  final String? currency;
  final String? weightUnit;
  final DateTime? availabledDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCurrent;

  ProductCertificateModel({
    this.productPriceId,
    this.price,
    this.currency,
    this.weightUnit,
    this.availabledDate,
    this.createdAt,
    this.updatedAt,
    this.isCurrent,
  });

  factory ProductCertificateModel.fromJson(Map<String, dynamic> json) => ProductCertificateModel(
    productPriceId: json["productPriceId"],
    price: json["price"],
    currency: json["currency"],
    weightUnit: json["weightUnit"],
    availabledDate: json["availabledDate"] == null ? null : DateTime.parse(json["availabledDate"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    isCurrent: json["isCurrent"],
  );

  Map<String, dynamic> toJson() => {
    "productPriceId": productPriceId,
    "price": price,
    "currency": currency,
    "weightUnit": weightUnit,
    "availabledDate": availabledDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "isCurrent": isCurrent,
  };
}
