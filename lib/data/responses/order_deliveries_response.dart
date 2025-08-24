import 'package:cfv_mobile/map_parser.dart';
import 'package:flutter/material.dart';

class OrderDeliveriesResponse {
  final List<OrderDeliveryModel> deliveries;

  OrderDeliveriesResponse({required this.deliveries});

  factory OrderDeliveriesResponse.fromJson(List<dynamic> json) {
    return OrderDeliveriesResponse(
      deliveries: json.map((item) => OrderDeliveryModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'deliveries': deliveries.map((item) => item.toJson()).toList()};
  }
}

class OrderDeliveryModel {
  final String orderDeliveryId;
  final String orderId;
  final String deliveryDate;
  final String deliveryStatus;
  final String createdAt;
  final String updatedAt;
  final String? note;
  final int totalAmount;
  final List<OrderDeliveryDetailModel> orderDeliveryDetails;

  Color get deliveryStatusColor {
    switch (deliveryStatus) {
      case 'PENDING':
        return Colors.orange;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  OrderDeliveryModel({
    required this.orderDeliveryId,
    required this.orderId,
    required this.deliveryDate,
    required this.deliveryStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.totalAmount,
    this.note,
    required this.orderDeliveryDetails,
  });

  factory OrderDeliveryModel.fromJson(Map<String, dynamic> json) {
    return OrderDeliveryModel(
      orderDeliveryId: json['orderDeliveryId'] as String,
      orderId: json['orderId'] as String,
      deliveryDate: json['deliveryDate'] as String,
      deliveryStatus: json['deliveryStatus'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      note: json['note'] as String?,
      totalAmount: json.parseDouble('totalAmount').toInt(),
      orderDeliveryDetails: (json['orderDeliveryDetails'] as List<dynamic>)
          .map((item) => OrderDeliveryDetailModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderDeliveryId': orderDeliveryId,
      'orderId': orderId,
      'deliveryDate': deliveryDate,
      'deliveryStatus': deliveryStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'note': note,
      'totalAmount': totalAmount,
      'orderDeliveryDetails': orderDeliveryDetails.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderDeliveryDetailModel {
  final String orderDeliveryDetailId;
  final String productId;
  final String productName;
  final String deliveredAt;
  final int quantity;
  final int price;
  final String productUnit;
  final String currency;

  OrderDeliveryDetailModel({
    required this.orderDeliveryDetailId,
    required this.productId,
    required this.productName,
    required this.deliveredAt,
    required this.quantity,
    required this.price,
    required this.productUnit,
    required this.currency,
  });

  factory OrderDeliveryDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDeliveryDetailModel(
      orderDeliveryDetailId: json['orderDeliveryDetailId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      deliveredAt: json['deliveredAt'] as String,
      quantity: json.parseDouble('quantity').toInt(),
      price: json.parseDouble('price').toInt(),
      productUnit: json['productUnit'] as String,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderDeliveryDetailId': orderDeliveryDetailId,
      'productId': productId,
      'productName': productName,
      'deliveredAt': deliveredAt,
      'quantity': quantity,
      'price': price,
      'productUnit': productUnit,
      'currency': currency,
    };
  }
}
