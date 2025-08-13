import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  final Map<String, dynamic> post = {
    "postId": "01K1BE67EJ4DXXD006CKZ40DWK",
    "title": "Gạo Hữu Cơ ST25 – Dẻo Thơm Tinh Khiết Từ Thiên Nhiên",
    "content": "✅ Mô tả:\nGạo ST25 hữu cơ là loại gạo cao cấp, được trồng theo quy trình hữu cơ tự nhiên tại vùng đất màu mỡ của Sóc Trăng. Đây là giống gạo từng đạt giải \"Ngon nhất thế giới\"với hạt dài, trắng trong, cơm nấu lên dẻo nhẹ, thơm dịu và ngọt hậu. Sản phẩm hoàn toàn không hóa chất, không thuốc trừ sâu, không phân bón tổng hợp – an toàn cho mọi đối tượng.\nĐặc điểm nổi bật:\nGiống gạo:\n ST25 – Top 1 thế giới (2019)\nCanh tác hữu cơ:\nTrồng tại vùng nguyên liệu đạt chuẩn hữu cơ, canh tác bền vững, bảo vệ môi trường.\nChất lượng hạt:\nHạt dài, đều, ít gãy, nở vừa, không khô, không nhão.\nPhù hợp:\nCho người già, trẻ nhỏ, người bệnh tiểu đường nhẹ hoặc đang ăn theo chế độ sạch.\nThông tin sản phẩm:\nBao bì: Túi zip khóa kín hoặc bao giấy kraft thân thiện môi trường\nBảo quản: Nơi khô ráo, thoáng mát. Nên dùng trong 60 ngày kể từ khi mở túi.\nHướng dẫn sử dụng: Vo nhẹ 1–2 lần, nấu với tỉ lệ 1 gạo : 1.2–1.4 nước tùy khẩu vị",
    "harvestDate": "2025-07-29T00:00:00",
    "postStatus": "ACTIVE",
    "rating": 0,
    "createdAt": "2025-07-29T15:53:02",
    "postEndDate": "2025-07-29T00:00:00",
    "priority": 100,
    "video": "https://res.cloudinary.com/dhin0zlf7/video/upload/v1753804378/dslqemiitxhowsrdqsmh.mp4",
    "thumbNail": "https://res.cloudinary.com/dhin0zlf7/video/upload/so_1/dslqemiitxhowsrdqsmh.jpg",
    "images": [
      "https://res.cloudinary.com/dhin0zlf7/image/upload/v1753804379/h5ogr3dmcehx0kbmdefb.webp",
      "https://res.cloudinary.com/dhin0zlf7/image/upload/v1753804380/irm45ldrxyglkqk27wab.jpg"
    ],
    "gardenerId": "01JZ5PP992S211N3GA55CYDACW",
    "gardenderName": "An Phu Organic Farm",
    "gardenerAvatar": "http://res.cloudinary.com/dhin0zlf7/image/upload/v1754433250/f5rdeycnlvsmeoblr8qv.jpg",
    "productId": "01K1BDM2CERFDXW9WM1DHGC323",
    "productData": {
      "productName": "Gạo Hữu Cơ ",
      "updatedAt": "2025-07-29T15:43:07",
      "productStatus": "ACTIVE",
      "productCategory": "Gạo",
      "price": 65000,
      "currency": "VND",
      "weightUnit": "kg"
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bài viết',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            _buildPostContent(),
            _buildProductImages(),
            _buildAttachedProduct(),
            _buildMessageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    final createdAt = DateTime.parse(post['createdAt']);
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: post['gardenerAvatar'] != null
                  ? Image.network(
                      post['gardenerAvatar'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.green[600],
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.green[600],
                      size: 24,
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['gardenderName'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${post['postId'].toString().substring(0, 8)}... • ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['title'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          Text(
            post['content'],
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    final images = post['images'] as List<dynamic>?;
    
    if (images == null || images.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: index < images.length - 1 ? 8 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachedProduct() {
    final productData = post['productData'] as Map<String, dynamic>;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm đính kèm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.eco,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['productName'] ?? 'Sản phẩm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatCurrency(productData['price'].toDouble()) + '/${productData['weightUnit']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showProductDetails(),
              child: Text(
                'Chi tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Gửi tin nhắn cho Gardener',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.green[400]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: () => _sendMessage(),
                  icon: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return '${formatter.format(amount).trim()}.0 VND';
  }

  void _showProductDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem chi tiết sản phẩm'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi tin nhắn: ${_messageController.text}'),
          backgroundColor: Colors.green[600],
        ),
      );
      _messageController.clear();
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Báo cáo bài viết'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Chặn người dùng'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
