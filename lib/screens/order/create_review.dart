import 'package:cfv_mobile/controller/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateReviewScreen extends StatefulWidget {
  final String retailerId;
  final String orderId;
  final String detailId;
  const CreateReviewScreen({super.key, required this.retailerId, required this.orderId, required this.detailId});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final ReviewController _reviewController = Get.find<ReviewController>();
  final bool _isAnonymous = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildReviewSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate your experience',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = index + 1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: index < _selectedRating ? Colors.amber : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getRatingText(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write your review',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Share your experience with this product...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _selectedRating > 0 && _commentController.text.isNotEmpty;

    return SizedBox(
      key: UniqueKey(),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          'Submit Review',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_selectedRating) {
      case 1:
        return 'Poor - Not satisfied at all';
      case 2:
        return 'Fair - Could be better';
      case 3:
        return 'Good - Satisfied';
      case 4:
        return 'Very Good - Highly satisfied';
      case 5:
        return 'Excellent - Outstanding experience';
      default:
        return 'Tap to rate';
    }
  }

  void _submitReview() async {
    final review = await _reviewController.createReview(
      retailerId: widget.retailerId,
      orderId: widget.orderId,
      detailId: widget.detailId,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    if (review.reviewId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully!')));
      _reviewController.getReview(widget.retailerId, widget.orderId, widget.detailId);
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review failed to submit!')));
    }
  }
}
