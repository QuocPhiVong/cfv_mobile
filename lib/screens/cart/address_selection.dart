import 'package:flutter/material.dart';

class AddressListScreen extends StatefulWidget {
  final String? selectedAddress;

  const AddressListScreen({
    Key? key,
    this.selectedAddress,
  }) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String? selectedAddress;
  
  // Sample addresses - in real app, this would come from a database
  final List<Map<String, String>> addresses = [
    {
      'id': '1',
      'name': 'Nhà riêng',
      'address': '123 Đường Cần Thơ, An Giang',
      'phone': '0901 234 567',
      'isDefault': 'true',
    },
    {
      'id': '2',
      'name': 'Văn phòng',
      'address': '456 Đường Trần Hưng Đạo, TP. Cần Thơ',
      'phone': '0901 234 567',
      'isDefault': 'false',
    },
    {
      'id': '3',
      'name': 'Nhà bố mẹ',
      'address': '789 Đường Nguyễn Văn Linh, Long Xuyên, An Giang',
      'phone': '0901 234 567',
      'isDefault': 'false',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.selectedAddress;
    
    // If no address is selected, select the default one
    if (selectedAddress == null || selectedAddress!.isEmpty) {
      final defaultAddress = addresses.firstWhere(
        (address) => address['isDefault'] == 'true',
        orElse: () => addresses.first,
      );
      selectedAddress = defaultAddress['address'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn địa chỉ giao hàng',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = selectedAddress == address['address'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedAddress = address['address'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (address['isDefault'] == 'true') ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Mặc định',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  address['address']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SĐT: ${address['phone']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: address['address']!,
                            groupValue: selectedAddress,
                            onChanged: (String? value) {
                              setState(() {
                                selectedAddress = value;
                              });
                            },
                            activeColor: Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom button container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAddress != null && selectedAddress!.isNotEmpty
                      ? () {
                          Navigator.pop(context, selectedAddress);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xác nhận địa chỉ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}