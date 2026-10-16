import 'package:get/get.dart';

class ProductFilterController extends GetxController {
  final selectedCategories = <String>{}.obs;
  final sortOption = 'Relevance'.obs;

  void applyFilters(Set<String> categories, String sort) {
    selectedCategories.assignAll(categories);
    sortOption.value = sort;
  }

  void reset() {
    selectedCategories.clear();
    sortOption.value = 'Relevance';
  }
}
