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

// [{productReviewId: 01K33YQNRXZ9DEKNCD6W95B4N7, name: Hoa Sua Foods, avatar: None, rating: 5, comment: string, createdAt: 2025-08-20T14:39:39}, {productReviewId: 01K38MFZ2046BE4V8QXSTBZX3F, name: Hoa Sua Foods, avatar: None, rating: 2, comment: OK nha, createdAt: 2025-08-22T10:16:53}, {productReviewId: 01K38P2Z1AGKF4NQM3C5B3ESBM, name: Hoa Sua Foods, avatar: None, rating: 3, comment: 123123213, createdAt: 2025-08-22T10:44:44}]

class ProductReviewResponse {
  final List<ProductReview> productReviews;

  ProductReviewResponse({required this.productReviews});

  factory ProductReviewResponse.fromJson(List<dynamic> json) {
    return ProductReviewResponse(productReviews: json.map((e) => ProductReview.fromJson(e)).toList());
  }
}

class ProductReview {
  final String productReviewId;
  final String name;
  final String avatar;
  final int rating;
  final String comment;
  final String createdAt;

  ProductReview({
    required this.productReviewId,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      productReviewId: json['productReviewId'],
      name: json['name'],
      avatar: json['avatar'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }
}
