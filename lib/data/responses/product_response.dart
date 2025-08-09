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
  final String? gardenerId;
  final String? gardenerName;

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
    this.gardenerId,
    this.gardenerName,
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
    gardenerId: json["gardenerId"],
    gardenerName: json["gardenerName"],
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
    "gardenerId": gardenerId,
    "gardenerName": gardenerName,
  };
}

class ProductPricesResponse {
  List<ProductPriceModel>? productPrices;

  ProductPricesResponse({this.productPrices});
  factory ProductPricesResponse.fromJson(List<dynamic> json) {
    return ProductPricesResponse(productPrices: json.map((x) => ProductPriceModel.fromJson(x)).toList());
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

class ProductCertificateResponse {
  List<ProductCertificateModel>? productCertificates;

  ProductCertificateResponse({this.productCertificates});

  factory ProductCertificateResponse.fromJson(List<dynamic> json) {
    return ProductCertificateResponse(
      productCertificates: json.map((x) => ProductCertificateModel.fromJson(x)).toList(),
    );
  }
}

class ProductCertificateModel {
  final String? productCertificateId;
  final String? certificateName;
  final String? issuingOrganization;
  final String? certificateNumber;
  final DateTime? issuedDate;
  final DateTime? expirationDate;
  final String? imageUrl;

  ProductCertificateModel({
    this.productCertificateId,
    this.certificateName,
    this.issuingOrganization,
    this.certificateNumber,
    this.issuedDate,
    this.expirationDate,
    this.imageUrl,
  });

  factory ProductCertificateModel.fromJson(Map<String, dynamic> json) => ProductCertificateModel(
    productCertificateId: json["productCertificateId"],
    certificateName: json["certificateName"],
    issuingOrganization: json["issuingOrganization"],
    certificateNumber: json["certificateNumber"],
    issuedDate: json["issuedDate"] == null ? null : DateTime.parse(json["issuedDate"]),
    expirationDate: json["expirationDate"] == null ? null : DateTime.parse(json["expirationDate"]),
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "productCertificateId": productCertificateId,
    "certificateName": certificateName,
    "issuingOrganization": issuingOrganization,
    "certificateNumber": certificateNumber,
    "issuedDate": issuedDate?.toIso8601String(),
    "expirationDate": expirationDate?.toIso8601String(),
    "imageUrl": imageUrl,
  };
}
