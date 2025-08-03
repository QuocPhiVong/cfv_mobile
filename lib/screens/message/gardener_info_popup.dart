import 'package:flutter/material.dart';

class GardenerInfoPopup extends StatelessWidget {
  final String gardenName;
  final String phoneNumber;
  final double rating;
  final String joinDate;
  final String address;
  final String certificationText;
  final bool isOnline;
  final VoidCallback? onMoreInfoPressed;
  final VoidCallback? onClosePressed;

  const GardenerInfoPopup({
    Key? key,
    required this.gardenName,
    required this.phoneNumber,
    required this.rating,
    required this.joinDate,
    required this.address,
    required this.certificationText,
    this.isOnline = true,
    this.onMoreInfoPressed,
    this.onClosePressed,
  }) : super(key: key);

  /// Static method to show the gardener info popup
  static Future<void> show(
    BuildContext context, {
    required String gardenName,
    required String phoneNumber,
    required double rating,
    required String joinDate,
    required String address,
    required String certificationText,
    bool isOnline = true,
    VoidCallback? onMoreInfoPressed,
    VoidCallback? onClosePressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return GardenerInfoPopup(
          gardenName: gardenName,
          phoneNumber: phoneNumber,
          rating: rating,
          joinDate: joinDate,
          address: address,
          certificationText: certificationText,
          isOnline: isOnline,
          onMoreInfoPressed: onMoreInfoPressed,
          onClosePressed: onClosePressed,
        );
      },
    );
  }

  /// Static method to show with default data (Vườn Xanh Miền Tây)
  static Future<void> showDefault(
    BuildContext context, {
    VoidCallback? onMoreInfoPressed,
    VoidCallback? onClosePressed,
  }) {
    return show(
      context,
      gardenName: "Vườn Xanh Miền Tây",
      phoneNumber: "0901 234 567",
      rating: 4.8,
      joinDate: "Tham gia: Tháng 3/2023",
      address: "123 Đường Cần Thơ, An Giang",
      certificationText: "Vườn chúng tôi đã được cấp chứng nhận an toàn thực phẩm từ Sở Y tế và các cơ quan có thẩm quyền.",
      isOnline: true,
      onMoreInfoPressed: onMoreInfoPressed,
      onClosePressed: onClosePressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildProfileSection(),
              SizedBox(height: 24),
              _buildContactInfoSection(),
              SizedBox(height: 16),
              _buildCertificationSection(),
              SizedBox(height: 16),
              _buildActionButton(context),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Thông tin vườn",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              if (onClosePressed != null) {
                onClosePressed!();
              }
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the profile section with avatar, name, and rating
  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildAvatar(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gardenName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                _buildRating(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the avatar with online status indicator
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFFB8E6B8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person,
            color: Color(0xFF4CAF50),
            size: 30,
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the rating display with star icon
  Widget _buildRating() {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.orange,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8),
        Text(
          "(Đánh giá)",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds the contact information section
  Widget _buildContactInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 8),
              Text(
                "Thông tin liên lạc",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow("Tên vườn", gardenName),
          SizedBox(height: 12),
          _buildInfoRow("Đã tham gia", joinDate),
          SizedBox(height: 12),
          _buildInfoRow("Số điện thoại", phoneNumber),
          SizedBox(height: 12),
          _buildInfoRow("Địa chỉ cư trú", address),
        ],
      ),
    );
  }

  /// Builds the food safety certification section
  Widget _buildCertificationSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Chứng nhận an toàn thực phẩm",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            certificationText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  /// Builds the action button at the bottom
  Widget _buildActionButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (onMoreInfoPressed != null) {
            onMoreInfoPressed!();
          } else {
            Navigator.pop(context);
            _showDefaultMoreInfoAction(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF81C4E8),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: Color(0xFF81C4E8).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              "Xem thêm thông tin",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an information row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          ": ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Default action when more info button is pressed
  void _showDefaultMoreInfoAction(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Xem thêm thông tin về $gardenName",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}