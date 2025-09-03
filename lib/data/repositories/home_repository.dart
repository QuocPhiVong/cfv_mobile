import 'package:cfv_mobile/data/responses/home_response.dart';
import 'package:cfv_mobile/data/responses/notification_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // Using the import path from your desired repo

class HomeRepository extends GetxController {
  // Provides a static instance getter for easy access throughout your app
  static HomeRepository get instance => Get.find();

  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    debugPrint('HomeRepository onReady: Initialized successfully.');
  }

  Future<CategoriesResponse?> fetchCategories() async {
    try {
      final response = await _apiService.dio.get(
        '/categories',
        queryParameters: {'page': 1, 'size': 10, 'fetchAll': true},
      );
      debugPrint('Home data fetched: ${response.data}');
      return CategoriesResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      return null; // Return null to indicate failure
    }
  }

  Future<GardenersResponse?> fetchGardeners() async {
    try {
      final response = await _apiService.dio.get('/accounts/gardeners', queryParameters: {'page': 1, 'size': 10});
      debugPrint('Gardeners data fetched: ${response.data}');
      return GardenersResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching gardeners data: $e');
      return null; // Return null to indicate failure
    }
  }

  Future<PostsResponse?> fetchPosts() async {
    try {
      final response = await _apiService.dio.get('/retailer/posts');
      debugPrint('Posts data fetched: ${response.data}');
      return PostsResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching posts data: $e');
      return null; // Return null to indicate failure
    }
  }

  Future<bool?> favPost(String retailerId, String postId) async {
    try {
      final response = await _apiService.dio.post('/retailer/$retailerId/fav-posts/$postId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<NotificationResponse?> fetchNotification({String? accountId}) async {
    try {
      final response = await _apiService.dio.get('/accounts/$accountId/notifications');
      return NotificationResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching notifications data: $e');
      return null;
    }
  }

  Future<bool?> createNotification({String? accountId, String? message, String? link, String? sender}) async {
    try {
      final response = await _apiService.dio.post(
        '/accounts/$accountId/notifications',
        data: {'accountId': accountId, 'message': message, 'link': link, 'sender': sender},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
