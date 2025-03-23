import 'package:PiliPlus/http/fan.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fans/result.dart';
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/storage.dart';

class FansController extends CommonController {
  int ps = 20;
  int total = 0;
  late int? mid;
  late String? name;
  dynamic userInfo;
  RxBool isOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    userInfo = GStorage.userInfo.get('userInfoCache');
    mid = Get.parameters['mid'] != null
        ? int.parse(Get.parameters['mid']!)
        : userInfo?.mid;
    isOwner.value = mid == userInfo?.mid;
    name = Get.parameters['name'] ?? userInfo?.uname;

    queryData();
  }

  @override
  bool customHandleResponse(Success response) {
    if ((currentPage == 1 && response.response.total < ps) ||
        (response.response.list as List?).isNullOrEmpty) {
      isEnd = true;
    }
    if (currentPage != 1 && loadingState.value is Success) {
      response.response.list ??= <FansItemModel>[];
      response.response.list!
          .insertAll(0, (loadingState.value as Success).response);
    }
    loadingState.value = LoadingState.success(response.response.list);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => FanHttp.fans(
        vmid: mid,
        pn: currentPage,
        ps: ps,
        orderType: 'attention',
      );
}
