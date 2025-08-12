import 'package:cfv_mobile/controller/cart_controller.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/data/responses/oder_response.dart';
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

  Future<AddressResponse?> getAddress(String id) async {
    try {
      final response = await _apiService.get('/accounts/$id/addresses');
      return AddressResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool?> createOder(String id, String paymentMethod, List<CartResponse> data) async {
    try {
      final response = await _apiService.post(
        '/orders/$id',
        queryParameters: {'paymentMethod': paymentMethod.toUpperCase()},
        data: data.map((e) => e.toJson()).toList(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
