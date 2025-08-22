import 'dart:ui';

import 'package:cfv_mobile/map_parser.dart';
import 'package:flutter/material.dart';

class CategoriesResponse {
  final List<CategoryModel> categories;

  CategoriesResponse({required this.categories});

  factory CategoriesResponse.fromJson(List<dynamic> json) {
    var categoryList = json.map((category) => CategoryModel.fromJson(category)).toList();

    return CategoriesResponse(categories: categoryList);
  }
}

class CategoryModel {
  final String? productCategoryId;
  final String name;
  final String? description;

  CategoryModel({required this.name, required this.productCategoryId, required this.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      productCategoryId: json['productCategoryId'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'productCategoryId': productCategoryId, 'name': name, 'description': description};
  }
}

class GardenersResponse {
  final List<GardenersModel> gardeners;

  GardenersResponse({required this.gardeners});

  factory GardenersResponse.fromJson(Map<String, dynamic> json) {
    var gardenersList = (json['items'] as List).map((gardener) => GardenersModel.fromJson(gardener)).toList();

    return GardenersResponse(gardeners: gardenersList);
  }
}

class GardenersModel {
  final String? accountId;
  final String? name;
  final String? bio;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? avatar;
  final String? status;
  final bool? isVerified;
  final DateTime? createAt;
  final DateTime? updatedAt;
  final String? roleName;
  final List<CertificateModel>? certificates;
  final List<AddressModel>? addresses;

  GardenersModel({
    this.accountId,
    this.name,
    this.bio,
    this.email,
    this.phoneNumber,
    this.gender,
    this.avatar,
    this.status,
    this.isVerified,
    this.createAt,
    this.updatedAt,
    this.roleName,
    this.certificates,
    this.addresses,
  });

  factory GardenersModel.fromJson(Map<String, dynamic> json) {
    return GardenersModel(
      accountId: json['accountId'],
      name: json['name'],
      bio: json['bio'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      avatar: json['avatar'],
      status: json['status'],
      isVerified: json['isVerified'],
      createAt: json['createAt'] != null ? DateTime.parse(json['createAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      roleName: json['roleName'],
      certificates: json['certificates'] != null
          ? (json['certificates'] as List).map((i) => CertificateModel.fromJson(i)).toList()
          : null,
      addresses: json['addresses'] != null
          ? (json['addresses'] as List).map((i) => AddressModel.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'name': name,
      'bio': bio,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'avatar': avatar,
      'status': status,
      'isVerified': isVerified,
      'createAt': createAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'roleName': roleName,
      'certificates': certificates?.map((i) => i.toJson()).toList(),
      'addresses': addresses?.map((i) => i.toJson()).toList(),
    };
  }
}

class AddressModel {
  final String? addressId;
  final String? addressLine;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  AddressModel({this.addressId, this.addressLine, this.city, this.province, this.postalCode, this.country});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['addressId'],
      addressLine: json['addressLine'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'addressLine': addressLine,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class CertificateModel {
  final String? certificateId;
  final String? name;
  final String? imageUrl;
  final String? issuingAuthority;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? status;

  CertificateModel({
    this.certificateId,
    this.name,
    this.imageUrl,
    this.issuingAuthority,
    this.issueDate,
    this.expiryDate,
    this.status,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certificateId: json['certificateId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      issuingAuthority: json['issuingAuthority'],
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'name': name,
      'imageUrl': imageUrl,
      'issuingAuthority': issuingAuthority,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status,
    };
  }
}

class PostsResponse {
  final List<PostModel> posts;

  PostsResponse({required this.posts});

  factory PostsResponse.fromJson(List<dynamic> json) {
    var postsList = json.map((post) => PostModel.fromJson(post)).toList();

    return PostsResponse(posts: postsList);
  }
}

class PostModel {
  final String? postId;
  final String? title;
  final double? price;
  final String? currency;
  final String? thumbNail;
  final String? gardenerName;
  final String? gardenerAvatar;
  final DateTime? createdAt;
  final String? content;
  final String? status;
  final double? rating;
  final String? weightUnit;
  final bool? hasProductCertificate;
  final String? productId;
  final String? gardenerId;
  final String? harvestStatus;
  final double? depositPercentage;
  
  (String, IconData) get harvestStatusData {
    final Map<String, (String, IconData)> harvestStatusMap = {
      "PREORDEROPEN": (
        "Mở đặt cọc",
        Icons.agriculture,
      ),
      "PLANTING": (
        "Đang trồng",
        Icons.agriculture,
      ),
      "HARVESTING": (
        "Thu hoạch",
        Icons.agriculture,
      ),
      "PROCESSING": (
        "Đóng gói",
        Icons.local_shipping,
      ),
      "READYFORSALE": (
        "Có hàng",
        Icons.store,
      ),
      "COMPLETED": (
        "Đã thu hoạch",
        Icons.check_circle,
      ),
    };
    return harvestStatusMap[harvestStatus] ?? ('', Icons.agriculture);
  }

  PostModel({
    this.postId,
    this.title,
    this.price,
    this.currency,
    this.thumbNail,
    this.gardenerName,
    this.gardenerAvatar,
    this.createdAt,
    this.content,
    this.status,
    this.rating,
    this.weightUnit,
    this.hasProductCertificate,
    this.productId,
    this.gardenerId,
    this.harvestStatus,
    this.depositPercentage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    postId: json["postId"],
    title: json["title"],
    price: json["price"],
    currency: json["currency"],
    thumbNail: json["thumbNail"],
    gardenerName: json["gardenerName"],
    gardenerAvatar: json["gardenerAvatar"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    content: json["content"],
    status: json["status"],
    rating: json["rating"],
    weightUnit: json["weightUnit"],
    hasProductCertificate: json["hasProductCertificate"],
    productId: json["productId"],
    gardenerId: json["gardenerId"],
    harvestStatus: json["harvestStatus"],
    depositPercentage: json.parseDouble("depositPercentage") 
  );

  Map<String, dynamic> toJson() => {
    "postId": postId,
    "title": title,
    "price": price,
    "currency": currency,
    "thumbNail": thumbNail,
    "gardenerName": gardenerName,
    "gardenerAvatar": gardenerAvatar,
    "createdAt": createdAt?.toIso8601String(),
    "content": content,
    "status": status,
    "rating": rating,
    "weightUnit": weightUnit,
    "hasProductCertificate": hasProductCertificate,
    "productId": productId,
    "gardenerId": gardenerId,
    "harvestStatus": harvestStatus,
    "depositPercentage": depositPercentage,
  };
}
