import 'package:cfv_mobile/data/responses/review_response.dart';
import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:get/get.dart';

class ReviewRepository extends GetxService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getReviews(String productId) async {
    try {
      final response = await _apiService.dio.get('/retailer/products/$productId/reviews');
      return response.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderReviewResponse> createReview({
    required String retailerId,
    required String orderId,
    required String detailId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/retailer/$retailerId/orders/$orderId/details/$detailId/reviews',
        data: {'rating': rating, 'comment': comment},
      );
      return OrderReviewResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderReviewResponse> getReview(String retailerId, String orderId, String detailId) async {
    try {
      final response = await _apiService.dio.get('/retailer/$retailerId/orders/$orderId/details/$detailId/review');
      return OrderReviewResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
