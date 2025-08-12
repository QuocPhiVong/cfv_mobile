import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/oder_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressListScreen extends StatefulWidget {
  String? selectedAddress;

  AddressListScreen({super.key, this.selectedAddress});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final OderController oderController = Get.find<OderController>();

  @override
  void initState() {
    super.initState();
    oderController.getAddress(Get.find<AuthenticationController>().currentUser?.accountId ?? '');
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
          style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => (oderController.isLoading.value)
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: oderController.addresses.length,
                      itemBuilder: (context, index) {
                        final address = oderController.addresses[index];
                        final isSelected = widget.selectedAddress == address.addressLine;

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
                                widget.selectedAddress = address.addressLine;
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
                                              address.addressLine ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (address.addressId == widget.selectedAddress) ...[
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
                                          address.addressLine ?? '',
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: address.addressLine ?? '',
                                    groupValue: widget.selectedAddress,
                                    onChanged: (String? value) {
                                      setState(() {
                                        widget.selectedAddress = value;
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
                          onPressed: widget.selectedAddress != null && widget.selectedAddress!.isNotEmpty
                              ? () {
                                  Navigator.pop(context, widget.selectedAddress);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Xác nhận địa chỉ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
