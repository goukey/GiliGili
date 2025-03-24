import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/http/live.dart';
import 'package:GiliGili/models/live/follow.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class LiveController extends CommonController {
  @override
  void onInit() {
    super.onInit();
    queryData();
    if (isLogin.value) {
      fetchLiveFollowing();
    }
  }

  @override
  Future<LoadingState> customGetData() => LiveHttp.liveList(pn: currentPage);

  @override
  Future onRefresh() {
    fetchLiveFollowing();
    return super.onRefresh();
  }

  late RxBool isLogin = Accounts.main.isLogin.obs;
  late Rx<LoadingState> followListState = LoadingState.loading().obs;
  late int followPage = 1;
  late bool followEnd = false;
  late RxInt liveCount = 0.obs;

  Future fetchLiveFollowing([bool isRefresh = true]) async {
    if (isRefresh.not && followEnd) {
      return;
    }
    if (isRefresh) {
      followPage = 1;
      followEnd = false;
    }
    dynamic res = await LiveHttp.liveFollowing(pn: followPage, ps: 20);
    if (res['status']) {
      followPage++;
      liveCount.value = res['data'].liveCount;
      List list = res['data']
          .list
          .where((LiveFollowingItemModel item) =>
              item.liveStatus == 1 && item.recordLiveTime == 0)
          .toList();
      if (isRefresh.not && followListState.value is Success) {
        list.insertAll(0, (followListState.value as Success).response);
      }
      followEnd = list.length >= liveCount.value ||
          list.isEmpty ||
          (res['data'].list as List?).isNullOrEmpty;
      followListState.value = LoadingState.success(list);
    } else {
      followListState.value = LoadingState.error(res['msg']);
    }
  }
}
