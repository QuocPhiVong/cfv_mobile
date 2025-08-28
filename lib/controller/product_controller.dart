import 'package:cfv_mobile/data/repositories/product_repository.dart';
import 'package:cfv_mobile/data/responses/product_response.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository.instance;

  Rx<bool> isLoading = true.obs;
  Rx<ProductModel?> product = Rx<ProductModel?>(null);

  Rx<bool> isProductPriceLoading = true.obs;
  Rx<ProductPriceModel?> productPrice = Rx<ProductPriceModel?>(null);

  Rx<bool> isProductCertificateLoading = true.obs;
  Rx<ProductCertificateModel?> productCertificates = Rx<ProductCertificateModel?>(null);

  @override
  void onReady() {
    super.onReady();
    debugPrint('ProductController onReady: Initialized successfully.');
  }

  Future<void> loadProductDetails(String productId, String postId) async {
    isLoading.value = true;
    try {
      final data = await _productRepository.fetchProductDetails(productId, postId);
      if (data != null) {
        product.value = data;
        debugPrint('Product details loaded successfully: ${data.productName}');
        if (data.productPriceId != null && data.productPriceId?.isNotEmpty == true) {
          Future.wait([loadProductPrice(data.productPriceId ?? ''), loadProductCertificates(data.productId ?? '')]);
        } else {
          debugPrint('No product price ID found for product: ${data.productName}');
        }
      } else {
        debugPrint('Failed to load product details for ID: $productId');
      }
    } catch (e) {
      debugPrint('Error loading product details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProductPrice(String productId) async {
    isProductPriceLoading.value = true;
    try {
      final data = await _productRepository.fetchProductPrices(productId);
      if (data != null && data.productPrices != null && data.productPrices!.isNotEmpty) {
        productPrice.value = data.productPrices?.first;
        debugPrint('Product price loaded successfully: ${data.productPrices?.first.price}');
      } else {
        debugPrint('Failed to load product price for ID: $productId');
      }
    } catch (e) {
      debugPrint('Error loading product price: $e');
    } finally {
      isProductPriceLoading.value = false;
    }
  }

  Future<void> loadProductCertificates(String productId) async {
    isProductCertificateLoading.value = true;
    try {
      final data = await _productRepository.fetchProductCertificates(productId);
      if (data != null && data.productCertificates != null && data.productCertificates!.isNotEmpty) {
        productCertificates.value = data.productCertificates?.first; // Assuming you want the first certificate
        debugPrint('Product certificates loaded successfully: ${data.productCertificates?.length} certificates found.');
      } else {
        debugPrint('Failed to load product certificates for ID: $productId');
      }
    } catch (e) {
      debugPrint('Error loading product certificates: $e');
    } finally {
      isProductCertificateLoading.value = false;
    }
  }
}
