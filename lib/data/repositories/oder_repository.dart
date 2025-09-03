import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/data/responses/order_deliveries_response.dart';
import 'package:cfv_mobile/data/responses/oder_response.dart';
import 'package:cfv_mobile/data/responses/order_detail_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OderRepository extends GetxController {
  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    super.onReady();
    debugPrint('OderRepository onReady: Initialized successfully.');
  }

  Future<bool> updateStatusOrder(String id, String status) async {
    try {
      await _apiService.patch('/orders/$id', queryParameters: {'status': status});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AddressResponse?> getAddress(String id) async {
    try {
      final response = await _apiService.get('/accounts/$id/addresses');
      return AddressResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool?> createOder(String id, String paymentMethod, List<CartResponse> data, List<String> contractImage) async {
    try {
      final newData = data.map((e) => e.copyWith(contractImage: contractImage)).toList();
      final response = await _apiService.post(
        '/orders/$id',
        queryParameters: {
          'paymentMethod': "COD", //paymentMethod.toUpperCase(),
          "shippingAddress": "39 Thạnh Xuân 18, Phường Thới An, Thành Phố Hồ Chí Minh", // "01JZ5RNPN3XX47MT6SJ7ZFX6AN",
        },
        data: newData.map((e) => e.toJson()).toList(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<OrderResponse> getOrders(String accountId, int page, int size) async {
    try {
      final response = await _apiService.get(
        '/accounts/$accountId/orders',
        queryParameters: {"page": page, "size": size},
      );
      return OrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderDetailResponse> getOrderDetail(String accountId, String id) async {
    try {
      final response = await _apiService.get('/accounts/$accountId/orders/$id');
      return OrderDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderDeliveriesResponse> getOrderDeliveries(String id) async {
    try {
      final response = await _apiService.get('/orders/$id/order-deliveries');
      return OrderDeliveriesResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
