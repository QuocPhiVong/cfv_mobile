import 'package:cfv_mobile/data/repositories/oder_repository.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/data/responses/oder_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OderController extends GetxController {
  final OderRepository oderRepository = OderRepository();

  Rx<bool> isLoading = true.obs;
  RxList<AddressModel> addresses = RxList<AddressModel>();

  @override
  void onReady() {
    super.onReady();
    debugPrint('OderController onReady: Initialized successfully.');
  }

  Future<void> getAddress(String id) async {
    isLoading.value = true;
    try {
      final response = await oderRepository.getAddress(id);
      isLoading.value = false;
      addresses.value = response?.addresses ?? [];
    } catch (e) {
      isLoading.value = false;
      throw Exception(e);
    }
  }

  Future<bool?> createOder(String id, String paymentMethod, List<CartResponse> data) async {
    try {
      final response = await oderRepository.createOder(id, paymentMethod, data);
      return response;
    } catch (e) {
      return false;
    }
  }
}
