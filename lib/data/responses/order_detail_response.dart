import 'package:cfv_mobile/map_parser.dart';
import 'package:flutter/material.dart';

class OrderDetailResponse {
  final String orderId;
  final String retailerId;
  final String gardenerId;
  final String accountName;
  final String phoneNumber;
  final String status;
  final int totalAmount;
  final int shippingCost;
  final String paymentMethod;
  final String createdAt;
  final String? cancelReason;
  final String shippingAddress;
  final int totalDepositAmount;
  final List<OrderDetail> orderDetails;
  final List<String>? contractImage;

  Color get statusColor {
    switch (status) {
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

  OrderDetailResponse({
    required this.orderId,
    required this.retailerId,
    required this.gardenerId,
    required this.accountName,
    required this.phoneNumber,
    required this.status,
    required this.totalAmount,
    required this.shippingCost,
    required this.paymentMethod,
    required this.createdAt,
    this.cancelReason,
    required this.shippingAddress,
    required this.orderDetails,
    required this.totalDepositAmount,
    this.contractImage,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      orderId: json['orderId'] as String,
      retailerId: json['retailerId'] as String,
      gardenerId: json['gardenerId'] as String,
      accountName: json['accountName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: json['status'] as String,
      totalAmount: json.parseDouble('totalAmount')?.toInt() ?? 0,
      shippingCost: json.parseDouble('shippingCost')?.toInt() ?? 0,
      paymentMethod: json['paymentMethod'] as String,
      createdAt: json['createdAt'] as String,
      cancelReason: json['cancelReason'] as String?,
      shippingAddress: json['shippingAddress'] as String,
      totalDepositAmount: json.parseDouble('totalDepositAmount')?.toInt() ?? 0,
      contractImage: json['contractImage'] != null
          ? (json['contractImage'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      orderDetails: (json['orderDetails'] as List<dynamic>)
          .map((item) => OrderDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'retailerId': retailerId,
      'gardenerId': gardenerId,
      'accountName': accountName,
      'phoneNumber': phoneNumber,
      'status': status,
      'totalAmount': totalAmount,
      'shippingCost': shippingCost,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
      'cancelReason': cancelReason,
      'shippingAddress': shippingAddress,
      'totalDepositAmount': totalDepositAmount,
      'contractImage': contractImage,
      'orderDetails': orderDetails.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderDetail {
  final String orderDetailId;
  final int price;
  final int quantity;
  final String productUnit;
  final String deliveryStatus;
  final String productId;
  final String productName;
  final String weightUnit;
  final String currency;
  final int deliveredQuantity;
  final String harvestStatus;
  final int depositAmount;
  final int depositPercentage;

  OrderDetail({
    required this.orderDetailId,
    required this.price,
    required this.quantity,
    required this.productUnit,
    required this.deliveryStatus,
    required this.productId,
    required this.productName,
    required this.weightUnit,
    required this.currency,
    required this.deliveredQuantity,
    required this.harvestStatus,
    required this.depositAmount,
    required this.depositPercentage,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderDetailId: json['orderDetailId'] as String,
      price: json.parseDouble('price')?.toInt() ?? 0,
      quantity: json.parseInt('quantity') ?? 0,
      productUnit: json['productUnit'] as String,
      deliveryStatus: json['deliveryStatus'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      weightUnit: json['weightUnit'] as String,
      currency: json['currency'] as String,
      deliveredQuantity: json.parseDouble('deliveredQuantity')?.toInt() ?? 0,
      harvestStatus: json['harvestStatus'] as String,
      depositAmount: json.parseDouble('depositAmount')?.toInt() ?? 0,
      depositPercentage: json.parseDouble('depositPercentage')?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderDetailId': orderDetailId,
      'price': price,
      'quantity': quantity,
      'productUnit': productUnit,
      'deliveryStatus': deliveryStatus,
      'productId': productId,
      'productName': productName,
      'weightUnit': weightUnit,
      'currency': currency,
      'deliveredQuantity': deliveredQuantity,
      'harvestStatus': harvestStatus,
      'depositAmount': depositAmount,
      'depositPercentage': depositPercentage,
    };
  }
}
