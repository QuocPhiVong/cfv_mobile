// {"reviewId":"01K33YQNRXZ9DEKNCD6W95B4N7","retailerId":"01JZ5PP9911H90Y5C01D8SK2VQ","orderDetailId":"01K2K1JZE55DJN6FB9G1WJN2HE","rating":5,"comment":"string","createdAt":"2025-08-20T14:39:39"}

class OrderReviewResponse {
  final String reviewId;
  final String retailerId;
  final String orderDetailId;
  final int rating;
  final String comment;
  final String createdAt;

  OrderReviewResponse({
    required this.reviewId,
    required this.retailerId,
    required this.orderDetailId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory OrderReviewResponse.fromJson(Map<String, dynamic> json) {
    return OrderReviewResponse(
      reviewId: json['reviewId'],
      retailerId: json['retailerId'],
      orderDetailId: json['orderDetailId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'retailerId': retailerId,
      'orderDetailId': orderDetailId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
