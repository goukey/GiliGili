import 'package:GiliGili/models/common/search_type.dart';
import 'package:get/get.dart';

class SearchResultController extends GetxController {
  String keyword = Get.parameters['keyword'] ?? '';

  RxList<int> count =
      List.generate(SearchType.values.length, (_) => -1).toList().obs;
}
