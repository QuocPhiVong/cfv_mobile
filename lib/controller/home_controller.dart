import 'package:cfv_mobile/data/repositories/home_repository.dart';
import 'package:cfv_mobile/data/responses/home_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Provides a static instance getter for easy access throughout your app
  static HomeController get instance => Get.find();

  final HomeRepository _homeRepository = HomeRepository.instance;

  Rx<bool> isCategoriesLoading = true.obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  Rx<bool> isGardenersLoading = true.obs;
  RxList<GardenersModel> gardeners = <GardenersModel>[].obs;

  Rx<bool> isPostsLoading = true.obs;
  RxList<PostModel> posts = <PostModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    debugPrint('HomeController onReady: Initialized successfully.');
  }

  Future<void> loadCategoriesData() async {
    isCategoriesLoading.value = true;
    final data = await _homeRepository.fetchCategories();
    isCategoriesLoading.value = false;
    if (data != null) {
      categories.assignAll(data.categories);
      debugPrint('Categories data loaded successfully: ${data.categories}');
    } else {
      debugPrint('Failed to load categories data.');
    }
  }

  Future<void> loadGardenersData() async {
    isGardenersLoading.value = true;
    final data = await _homeRepository.fetchGardeners();
    isGardenersLoading.value = false;
    if (data != null) {
      gardeners.assignAll(data.gardeners);
      debugPrint('Gardeners data loaded successfully: ${data.gardeners}');
    } else {
      debugPrint('Failed to load gardeners data.');
    }
    return;
  }

  Future<void> loadPostsData() async {
    isPostsLoading.value = true;
    final data = await _homeRepository.fetchPosts();
    isPostsLoading.value = false;
    if (data != null) {
      posts.assignAll(data.posts);
      debugPrint('Posts data loaded successfully: ${data.posts}');
    } else {
      debugPrint('Failed to load posts data.');
    }
  }
}
