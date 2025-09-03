import 'package:cfv_mobile/data/repositories/oder_repository.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/data/responses/oder_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OderController extends GetxController {
  final OderRepository oderRepository = OderRepository();

  Rx<bool> isLoadingAddress = true.obs;
  RxList<AddressModel> addresses = RxList<AddressModel>();
  Rx<bool> isLoadingOrders = true.obs;
  RxList<OrderModel> orders = RxList<OrderModel>();

  Rx<String> updatingStatusOrderId = ''.obs;

  @override
  void onReady() {
    super.onReady();
    debugPrint('OderController onReady: Initialized successfully.');
  }

  Future<void> getAddress(String id) async {
    isLoadingAddress.value = true;
    try {
      final response = await oderRepository.getAddress(id);
      isLoadingAddress.value = false;
      addresses.value = response?.addresses ?? [];
    } catch (e) {
      isLoadingAddress.value = false;
      throw Exception(e);
    }
  }

  Future<bool?> createOder(String id, String paymentMethod, List<CartResponse> data, List<String> contractImage) async {
    try {
      final response = await oderRepository.createOder(id, paymentMethod, data, contractImage);
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<OrderResponse> getOrders(String accountId, int page, int size) async {
    isLoadingOrders.value = true;
    try {
      final response = await oderRepository.getOrders(accountId, page, size);
      isLoadingOrders.value = false;
      orders.value = response.orders ?? [];
      return response;
    } catch (e) {
      isLoadingOrders.value = false;
      throw Exception(e);
    }
  }

  Future<bool> updateStatusOrder(String id, String status) async {
    updatingStatusOrderId.value = id;
    try {
      final response = await oderRepository.updateStatusOrder(id, status);
      updatingStatusOrderId.value = '';
      return response;
    } catch (e) {
      updatingStatusOrderId.value = '';
      return false;
    }
  }

  Future<List<String>> uploadImage(List<PlatformFile> files) async {
    try {
      List<String> result = [];
      for (var file in files) {
        final response = await CloudinaryService().uploadImageFromPlatformFile(file);
        result.add(response);
      }
      return result;
    } catch (e) {
      return [];
    }
  }
}
