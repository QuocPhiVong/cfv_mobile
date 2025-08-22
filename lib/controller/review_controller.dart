import 'package:cfv_mobile/data/repositories/review_repositories.dart';
import 'package:cfv_mobile/data/responses/review_response.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  final ReviewRepository _reviewRepository = ReviewRepository();

  final Rx<bool> isLoadingReview = false.obs;
  final Rx<bool> isLoadingProductReview = false.obs;
  final Rx<OrderReviewResponse?> review = Rx<OrderReviewResponse?>(null);
  final Rx<List<ProductReview>> productReviews = Rx<List<ProductReview>>([]);

  Future<void> getReviews(String productId) async {
    try {
      isLoadingProductReview.value = true;
      final reviews = await _reviewRepository.getReviews(productId);
      productReviews.value = reviews.productReviews;
    } catch (e) {
      throw Exception(e);
    } finally {
      isLoadingProductReview.value = false;
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
      final review = await _reviewRepository.createReview(
        retailerId: retailerId,
        orderId: orderId,
        detailId: detailId,
        rating: rating,
        comment: comment,
      );
      return review;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> getReview(String retailerId, String orderId, String detailId) async {
    try {
      isLoadingReview.value = true;
      final review = await _reviewRepository.getReview(retailerId, orderId, detailId);
      this.review.value = review;
    } catch (e) {
      review.value = null;
    } finally {
      isLoadingReview.value = false;
    }
  }
}
